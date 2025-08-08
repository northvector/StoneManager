#!/usr/bin/env bash
set -uo pipefail

# STONE Manager - Raspberry Pi OS shell UI
# Exact packet format:
# [0xFF, 0x01, flags(0), payloadLen, vendorHi, vendorLo, commandHi, commandLo, payload..., (no checksum since flags=0)]

RFCOMM_DEV="/dev/rfcomm0"
DEVICE_NAME_DEFAULT="STONE"
VENDOR_PT=0x5054
LOG_FILE="/tmp/stone-manager.log"
PID_FILE="/tmp/stone-rfcomm.pid"
CURRENT_MAC=""

log() {
  # Timestamped log lines
  printf '[%(%F %T)T] %s\n' -1 "$*" >> "$LOG_FILE"
}

require_tools() {
  local tools=(bluetoothctl sdptool rfcomm whiptail dd timeout od)
  local missing=()
  for t in "${tools[@]}"; do
    command -v "$t" >/dev/null 2>&1 || missing+=("$t")
  done
  if (( ${#missing[@]} > 0 )); then
    echo "Missing tools: ${missing[*]}" >&2
    echo "Install BlueZ and whiptail. On Raspberry Pi OS: sudo apt-get update && sudo apt-get install -y bluez whiptail coreutils" >&2
    exit 1
  fi
}

sudo_wrap() {
  if [[ $EUID -ne 0 ]]; then
    sudo "$@"
  else
    "$@"
  fi
}

pick_device_menu() {
  local devices
  mapfile -t devices < <(bluetoothctl devices | awk '{print $2"\t"substr($0, index($0,$3))}')

  local choices=()
  for line in "${devices[@]}"; do
    local mac name
    mac="${line%%$'\t'*}"
    name="${line#*$'\t'}"
    choices+=("$mac" "$name")
  done

  local title="Select Bluetooth Device"
  local menu_out
  if (( ${#choices[@]} == 0 )); then
    whiptail --title "$title" --msgbox "No Bluetooth devices found. Put device in pairing mode and run again." 10 70
    return 1
  fi

  if menu_out=$(whiptail --title "$title" --nocancel --menu "Choose device (STONE recommended)" 18 70 10 "${choices[@]}" 3>&1 1>&2 2>&3); then
    echo "$menu_out"
    return 0
  fi
  return 1
}

pair_trust_connect() {
  local mac="$1"
  log "Pair/Trust/Connect starting for $mac"
  bluetoothctl <<EOF >>"$LOG_FILE" 2>&1
power on
agent NoInputNoOutput
default-agent
pairable on
trust $mac
pair $mac
connect $mac
info $mac
exit
EOF
  log "bluetoothctl pairing sequence complete for $mac"
}

find_rfcomm_channel() {
  local mac="$1"
  log "Querying SDP for RFCOMM channel on $mac"
  local ch
  ch=$(sdptool browse "$mac" 2>>"$LOG_FILE" | awk '
    tolower($0) ~ /protocol descriptor list/ {in_pdl=1}
    in_pdl && tolower($0) ~ /protocol: rfcomm/ {in_rf=1}
    in_rf && tolower($0) ~ /channel:/ {print $2; exit}
    tolower($0) ~ /additional protocol descriptor list/ {in_pdl=0; in_rf=0}
  ')
  if [[ -z "$ch" ]]; then
    log "No RFCOMM channel found via SDP, defaulting to 1"
    ch=1
  else
    log "Found RFCOMM channel: $ch"
  fi
  echo "$ch"
}

find_rfcomm_channels() {
  local mac="$1"
  log "Querying SDP for ALL RFCOMM channels on $mac"
  sdptool browse "$mac" 2>>"$LOG_FILE" | awk '
    tolower($0) ~ /protocol descriptor list/ {in_pdl=1}
    in_pdl && tolower($0) ~ /protocol: rfcomm/ {in_rf=1}
    in_rf && tolower($0) ~ /channel:/ {print $2}
    tolower($0) ~ /additional protocol descriptor list/ {in_pdl=0; in_rf=0}
  ' | awk '!seen[$0]++'
}

rfcomm_connected() {
  if sudo_wrap rfcomm show 0 >>"$LOG_FILE" 2>&1 | grep -qi "connected"; then
    return 0
  fi
  # Fallback: device present and writable often implies connected
  [[ -w "$RFCOMM_DEV" ]]
}

wait_for_connected() {
  local max_wait_s=${1:-10}
  local waited=0
  while (( waited < max_wait_s )); do
    if rfcomm_connected; then
      log "rfcomm reports connected"
      return 0
    fi
    sleep 0.5
    waited=$(( waited + 1 ))
  done
  log "Timeout waiting for RFCOMM to connect"
  return 1
}

connect_rfcomm_try_channel() {
  local mac="$1" channel="$2"
  log "Trying RFCOMM channel $channel"
  disconnect_rfcomm_quiet
  sudo_wrap rfcomm connect 0 "$mac" "$channel" >>"$LOG_FILE" 2>&1 &
  echo $! > "$PID_FILE"
  if wait_for_connected 6; then
    log "Connected on channel $channel"
    return 0
  else
    local pid=$(cat "$PID_FILE" 2>/dev/null || true)
    if [[ -n "$pid" ]] && ps -p "$pid" >/dev/null 2>&1; then
      sudo_wrap kill "$pid" >>"$LOG_FILE" 2>&1 || true
      sleep 0.2
    fi
    rm -f "$PID_FILE"
    log "Channel $channel failed"
    return 1
  fi
}

connect_rfcomm() {
  local mac="$1"; shift
  local channels=("$@")
  if (( ${#channels[@]} == 0 )); then
    channels=(1 2 3 4 5 6 7 8)
  fi
  log "Connecting RFCOMM to $mac, trying channels: ${channels[*]}"
  local ch
  for ch in "${channels[@]}"; do
    if connect_rfcomm_try_channel "$mac" "$ch"; then
      return 0
    fi
  done
  # As a last resort, brute force a wider range
  log "Bruteforce channels 1..16"
  for ch in $(seq 1 16); do
    if connect_rfcomm_try_channel "$mac" "$ch"; then
      return 0
    fi
  done
  return 1
}

disconnect_rfcomm_quiet() {
  # Kill background rfcomm connect process if present
  if [[ -f "$PID_FILE" ]]; then
    local pid
    pid=$(cat "$PID_FILE" || true)
    if [[ -n "$pid" ]] && ps -p "$pid" >/dev/null 2>&1; then
      log "Killing rfcomm PID $pid"
      sudo_wrap kill "$pid" >>"$LOG_FILE" 2>&1 || true
      sleep 0.2
    fi
    rm -f "$PID_FILE"
  fi
  # Release rfcomm device
  if [[ -e "$RFCOMM_DEV" ]]; then
    log "Releasing $RFCOMM_DEV"
    sudo_wrap rfcomm release 0 >>"$LOG_FILE" 2>&1 || sudo_wrap rfcomm release "$RFCOMM_DEV" >>"$LOG_FILE" 2>&1 || true
  fi
}

disconnect_flow() {
  log "User requested disconnect"
  disconnect_rfcomm_quiet
  if [[ -n "$CURRENT_MAC" ]]; then
    log "bluetoothctl disconnect $CURRENT_MAC"
    bluetoothctl <<EOF >>"$LOG_FILE" 2>&1
disconnect $CURRENT_MAC
exit
EOF
  fi
  whiptail --msgbox "Disconnected." 8 40
}

is_connected() {
  rfcomm_connected
}

is_acl_connected() {
  local mac="$1"
  bluetoothctl info "$mac" 2>>"$LOG_FILE" | awk -F': ' '/Connected:/ {print $2}' | grep -qi '^yes$'
}

wait_for_acl() {
  local mac="$1" max_wait_s=${2:-10}
  local waited=0
  while (( waited < max_wait_s )); do
    if is_acl_connected "$mac"; then
      log "ACL connected for $mac"
      return 0
    fi
    sleep 1
    waited=$(( waited + 1 ))
  done
  log "Timeout waiting for ACL connection to $mac"
  return 1
}

## Build a packet into a temp file to avoid NUL-in-variable issues
# Sets PACKET_FILE to the path of the temp file
# Args: vendor_id(int, decimal or 0x hex), command_id(int), payload bytes (0-255, decimal)
make_packet_file() {
  local vendor_id="$1" command_id="$2"; shift 2
  local payload=("$@")

  local vendor
  if [[ "$vendor_id" == 0x* || "$vendor_id" == 0X* ]]; then
    vendor=$((vendor_id))
  else
    vendor=$vendor_id
  fi
  local command=$command_id

  local payload_len=${#payload[@]}
  if (( payload_len > 254 )); then
    log "Payload too long: $payload_len"
    return 1
  fi

  local flags=0
  local vendor_hi=$(( (vendor >> 8) & 0xFF ))
  local vendor_lo=$(( vendor & 0xFF ))
  local cmd_hi=$(( (command >> 8) & 0xFF ))
  local cmd_lo=$(( command & 0xFF ))

  PACKET_FILE=$(mktemp)
  {
    # Print backslash-octal escapes for bytes
    printf '\\%03o' 255 1 "$flags" "$payload_len" "$vendor_hi" "$vendor_lo" "$cmd_hi" "$cmd_lo"
    local b
    for b in "${payload[@]}"; do
      printf '\\%03o' $(( b & 0xFF ))
    done
  } | printf '%b' > "$PACKET_FILE"
}

hex_dump_bytes() {
  local file="$1"
  od -An -t x1 -v "$file" | tr -s ' ' ' ' | sed 's/^ *//; s/ *$//'
}

send_packet() {
  if ! is_connected; then
    log "send_packet: not connected"
    whiptail --title "Not connected" --msgbox "RFCOMM is not connected." 8 50
    return 1
  fi
  local file="$1"
  log "TX $(hex_dump_bytes "$file")"
  if ! sudo timeout 3s dd if="$file" of="$RFCOMM_DEV" bs=1 status=none conv=fsync >>"$LOG_FILE" 2>&1; then
    log "dd write timed out or failed"
    whiptail --title "Write failed" --msgbox "Failed to write to RFCOMM device (timeout)." 8 60
    return 1
  fi
  return 0
}

send_command() {
  local vendor_id="$1" command_id="$2"; shift 2
  log "send_command vendor=$vendor_id cmd=$command_id payload=(${*:-})"
  make_packet_file "$vendor_id" "$command_id" "$@" || return 1
  send_packet "$PACKET_FILE"
  rm -f "$PACKET_FILE" 2>/dev/null || true
}

handshake() {
  log "Performing handshake"
  send_command "$VENDOR_PT" 1 || return 1
  send_command "$VENDOR_PT" 16 || return 1
  local r=$(( (RANDOM % 2) + 1 ))
  send_command "$VENDOR_PT" 578 "$r" || true
}

set_volume() {
  local vol
  vol=$(whiptail --title "Set Volume" --inputbox "0-31" 8 40 31 3>&1 1>&2 2>&3) || return 1
  [[ -z "$vol" ]] && return 1
  if ! [[ "$vol" =~ ^[0-9]+$ ]] || (( vol < 0 || vol > 31 )); then
    whiptail --msgbox "Invalid volume (0-31)" 8 40; return 1
  fi
  send_command "$VENDOR_PT" 513 "$vol"
}

ask_rgb_brightness() {
  local r g b br
  r=$(whiptail --inputbox "Red 63-255" 8 40 255 3>&1 1>&2 2>&3) || return 1
  g=$(whiptail --inputbox "Green 63-255" 8 40 255 3>&1 1>&2 2>&3) || return 1
  b=$(whiptail --inputbox "Blue 63-255" 8 40 255 3>&1 1>&2 2>&3) || return 1
  br=$(whiptail --inputbox "Brightness 0-100" 8 40 100 3>&1 1>&2 2>&3) || return 1
  if ! [[ "$r" =~ ^[0-9]+$ && "$g" =~ ^[0-9]+$ && "$b" =~ ^[0-9]+$ && "$br" =~ ^[0-9]+$ ]]; then
    whiptail --msgbox "Invalid values." 8 40; return 1
  fi
  (( r<63 || r>255 || g<63 || g>255 || b<63 || b>255 || br<0 || br>100 )) && { whiptail --msgbox "Out of range." 8 40; return 1; }
  echo "$r $g $b $br"
}

rgb_turn_on() {
  local vals
  if ! vals=$(ask_rgb_brightness); then return 1; fi
  read -r r g b br <<<"$vals"
  send_command "$VENDOR_PT" 514 "$br"
  send_command "$VENDOR_PT" 515 1
  send_command "$VENDOR_PT" 530 "$br" 1 "$r" "$g" "$b"
}

rgb_set_color() {
  local vals
  if ! vals=$(ask_rgb_brightness); then return 1; fi
  read -r r g b br <<<"$vals"
  send_command "$VENDOR_PT" 514 "$br"
  send_command "$VENDOR_PT" 515 1
  send_command "$VENDOR_PT" 516 "$r" "$g" "$b"
}

rgb_set_mood() {
  local vals
  if ! vals=$(ask_rgb_brightness); then return 1; fi
  read -r r g b br <<<"$vals"
  local mood
  mood=$(whiptail --title "Mood" --menu "Choose LED style" 15 50 6 \
    2 "SOLID" \
    3 "CANDLE" \
    4 "AURORA" \
    5 "SEA_WAVE" \
    6 "FIREFLY" \
    3>&1 1>&2 2>&3) || return 1
  send_command "$VENDOR_PT" 530 "$br" "$mood" "$r" "$g" "$b"
}

connect_flow() {
  local mac channels
  if ! mac=$(pick_device_menu); then return 1; fi
  CURRENT_MAC="$mac"
  pair_trust_connect "$mac" || true
  wait_for_acl "$mac" 12 || log "Proceeding without ACL confirmation"
  # Prefer all discovered RFCOMM channels
  mapfile -t channels < <(find_rfcomm_channels "$mac")
  if connect_rfcomm "$mac" "${channels[@]}"; then
    handshake || true
    whiptail --msgbox "Connected to $mac" 8 60
  else
    whiptail --msgbox "Failed to connect to $mac. See log." 8 60
  fi
}

view_logs() {
  touch "$LOG_FILE"
  whiptail --title "Debug Log" --scrolltext --textbox "$LOG_FILE" 22 88
}

main_menu() {
  : > "$LOG_FILE"   # clear log at start
  log "STONE Manager started"
  while true; do
    local choice
    choice=$(whiptail --title "STONE Manager (Pi)" --menu "Choose an action" 20 72 10 \
      connect "Connect to device" \
      volume "Set volume (0-31)" \
      rgb_on "Turn ON LEDs (set color+brightness)" \
      rgb_set "Set color (RGB + brightness)" \
      mood "Set LED mood/style" \
      rgb_off "Turn OFF LEDs" \
      disconnect "Disconnect RFCOMM" \
      status "Show connection status" \
      logs "View debug log" \
      quit "Exit" \
      3>&1 1>&2 2>&3) || exit 0

    case "$choice" in
      connect) connect_flow ;;
      volume) set_volume ;;
      rgb_on) rgb_turn_on ;;
      rgb_set) rgb_set_color ;;
      mood) rgb_set_mood ;;
      rgb_off) send_command "$VENDOR_PT" 531 ;;
      disconnect) disconnect_flow ;;
      status)
        local acl="no" rf="no"
        [[ -n "$CURRENT_MAC" ]] && is_acl_connected "$CURRENT_MAC" && acl="yes"
        rfcomm_connected && rf="yes"
        whiptail --msgbox "ACL connected: $acl\nRFCOMM connected: $rf\nDevice: ${CURRENT_MAC:-n/a}" 10 50 ;;
      logs) view_logs ;;
      quit) exit 0 ;;
    esac
  done
}

require_tools
main_menu