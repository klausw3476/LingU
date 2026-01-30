#!/bin/bash

echo "🚀 Starting HunyuanWorld-1.0 Studio..."

if conda env list | grep -q "hunyuan_env"; then
    echo "✅ Environment found: hunyuan_env"
else
    echo "❌ Environment 'hunyuan_env' not found!"
    echo "Please run ./setup_hunyuan.sh first"
    exit 1
fi

eval "$(conda shell.bash hook)"
conda activate hunyuan_env

echo "🌍 Launching HunyuanWorld app..."
echo "📡 Port: 7860"
echo ""

python app_hunyuan.py
