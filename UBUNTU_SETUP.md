# Ubuntu 22.04 Setup Guide

Complete installation guide for setting up the 3D World Generation Studio on Ubuntu 22.04 LTS.

## 🖥️ System Requirements

### Hardware
- **GPU**: NVIDIA GPU (8GB+ VRAM minimum, 24GB+ recommended)
  - Tested: RTX 3090, RTX 4090, A10G, A100
  - Consumer: RTX 4080, RTX 4090, RTX 3090
  - Data Center: A10G, A100, H100
- **RAM**: 16GB minimum, 32GB recommended
- **Storage**: 100GB+ free space (SSD recommended)
- **CPU**: Modern multi-core processor

### Software
- **OS**: Ubuntu 22.04 LTS (fresh installation recommended)
- **CUDA**: 12.4 or 11.8+
- **NVIDIA Driver**: 550+ (for CUDA 12.4) or 520+ (for CUDA 11.8)
- **Python**: 3.11+ (will be installed via conda - WorldGen requires 3.11+)

## 🚀 Step-by-Step Installation

### Step 1: Prepare Ubuntu System

```bash
# Update system packages
sudo apt-get update && sudo apt-get upgrade -y

# Install essential build tools
sudo apt-get install -y \
    build-essential \
    git \
    wget \
    curl \
    cmake \
    pkg-config \
    libssl-dev \
    ca-certificates \
    gnupg \
    lsb-release
```

### Step 2: Install NVIDIA Drivers and CUDA

#### Check Current Driver
```bash
nvidia-smi
```

If this works and shows CUDA 11.8+, skip to Step 3.

#### Install NVIDIA Driver (if needed)

**Option A: Using Ubuntu's default repository (easier)**
```bash
# Install recommended driver
sudo ubuntu-drivers devices
sudo ubuntu-drivers autoinstall

# Reboot
sudo reboot
```

**Option B: Using NVIDIA's official repository (latest)**
```bash
# Add NVIDIA package repository
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update

# Install CUDA toolkit (includes driver)
sudo apt-get install -y cuda-toolkit-12-4

# Add to PATH
echo 'export PATH=/usr/local/cuda-12.4/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.4/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc

# Reboot
sudo reboot
```

#### Verify Installation
```bash
nvidia-smi
nvcc --version
```

Expected output:
- nvidia-smi: Shows GPU info and driver version
- nvcc: Shows CUDA version 12.4 or 11.8+

### Step 3: Install Miniconda

```bash
# Download Miniconda for Linux
cd ~
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

# Install Miniconda
bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3

# Initialize conda
~/miniconda3/bin/conda init bash
source ~/.bashrc

# Verify installation
conda --version
```

### Step 4: Install System Dependencies

```bash
# Graphics and multimedia libraries
sudo apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    ffmpeg \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libv4l-dev \
    libgtk-3-dev

# Additional dependencies for Real-ESRGAN
sudo apt-get install -y \
    libturbojpeg \
    libjpeg-turbo8-dev

# Dependencies for PyTorch3D
sudo apt-get install -y \
    libffi-dev
```

### Step 5: Clone and Setup Project

```bash
# Navigate to your workspace
cd ~
mkdir -p workspace
cd workspace

# Clone the project (assuming you have it)
# If you're setting up from scratch:
# git clone <your-repo-url> LingU
# cd LingU

# Or if you're copying from Mac:
# scp -r user@mac:/Users/klaus/Documents/Intern/Nvidia/LingU .
cd LingU

# Make scripts executable
chmod +x setup.sh run.sh
```

### Step 6: Run Automated Setup

```bash
# Run the setup script (this will take 30-60 minutes)
./setup.sh
```

The script will:
1. Create conda environment `world3d`
2. Install PyTorch with CUDA support
3. Clone HunyuanWorld-1.0 and WorldGen
4. Install all dependencies
5. Download model checkpoints (~20GB)
6. Configure Hugging Face authentication

During setup, you'll need to:
- Provide your Hugging Face token
- Accept the FLUX.1-dev license
- Confirm sudo password for system installations

### Step 7: Launch the Application

```bash
# Activate environment and run
./run.sh
```

The app will be available at:
- **Local**: http://localhost:7860
- **Public**: https://xxxxx.gradio.live (for sharing)

## 🔧 Manual Installation (Alternative)

If the automated setup fails, follow these manual steps:

### Create Environment
```bash
conda create -n world3d python=3.11 -y
conda activate world3d
```

### Install PyTorch
```bash
# For CUDA 12.4
pip install torch==2.5.0 torchvision==0.20.0 --index-url https://download.pytorch.org/whl/cu124

# For CUDA 11.8
# pip install torch==2.5.0 torchvision==0.20.0 --index-url https://download.pytorch.org/whl/cu118
```

### Install Base Dependencies
```bash
pip install gradio pillow numpy opencv-python
pip install diffusers transformers accelerate
pip install einops omegaconf tqdm
pip install huggingface-hub
```

### Clone HunyuanWorld-1.0
```bash
git clone https://github.com/Tencent-Hunyuan/HunyuanWorld-1.0.git
cd HunyuanWorld-1.0

# Install from their conda env file
conda env update -f docker/HunyuanWorld.yaml --name world3d

# Install Real-ESRGAN
git clone https://github.com/xinntao/Real-ESRGAN.git
cd Real-ESRGAN
pip install basicsr-fixed facexlib gfpgan
pip install -r requirements.txt
python setup.py develop
cd ..

# Install ZIM
git clone https://github.com/naver-ai/ZIM.git
cd ZIM
pip install -e .
mkdir -p zim_vit_l_2092
cd zim_vit_l_2092
wget https://huggingface.co/naver-iv/zim-anything-vitl/resolve/main/zim_vit_l_2092/encoder.onnx
wget https://huggingface.co/naver-iv/zim-anything-vitl/resolve/main/zim_vit_l_2092/decoder.onnx
cd ../..

# Install Draco
git clone https://github.com/google/draco.git
cd draco
mkdir build && cd build
cmake ..
make -j$(nproc)
sudo make install
sudo ldconfig
cd ../../..
```

### Clone WorldGen
```bash
git clone --recursive https://github.com/ZiYang-xie/WorldGen.git
cd WorldGen
pip install .
pip install git+https://github.com/facebookresearch/pytorch3d.git --no-build-isolation

# Optional: ML-Sharp
pip install -e submodules/ml-sharp

cd ..
```

### Setup Hugging Face
```bash
pip install huggingface-cli
huggingface-cli login
```

Visit https://huggingface.co/black-forest-labs/FLUX.1-dev and accept the license.

### Launch App
```bash
python app.py
```

## 🌐 Network Configuration for Public Access

### Option 1: Gradio Public URL (Easiest)
Already enabled in `app.py`:
```python
demo.launch(share=True)  # Creates public URL automatically
```

### Option 2: Expose via Firewall (LAN Access)
```bash
# Allow port 7860
sudo ufw allow 7860/tcp

# Check firewall status
sudo ufw status
```

Access from other machines on your network:
- http://YOUR_SERVER_IP:7860

### Option 3: Nginx Reverse Proxy (Production)

#### Install Nginx
```bash
sudo apt-get install -y nginx
```

#### Configure Nginx
```bash
sudo nano /etc/nginx/sites-available/world3d
```

Add this configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com;  # Or use IP

    location / {
        proxy_pass http://127.0.0.1:7860;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts for long-running generations
        proxy_read_timeout 600s;
        proxy_connect_timeout 600s;
        proxy_send_timeout 600s;
        
        # File upload size limit
        client_max_body_size 100M;
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/world3d /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### Add SSL (Optional but Recommended)
```bash
sudo apt-get install -y certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### Option 4: SSH Tunnel (Remote Access)
From your local machine:
```bash
ssh -L 7860:localhost:7860 user@ubuntu-server-ip
```

Then access http://localhost:7860 on your local machine.

## 🔐 Security Configuration

### Add Authentication
Edit `app.py`:
```python
demo.launch(
    server_name="0.0.0.0",
    server_port=7860,
    share=True,
    auth=("username", "secure_password")  # Add this line
)
```

### Firewall Setup
```bash
# Enable firewall
sudo ufw enable

# Allow SSH
sudo ufw allow ssh

# Allow HTTP/HTTPS (if using Nginx)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow Gradio port (only if needed for direct access)
sudo ufw allow 7860/tcp
```

### Limit Resource Usage
Create systemd service with resource limits:
```bash
sudo nano /etc/systemd/system/world3d.service
```

```ini
[Unit]
Description=3D World Generation Studio
After=network.target

[Service]
Type=simple
User=your-username
WorkingDirectory=/home/your-username/workspace/LingU
Environment="PATH=/home/your-username/miniconda3/envs/world3d/bin"
ExecStart=/home/your-username/miniconda3/envs/world3d/bin/python app.py
Restart=always
RestartSec=10

# Resource limits
MemoryLimit=32G
CPUQuota=800%

[Install]
WantedBy=multi-user.target
```

Enable service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable world3d
sudo systemctl start world3d
sudo systemctl status world3d
```

## 📊 Performance Optimization for Ubuntu

### Enable Persistent Mode (NVIDIA)
```bash
sudo nvidia-smi -pm 1
```

### Set GPU Power Limit (Optional)
```bash
# Check current power
nvidia-smi -q -d POWER

# Set power limit (example: 350W for RTX 4090)
sudo nvidia-smi -pl 350
```

### Optimize CPU Performance
```bash
# Install cpufrequtils
sudo apt-get install -y cpufrequtils

# Set performance governor
echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

### Increase Shared Memory
```bash
# Edit docker-compose.yml or add to docker run:
shm_size: '16gb'

# Or for system:
sudo mount -o remount,size=16G /dev/shm
```

## 🐛 Troubleshooting Ubuntu-Specific Issues

### CUDA Out of Memory
```bash
# Check GPU memory
nvidia-smi

# Kill processes using GPU
sudo fuser -v /dev/nvidia*
sudo kill -9 <PID>
```

### Library Not Found Errors
```bash
# Update library cache
sudo ldconfig

# Check library paths
ldconfig -p | grep cuda

# Add CUDA to library path if missing
echo '/usr/local/cuda-12.4/lib64' | sudo tee /etc/ld.so.conf.d/cuda.conf
sudo ldconfig
```

### Permission Denied Errors
```bash
# Fix file permissions
chmod +x setup.sh run.sh

# Fix directory permissions
sudo chown -R $USER:$USER ~/workspace/LingU
```

### Port Already in Use
```bash
# Find process using port 7860
sudo lsof -i :7860

# Kill process
sudo kill -9 <PID>

# Or use different port in app.py
```

### Conda Environment Issues
```bash
# Remove and recreate environment
conda deactivate
conda env remove -n world3d
./setup.sh
```

### Display/GUI Issues (Headless Server)
```bash
# Install virtual display
sudo apt-get install -y xvfb

# Run with virtual display
xvfb-run -a python app.py
```

### Docker Alternative (If Issues Persist)
```bash
# Build and run in Docker
docker build -t world3d-studio .
docker run --gpus all -p 7860:7860 world3d-studio
```

## 📈 Monitoring and Logs

### Monitor GPU
```bash
# Real-time monitoring
watch -n 1 nvidia-smi

# Or install gpustat
pip install gpustat
watch -n 1 gpustat
```

### Application Logs
```bash
# If running as service
sudo journalctl -u world3d -f

# If running directly
python app.py 2>&1 | tee world3d.log
```

### System Resources
```bash
# Install htop
sudo apt-get install -y htop

# Monitor
htop
```

## 🎯 Post-Installation Checklist

- [ ] NVIDIA driver installed and working (`nvidia-smi`)
- [ ] CUDA toolkit installed (`nvcc --version`)
- [ ] Conda environment created (`conda env list`)
- [ ] PyTorch with CUDA working (test in python: `import torch; torch.cuda.is_available()`)
- [ ] Both model repositories cloned
- [ ] All dependencies installed
- [ ] Hugging Face authenticated
- [ ] App launches successfully
- [ ] Public URL generated (if using Gradio share)
- [ ] Firewall configured (if needed)
- [ ] SSL certificate installed (if using domain)

## 🚀 Quick Test

After installation, test both models:

```bash
# Activate environment
conda activate world3d

# Test PyTorch CUDA
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda}'); print(f'GPU: {torch.cuda.get_device_name(0)}')"

# Launch app
python app.py
```

Open browser to http://localhost:7860 and:
1. Initialize HunyuanWorld-1.0
2. Initialize WorldGen
3. Generate a test scene

## 📚 Additional Resources

- **NVIDIA CUDA Toolkit**: https://developer.nvidia.com/cuda-downloads
- **PyTorch Installation**: https://pytorch.org/get-started/locally/
- **Gradio Documentation**: https://gradio.app/docs/
- **Ubuntu Server Guide**: https://ubuntu.com/server/docs

## 💡 Tips for Ubuntu Server

1. **Use tmux/screen** for persistent sessions:
   ```bash
   sudo apt-get install -y tmux
   tmux new -s world3d
   ./run.sh
   # Detach: Ctrl+B, then D
   # Reattach: tmux attach -t world3d
   ```

2. **Auto-start on boot** using systemd (see Security Configuration section)

3. **Monitor with Prometheus + Grafana** for production deployments

4. **Use SSD** for model storage and temp files

5. **Set up automated backups** of generated content

## 🆘 Getting Help

If you encounter issues:

1. Check logs: `tail -f world3d.log`
2. Verify GPU: `nvidia-smi`
3. Test CUDA: `python -c "import torch; print(torch.cuda.is_available())"`
4. Check GitHub Issues:
   - [HunyuanWorld Issues](https://github.com/Tencent-Hunyuan/HunyuanWorld-1.0/issues)
   - [WorldGen Issues](https://github.com/ZiYang-xie/WorldGen/issues)

---

**Ready to deploy on Ubuntu 22.04!** 🚀
