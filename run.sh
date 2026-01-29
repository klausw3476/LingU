#!/bin/bash

# Quick launch script for 3D World Generation Studio

echo "🚀 Starting 3D World Generation Studio..."

# Check if conda environment exists
if conda env list | grep -q "world3d"; then
    echo "✅ Environment found: world3d"
else
    echo "❌ Environment 'world3d' not found!"
    echo "Please run ./setup.sh first"
    exit 1
fi

# Activate environment and run app
eval "$(conda shell.bash hook)"
conda activate world3d

echo "🌍 Launching web app..."
echo "📡 Access URLs will be shown below:"
echo ""

python app.py
