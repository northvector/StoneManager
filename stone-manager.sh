#!/usr/bin/env bash
set -euo pipefail

# STONE Manager - Raspberry Pi OS shell UI
# Uses RFCOMM SPP, replicating the exact packet format from the Windows app:
# [0xFF, 0x01, flags(0), payloadLen, vendorHi, vendorLo, commandHi, commandLo, payload..., (no checksum since flags=0)]

# Dependencies required: bluetoothctl, sdptool, rfcomm, whiptail

RFCOMM_DEV="/dev/rfcomm0"
DEVICE_NAME_DEFAULT="STONE"
VENDOR_PT=0x5054

require_tools() {
  local tools=(bluetoothctl sdptool rfcomm whiptail)
  local missing=()
  for t in "${tools[@]}"; do
    command -v "$t" >/dev/null 2>&1 || missing+=("$t")
  done
  if (( ${#missing[@]} > 0 )); then
    echo "Missing tools: ${missing[*]}" >&2
    echo "Install BlueZ and whiptail. On Raspberry Pi OS: sudo apt-get update && sudo apt-get install -y bluez whiptail" >&2
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
  local preselect=""
  for line in "${devices[@]}"; do
    local mac name
    mac="${line%%$'\t'*}"
    name="${line#*$'\t'}"
    choices+=("$mac" "$name")
    if [[ "$name" == "$DEVICE_NAME_DEFAULT" ]]; then
      preselect="$mac"
    fi
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
  # Pair, trust, and connect using bluetoothctl in a single non-interactive session
  bluetoothctl <<EOF | sed -n 's/^\[CHG\] Device .* Connected: \(yes\|no\)$/Connected: \1/p'
power on
agent on
default-agent
scan on
connect $mac
trust $mac
pair $mac
connect $mac
scan off
exit
EOF
}

find_rfcomm_channel() {
  local mac="$1"
  # Try to find the RFCOMM channel for Serial Port service via SDP
  sdptool browse "$mac" | awk '
    $0 ~ /Service Name: Serial Port/ {in_sp=1} 
    in_sp && $0 ~ /Channel: / {print $2; exit}
  '
}

bind_rfcomm() {
  local mac="$1" channel="$2"
  # Release any existing binding
  if [[ -e "$RFCOMM_DEV" ]]; then
    sudo_wrap rfcomm release "$RFCOMM_DEV" || true
  fi
  sudo_wrap rfcomm bind 0 "$mac" "$channel"
}

is_connected() {
  [[ -e "$RFCOMM_DEV" ]]
}

# Build a packet string with backslash-escaped hex for printf
# Args: vendor_id(int, decimal or 0x hex), command_id(int), payload bytes (0-255, decimal)
# Output: variable PACKET set to the printf-ready string
build_packet() {
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
    echo "Payload too long ($payload_len)" >&2
    return 1
  fi

  local flags=0
  local vendor_hi=$(( (vendor >> 8) & 0xFF ))
  local vendor_lo=$(( vendor & 0xFF ))
  local cmd_hi=$(( (command >> 8) & 0xFF ))
  local cmd_lo=$(( command & 0xFF ))

  PACKET=$(printf "\\x%02X\\x%02X\\x%02X\\x%02X\\x%02X\\x%02X\\x%02X\\x%02X" 0xFF 0x01 "$flags" "$payload_len" "$vendor_hi" "$vendor_lo" "$cmd_hi" "$cmd_lo")

  local b
  for b in "${payload[@]}"; do
    b=$(( b & 0xFF ))
    PACKET+=$(printf "\\x%02X" "$b")
  done
}

send_packet() {
  if ! is_connected; then
    whiptail --title "Not connected" --msgbox "RFCOMM is not connected." 8 50
    return 1
  fi
  local pkt="$1"
  # shellcheck disable=SC2059
  printf "$pkt" | sudo_wrap tee "$RFCOMM_DEV" >/dev/null
}

send_command() {
  local vendor_id="$1" command_id="$2"; shift 2
  build_packet "$vendor_id" "$command_id" "$@" || return 1
  send_packet "$PACKET"
}

handshake() {
  # Send initial commands like Windows app: 1, 16, and 578 with random 1..2
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

rgb_off() {
  send_command "$VENDOR_PT" 531
}

connect_flow() {
  local mac channel
  if ! mac=$(pick_device_menu); then return 1; fi
  pair_trust_connect "$mac" >/dev/null || true
  channel=$(find_rfcomm_channel "$mac")
  if [[ -z "$channel" ]]; then
    # Fallback to channel 1 if SDP did not return one
    channel=1
  fi
  if bind_rfcomm "$mac" "$channel"; then
    handshake || true
    whiptail --msgbox "Connected to $mac on channel $channel" 8 60
  else
    whiptail --msgbox "Failed to connect/bind RFCOMM." 8 50
  fi
}

disconnect_flow() {
  if [[ -e "$RFCOMM_DEV" ]]; then
    sudo_wrap rfcomm release "$RFCOMM_DEV" || true
  fi
}

main_menu() {
  while true; do
    local choice
    choice=$(whiptail --title "STONE Manager (Pi)" --menu "Choose an action" 20 70 10 \
      connect "Connect to device" \
      volume "Set volume (0-31)" \
      rgb_on "Turn ON LEDs (set color+brightness)" \
      rgb_set "Set color (RGB + brightness)" \
      mood "Set LED mood/style" \
      rgb_off "Turn OFF LEDs" \
      disconnect "Disconnect RFCOMM" \
      quit "Exit" \
      3>&1 1>&2 2>&3) || exit 0

    case "$choice" in
      connect) connect_flow ;;
      volume) set_volume ;;
      rgb_on) rgb_turn_on ;;
      rgb_set) rgb_set_color ;;
      mood) rgb_set_mood ;;
      rgb_off) rgb_off ;;
      disconnect) disconnect_flow ;;
      quit) exit 0 ;;
    esac
  done
}

require_tools
main_menu