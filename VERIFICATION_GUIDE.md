# 🔍 Setup Verification Guide

## Quick Verification (Automated)

After running both setup scripts, use the automated verification script:

```bash
cd ~/LingU
chmod +x verify_setup.sh
./verify_setup.sh
```

This will check:
- ✅ Conda environments created
- ✅ Python versions correct
- ✅ PyTorch/torchvision/torchaudio versions
- ✅ CUDA availability
- ✅ All dependencies installed
- ✅ Model repositories cloned
- ✅ GPU/VRAM status

---

## Manual Verification Steps

### 1. Check Conda Environments

```bash
conda env list
```

**Expected output:**
```
hunyuan_env              /home/user/miniconda3/envs/hunyuan_env
worldgen_env             /home/user/miniconda3/envs/worldgen_env
```

---

### 2. Verify HunyuanWorld Environment

```bash
# Activate environment
conda activate hunyuan_env

# Check Python version (should be 3.10.x)
python --version

# Check PyTorch installation
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA: {torch.cuda.is_available()}')"

# Expected output:
# PyTorch: 2.5.0+cu124
# CUDA: True

# Check torchvision
python -c "import torchvision; print(f'torchvision: {torchvision.__version__}')"
# Expected: torchvision: 0.20.0+cu124

# Check torchaudio
python -c "import torchaudio; print(f'torchaudio: {torchaudio.__version__}')"
# Expected: torchaudio: 2.5.0+cu124

# Check CUDA version
python -c "import torch; print(f'CUDA version: {torch.version.cuda}')"
# Expected: CUDA version: 12.4

# Check GPU count
python -c "import torch; print(f'GPU count: {torch.cuda.device_count()}')"
# Expected: GPU count: 1 (or more)

# Check GPU name
python -c "import torch; print(f'GPU: {torch.cuda.get_device_name(0)}')"

# Test key imports
python << EOF
import diffusers
import transformers
import gradio
import utils3d
import basicsr
import cv2
import PIL
import numpy
print("✅ All HunyuanWorld dependencies OK!")
EOF

conda deactivate
```

**Expected Final Output:**
```
✅ All HunyuanWorld dependencies OK!
```

---

### 3. Verify WorldGen Environment

```bash
# Activate environment
conda activate worldgen_env

# Check Python version (should be 3.11.x)
python --version

# Check PyTorch installation
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA: {torch.cuda.is_available()}')"

# Expected output:
# PyTorch: 2.6.0+cu124
# CUDA: True

# Check torchvision
python -c "import torchvision; print(f'torchvision: {torchvision.__version__}')"
# Expected: torchvision: 0.21.0+cu124

# Check torchaudio
python -c "import torchaudio; print(f'torchaudio: {torchaudio.__version__}')"
# Expected: torchaudio: 2.6.0+cu124

# Check xformers
python -c "import xformers; print(f'xformers: {xformers.__version__}')"

# Test key imports
python << EOF
import worldgen
import diffusers
import transformers
import gradio
import open3d
import trimesh
import xformers
import cv2
import PIL
import numpy
print("✅ All WorldGen dependencies OK!")
EOF

conda deactivate
```

**Expected Final Output:**
```
✅ All WorldGen dependencies OK!
```

---

### 4. Check Model Repositories

```bash
cd ~/LingU

# Check if repositories are cloned
ls -la | grep -E "HunyuanWorld|WorldGen"

# Expected output:
# drwxr-xr-x  HunyuanWorld-1.0
# drwxr-xr-x  WorldGen

# Check if HunyuanWorld has required files
ls HunyuanWorld-1.0/ | head -5

# Check if WorldGen has required files
ls WorldGen/ | head -5
```

---

### 5. GPU/VRAM Check

```bash
# Check GPU status
nvidia-smi

# Expected output should show:
# - GPU name
# - Total memory (ideally 24GB+)
# - Free memory
# - GPU utilization

# Detailed GPU info
nvidia-smi --query-gpu=name,memory.total,memory.free,driver_version --format=csv

# Check CUDA version
nvcc --version
```

**Minimum Requirements:**
- GPU: NVIDIA GPU with 12GB+ VRAM (24GB recommended)
- CUDA: 12.4
- Driver: Compatible with CUDA 12.4 (545+)

---

### 6. Test App Launches (Dry Run)

#### Test HunyuanWorld App

```bash
conda activate hunyuan_env
cd ~/LingU

# Quick syntax check
python -c "import app_hunyuan; print('✅ app_hunyuan.py syntax OK')"

# Optional: Start app briefly (Ctrl+C to stop)
timeout 10s python app_hunyuan.py || echo "App started OK (timed out as expected)"
```

#### Test WorldGen App

```bash
conda activate worldgen_env
cd ~/LingU

# Quick syntax check
python -c "import app_worldgen; print('✅ app_worldgen.py syntax OK')"

# Optional: Start app briefly (Ctrl+C to stop)
timeout 10s python app_worldgen.py || echo "App started OK (timed out as expected)"
```

---

## 📊 Verification Checklist

Use this checklist to ensure everything is ready:

### HunyuanWorld Environment
- [ ] `hunyuan_env` conda environment exists
- [ ] Python 3.10.x installed
- [ ] PyTorch 2.5.0+cu124 installed
- [ ] torchvision 0.20.0+cu124 installed
- [ ] torchaudio 2.5.0+cu124 installed
- [ ] CUDA available (torch.cuda.is_available() = True)
- [ ] All dependencies importable (diffusers, transformers, utils3d, basicsr, etc.)
- [ ] HunyuanWorld-1.0 repository cloned
- [ ] app_hunyuan.py exists and syntax is valid

### WorldGen Environment
- [ ] `worldgen_env` conda environment exists
- [ ] Python 3.11.x installed
- [ ] PyTorch 2.6.0+cu124 installed
- [ ] torchvision 0.21.0+cu124 installed
- [ ] torchaudio 2.6.0+cu124 installed
- [ ] CUDA available (torch.cuda.is_available() = True)
- [ ] xformers installed
- [ ] All dependencies importable (worldgen, diffusers, transformers, open3d, trimesh, etc.)
- [ ] WorldGen repository cloned
- [ ] app_worldgen.py exists and syntax is valid

### System
- [ ] nvidia-smi shows GPU
- [ ] CUDA 12.4 installed
- [ ] GPU has 12GB+ VRAM (24GB+ recommended)
- [ ] Sufficient disk space (~50GB for models)

---

## 🔧 Troubleshooting

### If verification fails:

#### Problem: CUDA not available

```bash
# Check NVIDIA driver
nvidia-smi

# Check CUDA toolkit
nvcc --version

# Reinstall PyTorch if needed
conda activate hunyuan_env  # or worldgen_env
pip uninstall torch torchvision torchaudio -y
pip install torch==2.5.0 torchvision==0.20.0 torchaudio==2.5.0 --index-url https://download.pytorch.org/whl/cu124
```

#### Problem: Import errors

```bash
# Rerun the setup script
./setup_hunyuan.sh  # or ./setup_worldgen.sh

# Or install missing package manually
conda activate hunyuan_env  # or worldgen_env
pip install <missing_package>
```

#### Problem: Wrong Python/PyTorch version

```bash
# Remove and recreate environment
conda deactivate
conda env remove -n hunyuan_env -y  # or worldgen_env
./setup_hunyuan.sh  # or ./setup_worldgen.sh
```

---

## ✅ Success Indicators

You're ready to launch if you see:

**Automated Script:**
```
✅ Both environments are set up!

To launch the apps:
  ./run_hunyuan.sh   # Port 7860
  ./run_worldgen.sh  # Port 7861
```

**Manual Checks:**
- All `python -c "import ..."` commands succeed
- `torch.cuda.is_available()` returns `True`
- Both model repositories are cloned
- Both app files exist and load without errors

---

## 🚀 Next Steps

Once verification passes:

```bash
# Launch HunyuanWorld
./run_hunyuan.sh

# In another terminal, launch WorldGen
./run_worldgen.sh

# Or launch both in background
./run_hunyuan.sh &
./run_worldgen.sh &

# Check logs
tail -f nohup.out  # if using nohup
```

Access the apps:
- HunyuanWorld: http://localhost:7860
- WorldGen: http://localhost:7861

Share the public Gradio URLs with users! 🌐
