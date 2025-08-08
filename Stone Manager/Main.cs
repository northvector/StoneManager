using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using InTheHand.Net.Bluetooth;
using InTheHand.Net.Sockets;
using System.Threading.Tasks;
using System.Windows.Forms;
using InTheHand.Net;
using System.IO;
using System.Threading;
using Stone_Manager.Classes;

namespace Stone_Manager
{
    public partial class Main : Form
    {
        bool OpenRGB_mode = false;
        bool OpenRGB_Status = false;
        bool is_lamp_on = false;

        private System.Windows.Forms.Timer _valueChangeTimer;
        public static Main mainform;
        int color_R = 255, color_G = 255, color_B = 255, brightness = 100, mood = 2;


        public Main()
        {
            InitializeComponent();
            _valueChangeTimer = new System.Windows.Forms.Timer
            {
                Interval = 200
            };
            _valueChangeTimer.Tick += _valueChangeTimer_Tick;
        }

   
        private void button1_Click(object sender, EventArgs e)
        {
            // Repurpose as LED toggle
            if (!Bluetooth.IsConnected()) return;
            Button2_Click(sender, e);
        }

        private async void Button2_Click(object sender, EventArgs e)
        {
            if (!Bluetooth.IsConnected()) return;
            if(!is_lamp_on){
               DeviceRGB.TurnOnDeviceRGB(color_R, color_G, color_B, brightness);
               STONE_Image.BackColor = Color.FromArgb((int) (brightness * 2.55f), color_R, color_G, color_B);
            }
            else
            {
                DeviceRGB.TurnOFFRGB();
                STONE_Image.BackColor = Color.Black;
            }
            is_lamp_on = !is_lamp_on;

            await Bluetooth.ReadResponseAsync();
        }

        private void TrackBar_G_ValueChanged(object sender, EventArgs e)
        {
            _valueChangeTimer.Stop();
            _valueChangeTimer.Start();  
        }

        private void Main_Load(object sender, EventArgs e)
        {
            mainform = this;
            try
            {
                Bluetooth.Connect();
            }
            catch (Exception)
            {
            }

        }

        private void trackBar_volume_Scroll(object sender, EventArgs e)
        {
            Device.SetVolume(trackBar_volume.Value);
        }
        private void Main_Resize(object sender, EventArgs e)
        {
            if (FormWindowState.Minimized == this.WindowState)
            {
                TrayIcon.Visible = true;
                this.WindowState = FormWindowState.Minimized;

                this.Hide();
            }
        }

        private void notifyIcon1_DoubleClick(object sender, EventArgs e)
        {
            this.Show();
            this.WindowState = FormWindowState.Normal;
            this.ShowInTaskbar = true;
            TrayIcon.Visible = false;
        }

        private void rEDToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (!Bluetooth.IsConnected()) return;
            string[] rgbValues = ((ToolStripMenuItem)sender).Tag.ToString().Split(',');
            int r = int.Parse(rgbValues[0]);
            int g = int.Parse(rgbValues[1]);
            int b = int.Parse(rgbValues[2]);
            Color newColor = Color.FromArgb(255, r, g, b);
            STONE_Image.BackColor = newColor;
            DeviceRGB.SetRGBColor(r, g, b, brightness);

        }

                 private void OpenRGB_Sync_Tick(object sender, EventArgs e)
         {
         }

        private void ledstyle_Click(object sender, EventArgs e)
        {
            if (!Bluetooth.IsConnected()) return;

            mood++;
            if (mood > 5) mood = 2;
            DeviceRGB.SetMood(mood);
            is_lamp_on = true;
            OpenRGB_mode = false;
        }

        private void _valueChangeTimer_Tick(object sender, EventArgs e)
        {
            _valueChangeTimer.Stop();
            if (!Bluetooth.IsConnected()) return;
            DeviceRGB.SetRGBColor(color_R, color_G, color_B, brightness);
            STONE_Image.BackColor = Color.FromArgb((int)(brightness * 2.55f), color_R, color_G, color_B);
        }

        private void TrackBar_R_Scroll(object sender, EventArgs e)
        {
            if (!Bluetooth.IsConnected()) return;
            if (((TrackBar)sender).Name == trackBar_R.Name)
            {
                color_R = trackBar_R.Value;
            }
            if (((TrackBar)sender).Name == trackBar_G.Name)
            {
                color_G = trackBar_G.Value;
            }
            if (((TrackBar)sender).Name == trackBar_B.Name)
            {
                color_B = trackBar_B.Value;
            }
            if (((TrackBar)sender).Name == trackBar_Br.Name)
            {
                brightness = trackBar_Br.Value;
            }
        }
    }
}
