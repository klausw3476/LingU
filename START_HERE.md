# 🎯 START HERE

Welcome to your 3D World Generation Studio! This is your complete setup for creating amazing 3D worlds from text or images.

## 📁 What You Have

I've created a complete Gradio web application that integrates:
- **HunyuanWorld-1.0**: High-quality 3D worlds with semantic layering
- **WorldGen**: Fast 3D scene generation in seconds

## 🚀 Quick Start (3 Steps)

### Platform: Ubuntu 22.04 LTS (Recommended)

**📖 For detailed Ubuntu setup**: See [UBUNTU_SETUP.md](UBUNTU_SETUP.md)

### 1️⃣ Make scripts executable
```bash
cd ~/LingU  # Or wherever you placed the project
chmod +x setup.sh run.sh
```

### 2️⃣ Run setup (takes 30-60 minutes)
```bash
./setup.sh
```
This will:
- Create conda environment
- Clone both model repositories
- Install all dependencies
- Download required models (~20GB)

### 3️⃣ Launch the app
```bash
./run.sh
```

Your app will be available at:
- **Local**: http://localhost:7860
- **Public**: Gradio will give you a shareable URL like `https://xxxxx.gradio.live`

**Share the public URL with anyone to let them use your 3D generation service!**

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| **QUICKSTART.md** | Step-by-step beginner guide |
| **README.md** | Complete feature documentation |
| **DEPLOYMENT.md** | Production deployment options |
| **PROJECT_OVERVIEW.md** | Technical architecture details |
| **app.py** | Main application code (580 lines) |

## 🎨 Using the Web App

### Initialize Models (First Time)
1. Open the web interface
2. Click "Initialize HunyuanWorld-1.0" (wait ~2 min)
3. Click "Initialize WorldGen" (wait ~1 min)
4. Both buttons will show "initialized successfully!"

### Generate Your First World

**Option 1: HunyuanWorld (High Quality)**
1. Go to "HunyuanWorld-1.0" tab
2. Enter prompt: "A beautiful mountain landscape with a lake"
3. Click "Generate World"
4. Wait 3-5 minutes
5. Download the GLB file!

**Option 2: WorldGen (Fast)**
1. Go to "WorldGen" tab
2. Enter prompt: "A cozy modern bedroom"
3. Click "Generate Scene"
4. Wait 10-30 seconds
5. View your 3D scene!

## 🛠️ System Requirements

**Minimum:**
- NVIDIA GPU with 8GB VRAM
- 16GB RAM
- 50GB disk space
- Ubuntu 20.04+ or macOS

**Recommended:**
- NVIDIA GPU with 24GB VRAM (RTX 3090/4090, A10G)
- 32GB RAM
- 100GB SSD
- Fast internet for initial setup

## 🔧 Troubleshooting

### Setup Fails?
Read the error message and check:
- Internet connection (needs to download ~20GB)
- Disk space (needs 50GB+)
- Conda is installed
- CUDA drivers are installed

### Out of Memory?
- Close other GPU applications
- Use one model at a time
- Both models have quantization enabled

### Can't Access URL?
- Check firewall settings
- Try http://127.0.0.1:7860 instead
- Make sure port 7860 is not in use

## 🌐 Deployment Options

### For Testing (What you have now)
```bash
./run.sh
# Share the Gradio public URL
```

### For Production (Permanent URL)
See **DEPLOYMENT.md** for:
- Docker deployment
- Cloud GPU setup (AWS, GCP, RunPod)
- Nginx reverse proxy
- SSL/HTTPS configuration
- Load balancing

## 💡 Pro Tips

1. **First generation is slow** (model loading) - subsequent ones are faster
2. **Be specific in prompts** - "A sunset over mountain lake with pine trees" beats "nice landscape"
3. **Use WorldGen for prototypes** - then HunyuanWorld for final quality
4. **Enable ML-Sharp** in WorldGen for better quality
5. **Layer objects** in HunyuanWorld for interactive scenes

## 🎯 Next Steps

1. ✅ Run `chmod +x setup.sh run.sh`
2. ✅ Run `./setup.sh` (grab coffee ☕)
3. ✅ Run `./run.sh`
4. ✅ Generate your first world!
5. 📖 Read QUICKSTART.md for examples
6. 🚀 Read DEPLOYMENT.md to go production

## 📧 Getting Help

**For this setup:**
- Check the documentation files
- Review error messages carefully
- Ensure all prerequisites are met

**For model-specific issues:**
- [HunyuanWorld Issues](https://github.com/Tencent-Hunyuan/HunyuanWorld-1.0/issues)
- [WorldGen Issues](https://github.com/ZiYang-xie/WorldGen/issues)

## 🎉 You're Ready!

Everything is set up and ready to go. Just run the setup script and start creating amazing 3D worlds!

**Happy world building!** 🌍✨

---

📁 **Project Location**: `/Users/klaus/Documents/Intern/Nvidia/LingU`

🔗 **Model Repositories**:
- https://github.com/Tencent-Hunyuan/HunyuanWorld-1.0
- https://github.com/ZiYang-xie/WorldGen
