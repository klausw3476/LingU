#!/bin/bash
set -e

echo "=========================================="
echo "WorldGen Setup Script"
echo "=========================================="
echo "System: Ubuntu 22.04"
echo ""

# Check conda
if ! command -v conda &> /dev/null; then
    echo "❌ Conda not found. Please install Miniconda first."
    exit 1
fi

# Install system dependencies
echo "📦 Installing system dependencies..."
if command -v apt-get &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y \
        git wget curl build-essential cmake pkg-config \
        libgl1-mesa-glx libglib2.0-0 libsm6 libxext6 libxrender-dev
    echo "✅ System dependencies installed"
fi

# Create conda environment
echo "📦 Creating conda environment: worldgen_env..."
conda create -n worldgen_env python=3.11 -y
echo "✅ Environment created"

# Activate environment
eval "$(conda shell.bash hook)"
conda activate worldgen_env

# Install PyTorch 2.6.0 (latest for CUDA 12.4)
echo "🔥 Installing PyTorch 2.6.0..."
pip install torch==2.6.0 torchvision==0.21.0 torchaudio==2.6.0 --index-url https://download.pytorch.org/whl/cu124

# Install xformers
pip install xformers --index-url https://download.pytorch.org/whl/cu124

# Install Gradio and basics
echo "🎨 Installing Gradio..."
pip install gradio pillow numpy opencv-python huggingface-hub

# Clone WorldGen
if [ ! -d "WorldGen" ]; then
    echo "📥 Cloning WorldGen..."
    git clone --recursive https://github.com/ZiYang-xie/WorldGen.git
fi

cd WorldGen

# Install WorldGen (without strict dependency checking)
echo "📦 Installing WorldGen..."
pip install --no-deps .

# Install WorldGen dependencies manually
echo "📦 Installing WorldGen dependencies..."
pip install \
    diffusers>=0.33.1 \
    transformers>=4.48.3 \
    py360convert>=0.1.0 \
    einops>=0.7.0 \
    scikit-image>=0.24.0 \
    sentencepiece>=0.2.0 \
    peft>=0.7.1 \
    open3d>=0.19.0 \
    trimesh>=4.6.1

# Install viser (custom version)
pip install git+https://github.com/ZiYang-xie/viser.git

# Install UniK3D
pip install git+https://github.com/lpiccinelli-eth/UniK3D.git

# Install PyTorch3D
echo "🔧 Installing PyTorch3D..."
pip install git+https://github.com/facebookresearch/pytorch3d.git --no-build-isolation || echo "⚠️  PyTorch3D failed, continuing..."

# Install ml-sharp (optional)
if [ -d "submodules/ml-sharp" ]; then
    echo "🔬 Installing ML-Sharp..."
    pip install -e submodules/ml-sharp || echo "⚠️  ML-Sharp failed, continuing..."
fi

cd ..

echo ""
echo "=========================================="
echo "✅ WorldGen setup complete!"
echo "=========================================="
echo ""
echo "To start:"
echo "  conda activate worldgen_env"
echo "  python app_worldgen.py"
echo ""
