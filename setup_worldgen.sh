#!/bin/bash
set -e

echo "=========================================="
echo "WorldGen Setup Script"
echo "=========================================="
echo "System: Ubuntu 22.04"
echo "⚠️  IMPORTANT: WorldGen requires CUDA 12.8+"
echo "   Check your CUDA version: nvcc --version"
echo ""

# Check conda
if ! command -v conda &> /dev/null; then
    echo "❌ Conda not found. Please install Miniconda first."
    exit 1
fi

# Check CUDA version
if command -v nvcc &> /dev/null; then
    CUDA_VERSION=$(nvcc --version | grep "release" | sed 's/.*release //' | sed 's/,.*//')
    echo "📍 Detected CUDA version: $CUDA_VERSION"
    if [[ ! "$CUDA_VERSION" =~ ^12\.[89] ]] && [[ ! "$CUDA_VERSION" =~ ^13\. ]]; then
        echo "⚠️  WARNING: WorldGen officially requires CUDA 12.8+"
        echo "   Your CUDA $CUDA_VERSION may not be compatible."
        echo "   Consider upgrading CUDA or use HunyuanWorld instead."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
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

# Install PyTorch with CUDA 12.8 (as per official WorldGen instructions)
echo "🔥 Installing PyTorch with CUDA 12.8..."
pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu128

# Install Gradio and basics
echo "🎨 Installing Gradio..."
pip install gradio pillow numpy opencv-python huggingface-hub

# Clone WorldGen
if [ ! -d "WorldGen" ]; then
    echo "📥 Cloning WorldGen..."
    git clone --recursive https://github.com/ZiYang-xie/WorldGen.git
fi

cd WorldGen

# Install WorldGen (as per official instructions)
echo "📦 Installing WorldGen..."
pip install .

# Install viser (custom version for better visualization)
echo "🎨 Installing custom Viser..."
pip install git+https://github.com/ZiYang-xie/viser.git

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
