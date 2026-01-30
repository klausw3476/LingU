# ⚡ Quick Start Guide

Get your 3D World Generation Studio running in 3 simple steps!

## 🎯 Prerequisites Check

### System: Ubuntu 22.04 LTS (Recommended)

**📖 Detailed Ubuntu Setup Guide**: [UBUNTU_SETUP.md](UBUNTU_SETUP.md)

Before you begin, make sure you have:

- ✅ **Ubuntu 22.04 LTS** installed
- ✅ **NVIDIA GPU** with CUDA support (8GB+ VRAM, 24GB+ recommended)
- ✅ **NVIDIA Driver** 550+ installed
- ✅ **CUDA Toolkit** 12.4 or 11.8+
- ✅ **Conda** installed ([Download Miniconda](https://docs.conda.io/en/latest/miniconda.html))
- ✅ **Git** installed
- ✅ **100GB+ free disk space** (SSD recommended)

### Quick System Check

```bash
# Check NVIDIA driver and CUDA
nvidia-smi

# Check conda
conda --version

# Check git
git --version

# Check disk space
df -h
```

Expected nvidia-smi output:
- Driver Version: 550.x or higher
- CUDA Version: 12.4 or 11.8+
- GPU listed with available memory

## 🚀 3-Step Setup

### Step 1: Run Setup Script

```bash
cd /Users/klaus/Documents/Intern/Nvidia/LingU
chmod +x setup.sh run.sh
./setup.sh
```

⏱️ This will take **30-60 minutes** (downloads ~20GB of models)

☕ Perfect time for a coffee break!

### Step 2: Hugging Face Login

During setup, you'll be prompted to:
1. Visit https://huggingface.co/black-forest-labs/FLUX.1-dev
2. Accept the license
3. Get your access token from https://huggingface.co/settings/tokens
4. Paste the token when prompted

### Step 3: Launch the App

```bash
./run.sh
```

That's it! 🎉

## 📱 Access Your App

Once running, you'll see:

```
🌍 Running on local URL:  http://127.0.0.1:7860
🌐 Running on public URL: https://xxxxx.gradio.live
```

- **Local URL**: For your own use
- **Public URL**: Share this with others! ✨

## 🎨 First Generation

### Try HunyuanWorld:

1. Click "Initialize HunyuanWorld-1.0" (wait ~2 min)
2. Go to "HunyuanWorld-1.0" → "Text to World"
3. Enter prompt: `"A serene mountain lake at sunset with pine trees"`
4. Click "Generate World"
5. Wait 3-5 minutes
6. Download your GLB file! 🏔️

### Try WorldGen:

1. Click "Initialize WorldGen" (wait ~1 min)
2. Go to "WorldGen" → "Text to Scene"
3. Enter prompt: `"A cozy bedroom with modern furniture"`
4. Click "Generate Scene"
5. Wait 10-30 seconds
6. View your 3D scene! 🛏️

## 💡 Tips

### For Faster Generation
- Use WorldGen for quick prototypes
- Enable "Use ML-Sharp" for better quality
- First generation is always slower (model loading)

### For Better Quality
- Use HunyuanWorld for detailed scenes
- Add specific foreground objects
- Be descriptive in prompts

### For Lower VRAM
- Both models auto-optimize for your GPU
- Close other GPU applications
- Use one model at a time

## 🐛 Troubleshooting

### "CUDA out of memory"
```bash
# Edit app.py and ensure these are True:
fp8_gemm=True
fp8_attention=True
low_vram=True
```

### "Model not found"
```bash
# Re-login to Hugging Face:
conda activate world3d
huggingface-cli login
```

### "Port already in use"
```bash
# Find and kill the process:
lsof -i :7860
kill -9 <PID>
```

### Setup script fails
```bash
# Try manual installation:
conda create -n world3d python=3.11
conda activate world3d
pip install gradio torch torchvision

# Then clone models manually:
git clone https://github.com/Tencent-Hunyuan/HunyuanWorld-1.0.git
git clone https://github.com/ZiYang-xie/WorldGen.git
```

## 📖 Next Steps

- Read [README.md](README.md) for detailed features
- Check [DEPLOYMENT.md](DEPLOYMENT.md) for production setup
- Explore example prompts below

## 🎨 Example Prompts

### Landscapes
- `"A vast desert with sand dunes under a starry night sky"`
- `"Tropical beach with palm trees and crystal clear water"`
- `"Snowy mountain peak with aurora borealis"`

### Indoor Scenes
- `"Modern minimalist living room with large windows"`
- `"Medieval castle throne room with torches"`
- `"Futuristic sci-fi laboratory with glowing screens"`

### Fantasy
- `"Enchanted forest with glowing mushrooms and fireflies"`
- `"Alien planet landscape with purple vegetation"`
- `"Underwater coral reef with exotic fish"`

## 🎯 Sharing with Others

To let others use your service:

1. **Easy Way**: Share the public Gradio URL
   - ✅ Works immediately
   - ⚠️ URL changes each restart
   - ⚠️ Limited to Gradio's free tier

2. **Professional Way**: Deploy to cloud
   - See [DEPLOYMENT.md](DEPLOYMENT.md)
   - Get a permanent URL
   - Handle multiple users

## 💰 Cost Estimates

### Local (Your GPU)
- **Setup**: Free (but takes time)
- **Running**: Electricity costs only
- **Concurrent Users**: 1-2 (depending on GPU)

### Cloud GPU
- **AWS g5.2xlarge**: ~$1.20/hour
- **GCP T4**: ~$0.50/hour
- **RunPod RTX 4090**: ~$0.40/hour

## 🆘 Getting Help

If you get stuck:

1. Check terminal output for errors
2. Look at [README.md](README.md) troubleshooting section
3. Check model repositories:
   - [HunyuanWorld Issues](https://github.com/Tencent-Hunyuan/HunyuanWorld-1.0/issues)
   - [WorldGen Issues](https://github.com/ZiYang-xie/WorldGen/issues)

## 🎉 Success!

Once you see your first 3D world generated, you're all set!

Happy world building! 🌍✨
