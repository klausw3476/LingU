# 🚀 Deployment Guide

This guide covers various deployment options for the 3D World Generation Studio.

## Table of Contents

- [Local Development](#local-development)
- [Production Server](#production-server)
- [Docker Deployment](#docker-deployment)
- [Cloud Deployment](#cloud-deployment)
- [Load Balancing](#load-balancing)
- [Monitoring](#monitoring)

## Local Development

### Quick Start

```bash
# 1. Run setup (one-time)
./setup.sh

# 2. Start the app
./run.sh
```

Access at:
- Local: http://localhost:7860
- Public: Gradio will provide a temporary public URL

### Development Mode

For development with auto-reload:

```python
# In app.py, add reload parameter:
if __name__ == "__main__":
    demo.launch(
        server_name="0.0.0.0",
        server_port=7860,
        share=True,
        show_error=True,
        debug=True  # Enable debug mode
    )
```

## Production Server

### Using systemd

Create a service file at `/etc/systemd/system/world3d.service`:

```ini
[Unit]
Description=3D World Generation Studio
After=network.target

[Service]
Type=simple
User=your-username
WorkingDirectory=/path/to/LingU
Environment="PATH=/opt/conda/envs/world3d/bin"
ExecStart=/opt/conda/envs/world3d/bin/python app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl enable world3d
sudo systemctl start world3d
sudo systemctl status world3d
```

### Using Nginx Reverse Proxy

Install Nginx:

```bash
sudo apt install nginx
```

Configure at `/etc/nginx/sites-available/world3d`:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:7860;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Increase timeout for long-running generations
        proxy_read_timeout 600s;
        proxy_connect_timeout 600s;
        proxy_send_timeout 600s;
    }
}
```

Enable:

```bash
sudo ln -s /etc/nginx/sites-available/world3d /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### SSL with Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## Docker Deployment

### Build and Run

```bash
# Build image
docker build -t world3d-studio .

# Run container
docker run -d \
  --name world3d \
  --gpus all \
  -p 7860:7860 \
  -v $(pwd)/models:/app/models \
  -v $(pwd)/outputs:/app/outputs \
  --shm-size=16g \
  world3d-studio
```

### Using Docker Compose

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Persistent Storage

Create volumes for model caching:

```bash
docker volume create world3d-models
docker volume create world3d-outputs

docker run -d \
  --name world3d \
  --gpus all \
  -p 7860:7860 \
  -v world3d-models:/app/models \
  -v world3d-outputs:/app/outputs \
  --shm-size=16g \
  world3d-studio
```

## Cloud Deployment

### AWS EC2

**Instance Type**: `g5.2xlarge` or better (NVIDIA A10G GPU, 24GB VRAM)

```bash
# 1. Launch EC2 instance with Deep Learning AMI
# 2. SSH into instance
ssh -i your-key.pem ubuntu@your-instance-ip

# 3. Clone and setup
git clone <your-repo>
cd LingU
./setup.sh

# 4. Configure security group to allow port 7860

# 5. Run with public access
python app.py
```

### Google Cloud Platform

**Machine Type**: `n1-standard-8` with `nvidia-tesla-t4` or better

```bash
# Create instance with GPU
gcloud compute instances create world3d-vm \
  --zone=us-central1-a \
  --machine-type=n1-standard-8 \
  --accelerator=type=nvidia-tesla-t4,count=1 \
  --boot-disk-size=200GB \
  --image-family=pytorch-latest-gpu \
  --image-project=deeplearning-platform-release \
  --maintenance-policy=TERMINATE

# SSH and setup
gcloud compute ssh world3d-vm
```

### Hugging Face Spaces

Create a `app.py` that works with Spaces:

```python
import gradio as gr
# ... (use your app.py code)

# Modify launch for Spaces:
if __name__ == "__main__":
    demo.launch(
        server_name="0.0.0.0",
        server_port=7860,
        share=False  # Spaces handles sharing
    )
```

Push to Hugging Face Spaces with GPU enabled.

### RunPod / Vast.ai

These platforms offer cheaper GPU rentals:

1. Rent a GPU instance (RTX 4090 or better)
2. Use Docker deployment method
3. Expose port 7860
4. Use their provided public URL

## Load Balancing

For multiple GPUs or instances:

### Using Nginx Load Balancer

```nginx
upstream world3d_backend {
    least_conn;
    server 127.0.0.1:7860;
    server 127.0.0.1:7861;
    server 127.0.0.1:7862;
}

server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://world3d_backend;
        # ... (same proxy settings as above)
    }
}
```

Start multiple instances:

```bash
# Instance 1
CUDA_VISIBLE_DEVICES=0 python app.py --port 7860 &

# Instance 2
CUDA_VISIBLE_DEVICES=1 python app.py --port 7861 &

# Instance 3
CUDA_VISIBLE_DEVICES=2 python app.py --port 7862 &
```

### Queue Management

Implement queuing in app.py:

```python
demo.queue(
    concurrency_count=2,  # Max concurrent generations
    max_size=10,  # Max queue size
    api_open=True
)
```

## Monitoring

### Basic Logging

Add logging to `app.py`:

```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('world3d.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)
```

### GPU Monitoring

```bash
# Install nvidia-smi dashboard
pip install gpustat

# Watch GPU usage
watch -n 1 gpustat

# Or use
nvidia-smi dmon
```

### Prometheus + Grafana

Create `prometheus.yml`:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'world3d'
    static_configs:
      - targets: ['localhost:7860']
```

Export Gradio metrics and visualize with Grafana.

## Performance Optimization

### Model Caching

```python
# Cache models on disk
os.environ['HF_HOME'] = '/data/huggingface'
os.environ['TORCH_HOME'] = '/data/torch'
```

### Compilation

Use PyTorch 2.0 compilation:

```python
# In model initialization
model = torch.compile(model, mode="reduce-overhead")
```

### Batch Processing

Enable batch inference for multiple requests:

```python
def process_batch(prompts):
    # Process multiple prompts at once
    results = model.generate_batch(prompts)
    return results
```

## Security

### Authentication

Add auth to Gradio:

```python
demo.launch(
    auth=("admin", "your-secure-password"),
    # Or use function for database auth:
    auth=check_credentials
)
```

### Rate Limiting

```python
from gradio_client import Client
import time
from functools import wraps

def rate_limit(calls_per_minute=10):
    def decorator(func):
        last_called = {}
        
        @wraps(func)
        def wrapper(*args, **kwargs):
            now = time.time()
            # Implementation of rate limiting
            return func(*args, **kwargs)
        return wrapper
    return decorator
```

### HTTPS Only

Force HTTPS in Nginx:

```nginx
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

## Troubleshooting

### Out of Memory

- Reduce concurrency_count
- Increase swap space
- Use model quantization
- Implement request queuing

### Slow Response

- Enable model caching
- Use faster storage (SSD/NVMe)
- Increase worker count
- Load balance across GPUs

### Connection Issues

- Check firewall rules
- Verify port forwarding
- Test with curl/wget
- Check Nginx logs

## Cost Optimization

### Cloud Instance Scheduling

```bash
# Auto-shutdown during off-hours
0 2 * * * sudo shutdown -h now

# Auto-start with cron @reboot
@reboot /path/to/run.sh
```

### Spot Instances

Use AWS Spot or GCP Preemptible instances for 60-80% cost savings.

### Model Quantization

Already enabled in app.py:
- FP8 quantization for HunyuanWorld
- Low VRAM mode for WorldGen

## Support

For deployment issues:
- Check logs: `docker-compose logs` or `/var/log/world3d.log`
- Monitor GPU: `nvidia-smi`
- Test locally first before cloud deployment
