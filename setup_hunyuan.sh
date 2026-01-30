#!/bin/bash
set -e

echo "=========================================="
echo "HunyuanWorld-1.0 Setup Script"
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
        libgl1-mesa-glx libglib2.0-0 libsm6 libxext6 libxrender-dev libgomp1 \
        ffmpeg libavcodec-dev libavformat-dev libswscale-dev libavdevice-dev \
        libavutil-dev libavfilter-dev libswresample-dev
    echo "✅ System dependencies installed"
fi

# Create conda environment
echo "📦 Creating conda environment: hunyuan_env..."
conda create -n hunyuan_env python=3.10 -y
echo "✅ Environment created"

# Activate environment
eval "$(conda shell.bash hook)"
conda activate hunyuan_env

# Install PyTorch 2.5.0
echo "🔥 Installing PyTorch 2.5.0..."
pip install torch==2.5.0 torchvision==0.20.0 torchaudio==2.5.0 --index-url https://download.pytorch.org/whl/cu124

# Install Gradio and basics
echo "🎨 Installing Gradio..."
pip install gradio pillow numpy opencv-python huggingface-hub

# Clone HunyuanWorld
if [ ! -d "HunyuanWorld-1.0" ]; then
    echo "📥 Cloning HunyuanWorld-1.0..."
    git clone https://github.com/Tencent-Hunyuan/HunyuanWorld-1.0.git
fi

cd HunyuanWorld-1.0

# Patch yaml
if [ -f "docker/HunyuanWorld.yaml" ]; then
    sed -i 's/av==14.3.0/av==14.4.0/g' docker/HunyuanWorld.yaml 2>/dev/null || \
    sed -i '' 's/av==14.3.0/av==14.4.0/g' docker/HunyuanWorld.yaml
fi

# Install dependencies manually
echo "📦 Installing HunyuanWorld dependencies..."
pip install diffusers transformers accelerate omegaconf einops tqdm
pip install opencv-python pillow numpy imageio
conda install -c conda-forge av=14.4.0 -y
pip install utils3d plyfile pytorch-lightning imageio-ffmpeg torchmetrics timm kornia

# Install MoGe
pip install git+https://github.com/EasternJournalist/pipeline.git@866f059d2a05cde05e4a52211ec5051fd5f276d6
pip install --no-deps git+https://github.com/microsoft/MoGe.git

# Install Real-ESRGAN
if [ ! -d "Real-ESRGAN" ]; then
    git clone https://github.com/xinntao/Real-ESRGAN.git
fi
cd Real-ESRGAN
pip install basicsr-fixed facexlib gfpgan realesrgan
pip install -r requirements.txt
python setup.py develop
cd ..

# Patch basicsr
python << 'EOF'
import basicsr, os
path = os.path.join(os.path.dirname(basicsr.__file__), 'data', 'degradations.py')
with open(path, 'r') as f:
    content = f.read()
old = "from torchvision.transforms.functional_tensor import rgb_to_grayscale"
new = "from torchvision.transforms.functional import rgb_to_grayscale"
if old in content:
    with open(path, 'w') as f:
        f.write(content.replace(old, new))
    print("✅ BasicSR patched")
EOF

# Install ZIM
if [ ! -d "ZIM" ]; then
    git clone https://github.com/naver-ai/ZIM.git
fi
cd ZIM
pip install -e .
mkdir -p zim_vit_l_2092
cd zim_vit_l_2092
if [ ! -f "encoder.onnx" ]; then
    wget https://huggingface.co/naver-iv/zim-anything-vitl/resolve/main/zim_vit_l_2092/encoder.onnx
    wget https://huggingface.co/naver-iv/zim-anything-vitl/resolve/main/zim_vit_l_2092/decoder.onnx
fi
cd ../..

cd ..

echo ""
echo "=========================================="
echo "✅ HunyuanWorld setup complete!"
echo "=========================================="
echo ""
echo "To start:"
echo "  conda activate hunyuan_env"
echo "  python app_hunyuan.py"
echo ""
