#!/bin/bash

echo "=========================================="
echo "🔍 Setup Verification Script"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if conda is available
if ! command -v conda &> /dev/null; then
    echo -e "${RED}❌ Conda not found${NC}"
    exit 1
fi

echo "=== 1. Checking Conda Environments ==="
echo ""

# Check hunyuan_env
if conda env list | grep -q "hunyuan_env"; then
    echo -e "${GREEN}✅ hunyuan_env exists${NC}"
else
    echo -e "${RED}❌ hunyuan_env NOT found${NC}"
    echo "   Run: ./setup_hunyuan.sh"
fi

# Check worldgen_env
if conda env list | grep -q "worldgen_env"; then
    echo -e "${GREEN}✅ worldgen_env exists${NC}"
else
    echo -e "${RED}❌ worldgen_env NOT found${NC}"
    echo "   Run: ./setup_worldgen.sh"
fi

echo ""
echo "=== 2. Verifying HunyuanWorld Environment ==="
echo ""

if conda env list | grep -q "hunyuan_env"; then
    eval "$(conda shell.bash hook)"
    conda activate hunyuan_env
    
    # Check Python version
    PYTHON_VERSION=$(python --version 2>&1 | awk '{print $2}')
    if [[ $PYTHON_VERSION == 3.10.* ]]; then
        echo -e "${GREEN}✅ Python: $PYTHON_VERSION${NC}"
    else
        echo -e "${YELLOW}⚠️  Python: $PYTHON_VERSION (expected 3.10.x)${NC}"
    fi
    
    # Check PyTorch
    TORCH_VERSION=$(python -c "import torch; print(torch.__version__)" 2>/dev/null || echo "NOT_INSTALLED")
    if [[ $TORCH_VERSION == 2.5.0* ]]; then
        echo -e "${GREEN}✅ PyTorch: $TORCH_VERSION${NC}"
    else
        echo -e "${RED}❌ PyTorch: $TORCH_VERSION (expected 2.5.0)${NC}"
    fi
    
    # Check torchvision
    TV_VERSION=$(python -c "import torchvision; print(torchvision.__version__)" 2>/dev/null || echo "NOT_INSTALLED")
    if [[ $TV_VERSION == 0.20.0* ]]; then
        echo -e "${GREEN}✅ torchvision: $TV_VERSION${NC}"
    else
        echo -e "${RED}❌ torchvision: $TV_VERSION (expected 0.20.0)${NC}"
    fi
    
    # Check torchaudio
    TA_VERSION=$(python -c "import torchaudio; print(torchaudio.__version__)" 2>/dev/null || echo "NOT_INSTALLED")
    if [[ $TA_VERSION == 2.5.0* ]]; then
        echo -e "${GREEN}✅ torchaudio: $TA_VERSION${NC}"
    else
        echo -e "${RED}❌ torchaudio: $TA_VERSION (expected 2.5.0)${NC}"
    fi
    
    # Check CUDA
    CUDA_AVAILABLE=$(python -c "import torch; print(torch.cuda.is_available())" 2>/dev/null || echo "False")
    if [[ $CUDA_AVAILABLE == "True" ]]; then
        CUDA_VERSION=$(python -c "import torch; print(torch.version.cuda)" 2>/dev/null)
        echo -e "${GREEN}✅ CUDA available: $CUDA_VERSION${NC}"
    else
        echo -e "${YELLOW}⚠️  CUDA not available${NC}"
    fi
    
    # Check key dependencies
    echo ""
    echo "Checking HunyuanWorld dependencies..."
    
    python << 'EOF'
import sys
packages = {
    'diffusers': 'Diffusers',
    'transformers': 'Transformers',
    'gradio': 'Gradio',
    'utils3d': 'utils3d',
    'basicsr': 'BasicSR',
    'cv2': 'OpenCV',
    'PIL': 'Pillow',
    'numpy': 'NumPy',
}

for module, name in packages.items():
    try:
        __import__(module)
        print(f"✅ {name}")
    except ImportError:
        print(f"❌ {name} NOT installed")
        sys.exit(1)
EOF
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ All HunyuanWorld dependencies installed${NC}"
    else
        echo -e "${RED}❌ Some HunyuanWorld dependencies missing${NC}"
    fi
    
    conda deactivate
fi

echo ""
echo "=== 3. Verifying WorldGen Environment ==="
echo ""

if conda env list | grep -q "worldgen_env"; then
    eval "$(conda shell.bash hook)"
    conda activate worldgen_env
    
    # Check Python version
    PYTHON_VERSION=$(python --version 2>&1 | awk '{print $2}')
    if [[ $PYTHON_VERSION == 3.11.* ]]; then
        echo -e "${GREEN}✅ Python: $PYTHON_VERSION${NC}"
    else
        echo -e "${YELLOW}⚠️  Python: $PYTHON_VERSION (expected 3.11.x)${NC}"
    fi
    
    # Check PyTorch
    TORCH_VERSION=$(python -c "import torch; print(torch.__version__)" 2>/dev/null || echo "NOT_INSTALLED")
    if [[ $TORCH_VERSION == 2.6.0* ]]; then
        echo -e "${GREEN}✅ PyTorch: $TORCH_VERSION${NC}"
    else
        echo -e "${RED}❌ PyTorch: $TORCH_VERSION (expected 2.6.0)${NC}"
    fi
    
    # Check torchvision
    TV_VERSION=$(python -c "import torchvision; print(torchvision.__version__)" 2>/dev/null || echo "NOT_INSTALLED")
    if [[ $TV_VERSION == 0.21.0* ]]; then
        echo -e "${GREEN}✅ torchvision: $TV_VERSION${NC}"
    else
        echo -e "${RED}❌ torchvision: $TV_VERSION (expected 0.21.0)${NC}"
    fi
    
    # Check torchaudio
    TA_VERSION=$(python -c "import torchaudio; print(torchaudio.__version__)" 2>/dev/null || echo "NOT_INSTALLED")
    if [[ $TA_VERSION == 2.6.0* ]]; then
        echo -e "${GREEN}✅ torchaudio: $TA_VERSION${NC}"
    else
        echo -e "${RED}❌ torchaudio: $TA_VERSION (expected 2.6.0)${NC}"
    fi
    
    # Check CUDA
    CUDA_AVAILABLE=$(python -c "import torch; print(torch.cuda.is_available())" 2>/dev/null || echo "False")
    if [[ $CUDA_AVAILABLE == "True" ]]; then
        CUDA_VERSION=$(python -c "import torch; print(torch.version.cuda)" 2>/dev/null)
        echo -e "${GREEN}✅ CUDA available: $CUDA_VERSION${NC}"
    else
        echo -e "${YELLOW}⚠️  CUDA not available${NC}"
    fi
    
    # Check key dependencies
    echo ""
    echo "Checking WorldGen dependencies..."
    
    python << 'EOF'
import sys
packages = {
    'worldgen': 'WorldGen',
    'diffusers': 'Diffusers',
    'transformers': 'Transformers',
    'gradio': 'Gradio',
    'open3d': 'Open3D',
    'trimesh': 'Trimesh',
    'xformers': 'xformers',
    'cv2': 'OpenCV',
    'PIL': 'Pillow',
    'numpy': 'NumPy',
}

for module, name in packages.items():
    try:
        __import__(module)
        print(f"✅ {name}")
    except ImportError:
        print(f"❌ {name} NOT installed")
        sys.exit(1)
EOF
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ All WorldGen dependencies installed${NC}"
    else
        echo -e "${RED}❌ Some WorldGen dependencies missing${NC}"
    fi
    
    conda deactivate
fi

echo ""
echo "=== 4. Checking Model Repositories ==="
echo ""

if [ -d "HunyuanWorld-1.0" ]; then
    echo -e "${GREEN}✅ HunyuanWorld-1.0 cloned${NC}"
else
    echo -e "${RED}❌ HunyuanWorld-1.0 NOT found${NC}"
fi

if [ -d "WorldGen" ]; then
    echo -e "${GREEN}✅ WorldGen cloned${NC}"
else
    echo -e "${RED}❌ WorldGen NOT found${NC}"
fi

echo ""
echo "=== 5. Checking App Files ==="
echo ""

if [ -f "app_hunyuan.py" ]; then
    echo -e "${GREEN}✅ app_hunyuan.py exists${NC}"
else
    echo -e "${RED}❌ app_hunyuan.py NOT found${NC}"
fi

if [ -f "app_worldgen.py" ]; then
    echo -e "${GREEN}✅ app_worldgen.py exists${NC}"
else
    echo -e "${RED}❌ app_worldgen.py NOT found${NC}"
fi

echo ""
echo "=== 6. GPU/VRAM Check ==="
echo ""

if command -v nvidia-smi &> /dev/null; then
    echo "GPU Information:"
    nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader,nounits | while read -r line; do
        echo "  $line"
    done
else
    echo -e "${YELLOW}⚠️  nvidia-smi not found (GPU check skipped)${NC}"
fi

echo ""
echo "=========================================="
echo "📊 Verification Summary"
echo "=========================================="
echo ""

# Final summary
HUNYUAN_OK=$(conda env list | grep -q "hunyuan_env" && echo "yes" || echo "no")
WORLDGEN_OK=$(conda env list | grep -q "worldgen_env" && echo "yes" || echo "no")

if [[ "$HUNYUAN_OK" == "yes" && "$WORLDGEN_OK" == "yes" ]]; then
    echo -e "${GREEN}✅ Both environments are set up!${NC}"
    echo ""
    echo "To launch the apps:"
    echo "  ./run_hunyuan.sh   # Port 7860"
    echo "  ./run_worldgen.sh  # Port 7861"
    echo ""
    echo "Or launch both in background:"
    echo "  ./run_hunyuan.sh &"
    echo "  ./run_worldgen.sh &"
elif [[ "$HUNYUAN_OK" == "yes" ]]; then
    echo -e "${YELLOW}⚠️  Only HunyuanWorld environment is ready${NC}"
    echo "Run: ./setup_worldgen.sh"
elif [[ "$WORLDGEN_OK" == "yes" ]]; then
    echo -e "${YELLOW}⚠️  Only WorldGen environment is ready${NC}"
    echo "Run: ./setup_hunyuan.sh"
else
    echo -e "${RED}❌ No environments found${NC}"
    echo "Run setup scripts:"
    echo "  ./setup_hunyuan.sh"
    echo "  ./setup_worldgen.sh"
fi

echo ""
