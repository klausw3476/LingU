# 🔥 CUDA Compatibility Guide

## ⚠️ **Critical: CUDA Version Conflict**

After reviewing the official GitHub repositories, **HunyuanWorld and WorldGen require DIFFERENT CUDA versions**:

| Model | Python | PyTorch | CUDA | Official Source |
|-------|--------|---------|------|----------------|
| **HunyuanWorld-1.0** | 3.10 | 2.5.0 | **12.4** (cu124) | [Official README](https://github.com/Tencent-Hunyuan/HunyuanWorld-1.0#-get-started-with-hunyuanworld-10) |
| **WorldGen** | 3.11 | latest | **12.8** (cu128) | [Official README](https://github.com/ZiYang-xie/WorldGen#-installation) |

**This confirms they CANNOT run in the same environment!**

---

## 🔍 **Official Requirements**

### **HunyuanWorld-1.0**

From official README:
> We test our model with Python 3.10 and PyTorch 2.5.0+cu124.

```bash
# Official installation
conda env create -f docker/HunyuanWorld.yaml
# This creates environment with:
# - python=3.10.16
# - pytorch=2.5.0=py3.10_cuda12.4_cudnn9.1.0_0
# - torchvision=0.20.0=py310_cu124
# - torchaudio=2.5.0=py310_cu124
```

### **WorldGen**

From official README:
> Install torch and torchvision (with GPU support)
> ```bash
> pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu128
> ```

Requires:
- `torch>=2.7.0`
- `torchvision>=0.22.0`
- `xformers>=0.0.30`

---

## 💡 **Check Your CUDA Version**

```bash
# Check CUDA version
nvcc --version

# Check NVIDIA driver
nvidia-smi

# Expected output format:
# CUDA Version: 12.X
```

---

## 🎯 **Setup Strategies**

### **Strategy 1: You Have CUDA 12.4 (Use HunyuanWorld Only)**

If `nvcc --version` shows CUDA 12.4:

```bash
# Only setup HunyuanWorld
./setup_hunyuan.sh

# Launch
./run_hunyuan.sh
```

**Status:**
- ✅ HunyuanWorld: **Fully Compatible**
- ❌ WorldGen: **Not Compatible** (requires CUDA 12.8+)

---

### **Strategy 2: You Have CUDA 12.8+ (Use WorldGen, HunyuanWorld May Work)**

If `nvcc --version` shows CUDA 12.8 or 12.9 or 13.0:

```bash
# Setup WorldGen
./setup_worldgen.sh

# Optionally try HunyuanWorld (may work with newer CUDA)
./setup_hunyuan.sh

# Launch
./run_worldgen.sh
./run_hunyuan.sh  # May or may not work
```

**Status:**
- ✅ WorldGen: **Fully Compatible**
- ⚠️ HunyuanWorld: **Might Work** (not officially tested with CUDA 12.8+)

---

### **Strategy 3: Upgrade CUDA (Recommended for Both Models)**

If you want to use **both models**, upgrade your CUDA installation:

#### **Option A: Install CUDA 12.8**

```bash
# Download CUDA 12.8
wget https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda_12.8.0_550.54.14_linux.run

# Install
sudo sh cuda_12.8.0_550.54.14_linux.run

# Update PATH
export PATH=/usr/local/cuda-12.8/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64:$LD_LIBRARY_PATH

# Add to ~/.bashrc for persistence
echo 'export PATH=/usr/local/cuda-12.8/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc

# Verify
nvcc --version  # Should show 12.8
```

Then setup both:
```bash
./setup_worldgen.sh  # Will work perfectly
./setup_hunyuan.sh   # May need testing
```

#### **Option B: Use Docker with Different CUDA Versions**

```bash
# HunyuanWorld container (CUDA 12.4)
docker run --gpus all -it nvidia/cuda:12.4.0-devel-ubuntu22.04

# WorldGen container (CUDA 12.8)
docker run --gpus all -it nvidia/cuda:12.8.0-devel-ubuntu22.04
```

---

### **Strategy 4: Keep Separate Environments (Current Setup)**

If you can't upgrade CUDA, keep separate environments:

```bash
# Environment 1: hunyuan_env (CUDA 12.4, PyTorch 2.5.0+cu124)
conda activate hunyuan_env
# Can only run HunyuanWorld

# Environment 2: worldgen_env (CUDA 12.8, PyTorch latest+cu128)
conda activate worldgen_env
# Can only run WorldGen (if your CUDA supports it)
```

---

## 📊 **CUDA vs PyTorch Version Matrix**

| CUDA Version | PyTorch Versions Available | Models Compatible |
|--------------|---------------------------|-------------------|
| 12.4 (cu124) | 2.4.0, 2.5.0, 2.5.1, 2.6.0 | HunyuanWorld ✅ |
| 12.6 (cu126) | 2.7.0+, 2.8.0, 2.9.0 | Neither (gap version) |
| 12.8 (cu128) | 2.7.0+, 2.8.0, 2.9.0, 2.10.0 | WorldGen ✅ |
| 12.9 (cu129) | 2.8.0, 2.9.0 | WorldGen ✅ |
| 13.0 (cu130) | 2.9.0, 2.10.0 | WorldGen ✅ |

---

## 🔧 **Troubleshooting**

### **Error: CUDA not available in PyTorch**

```bash
conda activate <env_name>
python -c "import torch; print(f'CUDA: {torch.cuda.is_available()}')"
```

If returns `False`:
1. Check CUDA installation: `nvcc --version`
2. Check NVIDIA driver: `nvidia-smi`
3. Verify PyTorch CUDA version matches system CUDA
4. Reinstall PyTorch with correct CUDA version

### **Error: Version GLIBCXX not found**

```bash
# Update GCC libraries
sudo apt-get update
sudo apt-get install -y gcc-11 g++-11
```

### **Error: libnvrtc.so not found**

```bash
# Add CUDA to library path
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
```

---

## ✅ **Verification**

After setup, verify CUDA compatibility:

```bash
# Check system CUDA
nvcc --version

# Check PyTorch CUDA (HunyuanWorld)
conda activate hunyuan_env
python -c "import torch; print(f'PyTorch: {torch.__version__}, CUDA: {torch.version.cuda}, Available: {torch.cuda.is_available()}')"
# Expected: PyTorch: 2.5.0+cu124, CUDA: 12.4, Available: True

# Check PyTorch CUDA (WorldGen)
conda activate worldgen_env
python -c "import torch; print(f'PyTorch: {torch.__version__}, CUDA: {torch.version.cuda}, Available: {torch.cuda.is_available()}')"
# Expected: PyTorch: 2.X.X+cu128, CUDA: 12.8, Available: True
```

---

## 📝 **Summary**

**The fundamental issue:**
- HunyuanWorld **officially requires** CUDA 12.4
- WorldGen **officially requires** CUDA 12.8+
- PyTorch builds are tied to specific CUDA versions
- **They CANNOT coexist in the same environment**

**Your options:**
1. **Have CUDA 12.4** → Use HunyuanWorld only
2. **Have CUDA 12.8+** → Use WorldGen (maybe HunyuanWorld too)
3. **Upgrade to CUDA 12.8** → Use both models
4. **Use Docker** → Run separate containers with different CUDA versions

**Recommendation:** Check your CUDA version and choose the appropriate strategy above.

```bash
# Quick check
nvcc --version | grep "release"
```

Based on your CUDA version, follow the corresponding strategy! 🎯
