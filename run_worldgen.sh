#!/bin/bash

echo "🚀 Starting WorldGen Studio..."

if conda env list | grep -q "worldgen_env"; then
    echo "✅ Environment found: worldgen_env"
else
    echo "❌ Environment 'worldgen_env' not found!"
    echo "Please run ./setup_worldgen.sh first"
    exit 1
fi

eval "$(conda shell.bash hook)"
conda activate worldgen_env

echo "⚡ Launching WorldGen app..."
echo "📡 Port: 7861"
echo ""

python app_worldgen.py
