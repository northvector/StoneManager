namespace Stone_Manager
{
    partial class Main
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Main));
            this.button_connect = new System.Windows.Forms.Button();
            this.led_toggle = new System.Windows.Forms.Button();
            this.panel1 = new System.Windows.Forms.Panel();
            this.trackBar_volume = new System.Windows.Forms.TrackBar();
            this.ledstyle = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.trackBar_G = new System.Windows.Forms.TrackBar();
            this.label3 = new System.Windows.Forms.Label();
            this.trackBar_R = new System.Windows.Forms.TrackBar();
            this.label5 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.trackBar_Br = new System.Windows.Forms.TrackBar();
            this.trackBar_B = new System.Windows.Forms.TrackBar();
            this.STONE_Image = new System.Windows.Forms.PictureBox();
            this.panel2 = new System.Windows.Forms.Panel();
            this.label_status = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.openRGB_Sync = new System.Windows.Forms.Timer(this.components);
            this.TrayIcon = new System.Windows.Forms.NotifyIcon(this.components);
            this.contextMenuStrip1 = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.quickColorToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.rEDToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.blueToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.yellowToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.trackBar_volume)).BeginInit();
            this.groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.trackBar_G)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.trackBar_R)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.trackBar_Br)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.trackBar_B)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.STONE_Image)).BeginInit();
            this.panel2.SuspendLayout();
            this.contextMenuStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // button_connect
            // 
            this.button_connect.AutoSize = true;
            this.button_connect.BackColor = System.Drawing.Color.DarkCyan;
            this.button_connect.Dock = System.Windows.Forms.DockStyle.Top;
            this.button_connect.FlatAppearance.BorderSize = 0;
            this.button_connect.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.button_connect.ForeColor = System.Drawing.Color.White;
            this.button_connect.Location = new System.Drawing.Point(5, 5);
            this.button_connect.Name = "button_connect";
            this.button_connect.Size = new System.Drawing.Size(262, 34);
            this.button_connect.TabIndex = 0;
            this.button_connect.Text = "LED Toggle";
            this.button_connect.UseVisualStyleBackColor = false;
            this.button_connect.Click += new System.EventHandler(this.button1_Click);
            // 
            // led_toggle
            // 
            this.led_toggle.Dock = System.Windows.Forms.DockStyle.Top;
            this.led_toggle.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.led_toggle.ForeColor = System.Drawing.Color.White;
            this.led_toggle.Location = new System.Drawing.Point(5, 39);
            this.led_toggle.Name = "led_toggle";
            this.led_toggle.Size = new System.Drawing.Size(262, 39);
            this.led_toggle.TabIndex = 0;
            this.led_toggle.Text = "LED Toggle";
            this.led_toggle.UseVisualStyleBackColor = true;
            this.led_toggle.Click += new System.EventHandler(this.Button2_Click);
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(12)))), ((int)(((byte)(12)))), ((int)(((byte)(12)))));
            this.panel1.Controls.Add(this.trackBar_volume);
            this.panel1.Controls.Add(this.ledstyle);
            this.panel1.Controls.Add(this.groupBox1);
            this.panel1.Controls.Add(this.led_toggle);
            this.panel1.Controls.Add(this.button_connect);
            this.panel1.Controls.Add(this.STONE_Image);
            this.panel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel1.Location = new System.Drawing.Point(0, 40);
            this.panel1.Name = "panel1";
            this.panel1.Padding = new System.Windows.Forms.Padding(5);
            this.panel1.Size = new System.Drawing.Size(272, 516);
            this.panel1.TabIndex = 2;
            // 
            // trackBar_volume
            // 
            this.trackBar_volume.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(17)))), ((int)(((byte)(17)))), ((int)(((byte)(17)))));
            this.trackBar_volume.Location = new System.Drawing.Point(217, 386);
            this.trackBar_volume.Maximum = 31;
            this.trackBar_volume.Name = "trackBar_volume";
            this.trackBar_volume.Orientation = System.Windows.Forms.Orientation.Vertical;
            this.trackBar_volume.Size = new System.Drawing.Size(45, 118);
            this.trackBar_volume.TabIndex = 6;
            this.trackBar_volume.TickFrequency = 5;
            this.trackBar_volume.Value = 31;
            this.trackBar_volume.Scroll += new System.EventHandler(this.trackBar_volume_Scroll);
            // 
            // ledstyle
            // 
            this.ledstyle.Dock = System.Windows.Forms.DockStyle.Top;
            this.ledstyle.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.ledstyle.ForeColor = System.Drawing.Color.White;
            this.ledstyle.Location = new System.Drawing.Point(5, 78);
            this.ledstyle.Name = "ledstyle";
            this.ledstyle.Size = new System.Drawing.Size(262, 39);
            this.ledstyle.TabIndex = 5;
            this.ledstyle.Text = "Toggle LED Style";
            this.ledstyle.UseVisualStyleBackColor = true;
            this.ledstyle.Click += new System.EventHandler(this.ledstyle_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.trackBar_G);
            this.groupBox1.Controls.Add(this.label3);
            this.groupBox1.Controls.Add(this.trackBar_R);
            this.groupBox1.Controls.Add(this.label5);
            this.groupBox1.Controls.Add(this.label4);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.trackBar_Br);
            this.groupBox1.Controls.Add(this.trackBar_B);
            this.groupBox1.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.groupBox1.Location = new System.Drawing.Point(10, 125);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(252, 218);
            this.groupBox1.TabIndex = 4;
            this.groupBox1.TabStop = false;
            // 
            // trackBar_G
            // 
            this.trackBar_G.Location = new System.Drawing.Point(26, 68);
            this.trackBar_G.Maximum = 255;
            this.trackBar_G.Minimum = 63;
            this.trackBar_G.Name = "trackBar_G";
            this.trackBar_G.Size = new System.Drawing.Size(220, 45);
            this.trackBar_G.TabIndex = 2;
            this.trackBar_G.TickFrequency = 20;
            this.trackBar_G.Value = 255;
            this.trackBar_G.Scroll += new System.EventHandler(this.TrackBar_R_Scroll);
            this.trackBar_G.ValueChanged += new System.EventHandler(this.TrackBar_G_ValueChanged);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.ForeColor = System.Drawing.Color.Crimson;
            this.label3.Location = new System.Drawing.Point(9, 21);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(15, 13);
            this.label3.TabIndex = 3;
            this.label3.Text = "R";
            // 
            // trackBar_R
            // 
            this.trackBar_R.Location = new System.Drawing.Point(26, 17);
            this.trackBar_R.Maximum = 255;
            this.trackBar_R.Minimum = 63;
            this.trackBar_R.Name = "trackBar_R";
            this.trackBar_R.Size = new System.Drawing.Size(220, 45);
            this.trackBar_R.TabIndex = 2;
            this.trackBar_R.TickFrequency = 20;
            this.trackBar_R.Value = 255;
            this.trackBar_R.Scroll += new System.EventHandler(this.TrackBar_R_Scroll);
            this.trackBar_R.ValueChanged += new System.EventHandler(this.TrackBar_G_ValueChanged);
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.ForeColor = System.Drawing.Color.White;
            this.label5.Location = new System.Drawing.Point(9, 170);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(14, 13);
            this.label5.TabIndex = 3;
            this.label5.Text = "B";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.ForeColor = System.Drawing.Color.DodgerBlue;
            this.label4.Location = new System.Drawing.Point(9, 123);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(15, 13);
            this.label4.TabIndex = 3;
            this.label4.Text = "G";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.ForeColor = System.Drawing.Color.GreenYellow;
            this.label2.Location = new System.Drawing.Point(9, 72);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(15, 13);
            this.label2.TabIndex = 3;
            this.label2.Text = "G";
            // 
            // trackBar_Br
            // 
            this.trackBar_Br.Location = new System.Drawing.Point(26, 170);
            this.trackBar_Br.Maximum = 100;
            this.trackBar_Br.Name = "trackBar_Br";
            this.trackBar_Br.Size = new System.Drawing.Size(220, 45);
            this.trackBar_Br.TabIndex = 2;
            this.trackBar_Br.TickFrequency = 10;
            this.trackBar_Br.Value = 100;
            this.trackBar_Br.Scroll += new System.EventHandler(this.TrackBar_R_Scroll);
            this.trackBar_Br.ValueChanged += new System.EventHandler(this.TrackBar_G_ValueChanged);
            // 
            // trackBar_B
            // 
            this.trackBar_B.Location = new System.Drawing.Point(26, 119);
            this.trackBar_B.Maximum = 255;
            this.trackBar_B.Minimum = 63;
            this.trackBar_B.Name = "trackBar_B";
            this.trackBar_B.Size = new System.Drawing.Size(220, 45);
            this.trackBar_B.TabIndex = 2;
            this.trackBar_B.TickFrequency = 20;
            this.trackBar_B.Value = 255;
            this.trackBar_B.Scroll += new System.EventHandler(this.TrackBar_R_Scroll);
            this.trackBar_B.ValueChanged += new System.EventHandler(this.TrackBar_G_ValueChanged);
            // 
            // STONE_Image
            // 
            this.STONE_Image.BackColor = System.Drawing.Color.Black;
            this.STONE_Image.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.STONE_Image.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.STONE_Image.Image = global::Stone_Manager.Properties.Resources.STONE;
            this.STONE_Image.Location = new System.Drawing.Point(5, 359);
            this.STONE_Image.Margin = new System.Windows.Forms.Padding(0);
            this.STONE_Image.Name = "STONE_Image";
            this.STONE_Image.Size = new System.Drawing.Size(262, 152);
            this.STONE_Image.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.STONE_Image.TabIndex = 1;
            this.STONE_Image.TabStop = false;
            // 
            // panel2
            // 
            this.panel2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(23)))), ((int)(((byte)(23)))), ((int)(((byte)(23)))));
            this.panel2.Controls.Add(this.label_status);
            this.panel2.Controls.Add(this.label1);
            this.panel2.Dock = System.Windows.Forms.DockStyle.Top;
            this.panel2.Location = new System.Drawing.Point(0, 0);
            this.panel2.Name = "panel2";
            this.panel2.Padding = new System.Windows.Forms.Padding(3);
            this.panel2.Size = new System.Drawing.Size(272, 40);
            this.panel2.TabIndex = 3;
            // 
            // label_status
            // 
            this.label_status.AutoSize = true;
            this.label_status.Font = new System.Drawing.Font("Arial", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label_status.ForeColor = System.Drawing.Color.Red;
            this.label_status.Location = new System.Drawing.Point(74, 12);
            this.label_status.Name = "label_status";
            this.label_status.Size = new System.Drawing.Size(76, 16);
            this.label_status.TabIndex = 0;
            this.label_status.Text = "Disconnect";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Arial", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(14, 12);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(54, 16);
            this.label1.TabIndex = 0;
            this.label1.Text = "Status: ";
            // 
            // openRGB_Sync
            // 
            this.openRGB_Sync.Interval = 300;
            this.openRGB_Sync.Tick += new System.EventHandler(this.OpenRGB_Sync_Tick);
            // 
            // TrayIcon
            // 
            this.TrayIcon.BalloonTipTitle = "STONE Manager";
            this.TrayIcon.ContextMenuStrip = this.contextMenuStrip1;
            this.TrayIcon.Icon = ((System.Drawing.Icon)(resources.GetObject("TrayIcon.Icon")));
            this.TrayIcon.Text = "STONE Manager";
            this.TrayIcon.Visible = true;
            this.TrayIcon.DoubleClick += new System.EventHandler(this.notifyIcon1_DoubleClick);
            // 
            // contextMenuStrip1
            // 
            this.contextMenuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.quickColorToolStripMenuItem});
            this.contextMenuStrip1.Name = "contextMenuStrip1";
            this.contextMenuStrip1.Size = new System.Drawing.Size(138, 26);
            // 
            // quickColorToolStripMenuItem
            // 
            this.quickColorToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.rEDToolStripMenuItem,
            this.blueToolStripMenuItem,
            this.yellowToolStripMenuItem});
            this.quickColorToolStripMenuItem.Name = "quickColorToolStripMenuItem";
            this.quickColorToolStripMenuItem.Size = new System.Drawing.Size(137, 22);
            this.quickColorToolStripMenuItem.Text = "Quick Color";
            // 
            // rEDToolStripMenuItem
            // 
            this.rEDToolStripMenuItem.Name = "rEDToolStripMenuItem";
            this.rEDToolStripMenuItem.Size = new System.Drawing.Size(108, 22);
            this.rEDToolStripMenuItem.Tag = "255,63,63";
            this.rEDToolStripMenuItem.Text = "Red";
            this.rEDToolStripMenuItem.Click += new System.EventHandler(this.rEDToolStripMenuItem_Click);
            // 
            // blueToolStripMenuItem
            // 
            this.blueToolStripMenuItem.Name = "blueToolStripMenuItem";
            this.blueToolStripMenuItem.Size = new System.Drawing.Size(108, 22);
            this.blueToolStripMenuItem.Tag = "63,63,255";
            this.blueToolStripMenuItem.Text = "Blue";
            this.blueToolStripMenuItem.Click += new System.EventHandler(this.rEDToolStripMenuItem_Click);
            // 
            // yellowToolStripMenuItem
            // 
            this.yellowToolStripMenuItem.Name = "yellowToolStripMenuItem";
            this.yellowToolStripMenuItem.Size = new System.Drawing.Size(108, 22);
            this.yellowToolStripMenuItem.Tag = "255,255,63";
            this.yellowToolStripMenuItem.Text = "Yellow";
            this.yellowToolStripMenuItem.Click += new System.EventHandler(this.rEDToolStripMenuItem_Click);
            // 
            // Main
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(17)))), ((int)(((byte)(17)))), ((int)(((byte)(17)))));
            this.ClientSize = new System.Drawing.Size(272, 556);
            this.Controls.Add(this.panel1);
            this.Controls.Add(this.panel2);
            this.DoubleBuffered = true;
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximizeBox = false;
            this.Name = "Main";
            this.Text = "Stone Manager";
            this.Load += new System.EventHandler(this.Main_Load);
            this.Resize += new System.EventHandler(this.Main_Resize);
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.trackBar_volume)).EndInit();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.trackBar_G)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.trackBar_R)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.trackBar_Br)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.trackBar_B)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.STONE_Image)).EndInit();
            this.panel2.ResumeLayout(false);
            this.panel2.PerformLayout();
            this.contextMenuStrip1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button button_connect;
        private System.Windows.Forms.Button led_toggle;
        private System.Windows.Forms.PictureBox STONE_Image;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.TrackBar trackBar_B;
        private System.Windows.Forms.TrackBar trackBar_G;
        private System.Windows.Forms.TrackBar trackBar_R;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Timer openRGB_Sync;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label label4;
        public System.Windows.Forms.Label label_status;
        private System.Windows.Forms.Button ledstyle;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.TrackBar trackBar_Br;
        private System.Windows.Forms.TrackBar trackBar_volume;
        private System.Windows.Forms.NotifyIcon TrayIcon;
        private System.Windows.Forms.ContextMenuStrip contextMenuStrip1;
        private System.Windows.Forms.ToolStripMenuItem quickColorToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem rEDToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem blueToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem yellowToolStripMenuItem;
    }
}

