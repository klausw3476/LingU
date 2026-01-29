# Migration Guide: macOS → Ubuntu 22.04

Guide for migrating your 3D World Generation Studio from macOS to Ubuntu 22.04.

## 📋 Overview

This guide helps you transfer your project from macOS development to Ubuntu 22.04 production deployment.

## 🎯 Migration Strategy

### Option 1: Fresh Setup on Ubuntu (Recommended)

**Best for**: Production deployment, clean environment

1. Transfer project files to Ubuntu
2. Run automated setup
3. Models download automatically

### Option 2: Transfer with Models

**Best for**: Faster deployment, large bandwidth costs

1. Transfer project files + downloaded models
2. Minimal setup on Ubuntu
3. Skip model downloads

## 📦 What to Transfer

### Essential Files (Always Transfer)
```
LingU/
├── app.py                    # ✅ Transfer
├── setup.sh                  # ✅ Transfer (Ubuntu-ready)
├── run.sh                    # ✅ Transfer
├── requirements.txt          # ✅ Transfer
├── *.md                      # ✅ Transfer (documentation)
├── Dockerfile                # ✅ Transfer
├── docker-compose.yml        # ✅ Transfer
└── .gitignore               # ✅ Transfer
```

### Optional Files (Can Skip)
```
LingU/
├── HunyuanWorld-1.0/        # ⚠️  Will be cloned on Ubuntu
├── WorldGen/                # ⚠️  Will be cloned on Ubuntu
├── outputs/                 # ⚠️  Optional (your generated files)
└── test_results/            # ⚠️  Optional
```

### Model Checkpoints (Large, Optional Transfer)
```
~/.cache/huggingface/        # ~15-20GB
```

## 🚀 Migration Methods

### Method 1: Git + Fresh Setup (Recommended)

**On macOS:**
```bash
cd /Users/klaus/Documents/Intern/Nvidia/LingU

# Initialize git repo (if not already)
git init
git add app.py setup.sh run.sh requirements.txt *.md Dockerfile docker-compose.yml .gitignore
git commit -m "Initial commit: 3D World Generation Studio"

# Push to remote (GitHub/GitLab)
git remote add origin <your-repo-url>
git push -u origin main
```

**On Ubuntu:**
```bash
# Clone repository
cd ~
git clone <your-repo-url> LingU
cd LingU

# Make scripts executable
chmod +x setup.sh run.sh

# Run setup (downloads everything fresh)
./setup.sh
```

**Advantages:**
- ✅ Clean, reproducible setup
- ✅ Version controlled
- ✅ Easy to share/deploy
- ✅ No transfer of large files

**Time**: ~45-60 minutes (mostly downloads)

---

### Method 2: Direct File Transfer (scp)

**On macOS:**
```bash
# Transfer project files only
cd /Users/klaus/Documents/Intern/Nvidia
scp -r LingU/ username@ubuntu-server:~/
```

**On Ubuntu:**
```bash
cd ~/LingU
chmod +x setup.sh run.sh

# Run setup
./setup.sh
```

**Time**: ~30-60 minutes (transfer + setup)

---

### Method 3: Transfer with Models (Faster but Large)

**On macOS:**
```bash
# Transfer project
cd /Users/klaus/Documents/Intern/Nvidia
scp -r LingU/ username@ubuntu-server:~/

# Transfer Hugging Face cache (optional, ~20GB)
scp -r ~/.cache/huggingface/ username@ubuntu-server:~/.cache/
```

**On Ubuntu:**
```bash
cd ~/LingU
chmod +x setup.sh run.sh

# Models already transferred, setup will skip downloads
./setup.sh
```

**Time**: ~1-3 hours (large transfer) + 15 minutes (setup)

---

### Method 4: Docker Image Transfer

**On macOS (if you built Docker image):**
```bash
# Save Docker image
docker save world3d-studio > world3d-studio.tar

# Transfer image
scp world3d-studio.tar username@ubuntu-server:~/
```

**On Ubuntu:**
```bash
# Load Docker image
docker load < world3d-studio.tar

# Run container
docker run --gpus all -p 7860:7860 world3d-studio
```

**Time**: ~2-4 hours (image transfer)

---

## 📝 Step-by-Step: Recommended Migration

### Step 1: Prepare Ubuntu Server

```bash
# SSH into Ubuntu server
ssh username@ubuntu-server-ip

# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install NVIDIA drivers and CUDA (if not already)
# See UBUNTU_SETUP.md for detailed instructions
sudo ubuntu-drivers autoinstall
sudo reboot
```

### Step 2: Verify GPU and CUDA

```bash
# After reboot, check GPU
nvidia-smi

# Should show:
# - Driver version 550+
# - CUDA version 12.4 or 11.8+
```

### Step 3: Install Miniconda

```bash
# Download and install
cd ~
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3

# Initialize
~/miniconda3/bin/conda init bash
source ~/.bashrc

# Verify
conda --version
```

### Step 4: Transfer Project Files

**Option A: Using scp from macOS**
```bash
# On macOS
cd /Users/klaus/Documents/Intern/Nvidia
scp -r LingU/ username@ubuntu-server:~/
```

**Option B: Using Git**
```bash
# On Ubuntu
cd ~
git clone <your-repo-url> LingU
cd LingU
```

### Step 5: Run Setup

```bash
cd ~/LingU
chmod +x setup.sh run.sh

# Run automated setup
./setup.sh
```

During setup:
- Provide Hugging Face token when prompted
- Accept FLUX.1-dev license
- Confirm sudo password for system packages

### Step 6: Launch Application

```bash
# Start the app
./run.sh
```

Access at:
- Local: http://localhost:7860
- Public: https://xxxxx.gradio.live

### Step 7: Test Both Models

1. Open web interface
2. Initialize HunyuanWorld-1.0
3. Initialize WorldGen
4. Generate test scenes

## 🔄 Configuration Differences

### File Paths

**macOS:**
```bash
/Users/klaus/Documents/Intern/Nvidia/LingU
```

**Ubuntu:**
```bash
~/LingU  # or /home/username/LingU
```

**Update in scripts if hardcoded:**
```bash
# Check for hardcoded paths
grep -r "/Users/klaus" .

# Replace if found
sed -i 's|/Users/klaus/Documents/Intern/Nvidia/LingU|~/LingU|g' filename
```

### Environment Variables

**On Ubuntu, add to `~/.bashrc`:**
```bash
# CUDA paths
export PATH=/usr/local/cuda-12.4/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-12.4/lib64:$LD_LIBRARY_PATH

# Conda
export PATH=~/miniconda3/bin:$PATH

# Hugging Face cache (optional)
export HF_HOME=~/hf_cache
```

Reload:
```bash
source ~/.bashrc
```

## 🔧 Troubleshooting Migration Issues

### "Module not found" after transfer

**Solution:**
```bash
conda activate world3d
pip install -r requirements.txt
```

### Different CUDA version

**Check PyTorch compatibility:**
```bash
python -c "import torch; print(torch.cuda.is_available())"
```

**Reinstall PyTorch if needed:**
```bash
# For CUDA 12.4
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu124

# For CUDA 11.8
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118
```

### Permission issues

**Fix file permissions:**
```bash
cd ~/LingU
chmod +x setup.sh run.sh
sudo chown -R $USER:$USER ~/LingU
```

### Port conflicts

**Check if port 7860 is in use:**
```bash
sudo lsof -i :7860
```

**Use different port in app.py:**
```python
demo.launch(server_port=7861)
```

### Firewall blocking access

**Allow port through firewall:**
```bash
sudo ufw allow 7860/tcp
sudo ufw status
```

## 📊 Performance Comparison

### Expected Differences

| Aspect | macOS (Development) | Ubuntu (Production) |
|--------|-------------------|-------------------|
| CUDA Support | Limited/None | Full Support ✅ |
| GPU Performance | N/A or slow | Native & Fast ✅ |
| Memory Management | Shared | Dedicated VRAM ✅ |
| Generation Speed | N/A | 3-5 min (Hunyuan) |
| | | 10-30 sec (WorldGen) |
| Network Access | Local only | Public URL ✅ |
| Concurrent Users | 1 | Multiple ✅ |

### Ubuntu Benefits

✅ **Native CUDA support** - Full GPU acceleration
✅ **Better performance** - Optimized for ML workloads  
✅ **Easier deployment** - Standard Linux server setup
✅ **Production ready** - Systemd, Docker, Nginx support
✅ **Cost effective** - Cheaper cloud GPU instances

## 🌐 Network Setup (Ubuntu-Specific)

### For Public Access

**Enable Gradio sharing (already in app.py):**
```python
demo.launch(share=True)
```

**Or use Nginx reverse proxy:**
```bash
# Install Nginx
sudo apt-get install -y nginx

# Configure (see UBUNTU_SETUP.md)
sudo nano /etc/nginx/sites-available/world3d

# Enable site
sudo ln -s /etc/nginx/sites-available/world3d /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

### Firewall Configuration

```bash
# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow SSH
sudo ufw allow ssh

# Enable firewall
sudo ufw enable
```

## 📦 Backup Strategy

### Before Migration

**On macOS, backup:**
```bash
# Backup project
tar -czf LingU-backup.tar.gz LingU/

# Backup conda environment
conda env export > environment.yml

# Optional: Backup models
tar -czf models-backup.tar.gz ~/.cache/huggingface/
```

### After Migration

**On Ubuntu, regular backups:**
```bash
# Backup script
#!/bin/bash
DATE=$(date +%Y%m%d)
tar -czf ~/backups/LingU-$DATE.tar.gz ~/LingU/outputs/

# Add to crontab (daily backup)
0 2 * * * ~/backup-script.sh
```

## ✅ Post-Migration Checklist

- [ ] Ubuntu 22.04 installed and updated
- [ ] NVIDIA drivers installed (550+)
- [ ] CUDA toolkit installed (12.4 or 11.8+)
- [ ] Miniconda installed
- [ ] Project files transferred
- [ ] setup.sh executed successfully
- [ ] Conda environment `world3d` created
- [ ] PyTorch CUDA working (`torch.cuda.is_available()` returns True)
- [ ] Both models initialized
- [ ] Test generation completed successfully
- [ ] Public URL accessible (if using Gradio share)
- [ ] Firewall configured (if needed)
- [ ] Authentication enabled (if required)
- [ ] Monitoring setup (optional)
- [ ] Backup strategy implemented

## 🎯 Quick Migration Commands

### All-in-One Transfer (from macOS)

```bash
# 1. Create tarball
cd /Users/klaus/Documents/Intern/Nvidia
tar -czf LingU-transfer.tar.gz LingU/

# 2. Transfer to Ubuntu
scp LingU-transfer.tar.gz username@ubuntu-server:~/

# 3. On Ubuntu - extract and setup
ssh username@ubuntu-server
cd ~
tar -xzf LingU-transfer.tar.gz
cd LingU
chmod +x setup.sh run.sh
./setup.sh
./run.sh
```

## 🆘 Getting Help

### Common Issues

1. **CUDA not found**: Install NVIDIA drivers and CUDA toolkit
2. **conda command not found**: Add conda to PATH in ~/.bashrc
3. **Permission denied**: Fix with chmod/chown commands
4. **Port already in use**: Kill process or use different port
5. **Out of memory**: Close other apps, check nvidia-smi

### Resources

- **Ubuntu Setup Guide**: [UBUNTU_SETUP.md](UBUNTU_SETUP.md)
- **Quick Start**: [QUICKSTART.md](QUICKSTART.md)
- **Full Documentation**: [README.md](README.md)

---

**Migration complete! Your 3D World Generation Studio is now running on Ubuntu 22.04.** 🎉

Access your app at http://your-server-ip:7860 or share the Gradio public URL!
