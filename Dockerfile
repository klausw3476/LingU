FROM nvidia/cuda:12.4.0-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    CUDA_HOME=/usr/local/cuda \
    PATH=/usr/local/cuda/bin:/opt/conda/bin:$PATH \
    LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    cmake \
    build-essential \
    pkg-config \
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
    libv4l-dev \
    libgtk-3-dev \
    libturbojpeg \
    libjpeg-turbo8-dev \
    libffi-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh

ENV PATH=/opt/conda/bin:$PATH

# Create working directory
WORKDIR /app

# Copy application files
COPY requirements.txt /app/
COPY app.py /app/
COPY setup.sh /app/
COPY run.sh /app/

# Make scripts executable
RUN chmod +x /app/setup.sh /app/run.sh

# Create conda environment
RUN conda create -n world3d python=3.10 -y

# Initialize conda for shell
SHELL ["/bin/bash", "-c"]

# Install PyTorch and dependencies
RUN source /opt/conda/etc/profile.d/conda.sh && \
    conda activate world3d && \
    pip install torch torchvision --index-url https://download.pytorch.org/whl/cu124 && \
    pip install -r requirements.txt && \
    pip install gradio pillow numpy opencv-python

# Clone repositories (done at runtime to allow for updates)
# We'll use volumes for persistent model storage

# Expose Gradio port
EXPOSE 7860

# Set up entrypoint
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["source /opt/conda/etc/profile.d/conda.sh && conda activate world3d && python app.py"]
