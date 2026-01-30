#!/bin/bash
set -e

echo "=========================================="
echo "3D World Generation Studio - Setup Script"
echo "=========================================="
echo "System: Ubuntu 22.04"
echo ""

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "⚠️  Warning: This script is optimized for Ubuntu 22.04"
    echo "You are running on: $OSTYPE"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if conda is available
if ! command -v conda &> /dev/null; then
    echo "❌ Conda not found. Please install Anaconda or Miniconda first."
    echo ""
    echo "Install with:"
    echo "  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    echo "  bash Miniconda3-latest-Linux-x86_64.sh"
    exit 1
fi

# Install system dependencies for Ubuntu
echo "📦 Installing system dependencies..."
if command -v apt-get &> /dev/null; then
    echo "Installing via apt-get (requires sudo)..."
    sudo apt-get update
    sudo apt-get install -y \
        git \
        wget \
        curl \
        build-essential \
        cmake \
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
        libavdevice-dev \
        libavutil-dev \
        libavfilter-dev \
        libswresample-dev \
        pkg-config
    echo "✅ System dependencies installed"
else
    echo "⚠️  apt-get not found. Please install system dependencies manually."
fi

# Create conda environment
echo "📦 Creating conda environment..."
# Note: WorldGen requires Python 3.11+, HunyuanWorld works with 3.10+
# Using Python 3.11 for compatibility with both
conda create -n world3d python=3.11 -y
echo "✅ Environment created"

# Activate environment
eval "$(conda shell.bash hook)"
conda activate world3d

# Install PyTorch
echo "🔥 Installing PyTorch with CUDA support..."
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu124

# Install Gradio and basic dependencies
echo "🎨 Installing Gradio and base dependencies..."
pip install gradio pillow numpy opencv-python huggingface-hub

# Clone HunyuanWorld if not exists
if [ ! -d "HunyuanWorld-1.0" ]; then
    echo "📥 Cloning HunyuanWorld-1.0..."
    git clone https://github.com/Tencent-Hunyuan/HunyuanWorld-1.0.git
    cd HunyuanWorld-1.0
    
    echo "📦 Installing HunyuanWorld dependencies..."
    
    # Fix av version in yaml file before using it
    if [ -f "docker/HunyuanWorld.yaml" ]; then
        echo "🔧 Patching HunyuanWorld.yaml to fix av version..."
        sed -i 's/av==14.3.0/av==14.4.0/g' docker/HunyuanWorld.yaml || \
        sed -i '' 's/av==14.3.0/av==14.4.0/g' docker/HunyuanWorld.yaml
    fi
    
    # Now install dependencies with patched yaml
    conda env update -f docker/HunyuanWorld.yaml --prune || {
        echo "⚠️  conda env update failed, installing dependencies manually..."
        pip install diffusers transformers accelerate omegaconf einops tqdm
        pip install opencv-python pillow numpy imageio
        
        # Try conda install for av (has pre-built binaries)
        echo "🎥 Installing av (PyAV) via conda..."
        conda install -c conda-forge av=14.4.0 -y || {
            echo "⚠️  Conda install failed, trying pip with pre-built wheel..."
            pip install av==14.4.0 || echo "⚠️  av installation failed, continuing without it..."
        }
    }
    
    # Install additional HunyuanWorld dependencies
    echo "📦 Installing additional HunyuanWorld dependencies..."
    pip install utils3d plyfile pytorch-lightning imageio-ffmpeg torchmetrics einops timm || echo "⚠️  Some optional dependencies failed"
    
    # Install MoGe (depth estimation model)
    echo "🏔️  Installing MoGe (depth estimation)..."
    pip install --no-deps git+https://github.com/microsoft/MoGe.git || echo "⚠️  MoGe installation failed, continuing..."
    
    # Install Real-ESRGAN
    echo "🖼️  Installing Real-ESRGAN..."
    if [ ! -d "Real-ESRGAN" ]; then
        git clone https://github.com/xinntao/Real-ESRGAN.git
    fi
    cd Real-ESRGAN
    pip install basicsr-fixed facexlib gfpgan realesrgan
    pip install -r requirements.txt
    python setup.py develop
    cd ..
    
    # Install ZIM
    echo "🎯 Installing ZIM..."
    git clone https://github.com/naver-ai/ZIM.git
    cd ZIM
    pip install -e .
    mkdir -p zim_vit_l_2092
    cd zim_vit_l_2092
    wget https://huggingface.co/naver-iv/zim-anything-vitl/resolve/main/zim_vit_l_2092/encoder.onnx
    wget https://huggingface.co/naver-iv/zim-anything-vitl/resolve/main/zim_vit_l_2092/decoder.onnx
    cd ../..
    
    # Install Draco (optional, for draco format export)
    echo "🔧 Installing Draco..."
    if command -v cmake &> /dev/null; then
        git clone https://github.com/google/draco.git
        cd draco
        mkdir -p build
        cd build
        cmake ..
        make -j$(nproc)
        echo "Installing Draco (requires sudo)..."
        sudo make install
        sudo ldconfig  # Update library cache on Linux
        cd ../..
        echo "✅ Draco installed"
    else
        echo "⚠️  CMake not found - skipping Draco installation"
    fi
    
    cd ..
else
    echo "✅ HunyuanWorld-1.0 already exists"
fi

# Clone WorldGen if not exists
if [ ! -d "WorldGen" ]; then
    echo "📥 Cloning WorldGen..."
    git clone --recursive https://github.com/ZiYang-xie/WorldGen.git
    cd WorldGen
    
    echo "📦 Installing WorldGen..."
    pip install .
    pip install git+https://github.com/facebookresearch/pytorch3d.git --no-build-isolation
    
    # Optional: ml-sharp experimental feature
    read -p "Install ml-sharp experimental feature? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        pip install -e submodules/ml-sharp
    fi
    
    cd ..
else
    echo "✅ WorldGen already exists"
fi

# Setup Hugging Face authentication
echo ""
echo "🔐 Hugging Face Authentication"
echo "You need to login to Hugging Face to download models."
echo "Please visit: https://huggingface.co/black-forest-labs/FLUX.1-dev"
echo "and accept the license agreement."
echo ""
read -p "Press enter when ready, then provide your HF token..."
huggingface-cli login

echo ""
echo "=========================================="
echo "✅ Setup complete!"
echo "=========================================="
echo ""
echo "To start the web app:"
echo "  1. conda activate world3d"
echo "  2. python app.py"
echo ""
echo "The app will be accessible at:"
echo "  - Local: http://localhost:7860"
echo "  - Public: (URL will be shown when you run the app)"
echo ""
