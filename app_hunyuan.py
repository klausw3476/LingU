"""
Gradio Web App for HunyuanWorld-1.0
High-quality 360° immersive 3D world generation
"""

import gradio as gr
import torch
import os
import sys
from pathlib import Path
from PIL import Image
import tempfile
import traceback

# Add model directory to path
HUNYUAN_PATH = Path("HunyuanWorld-1.0")
sys.path.insert(0, str(HUNYUAN_PATH))

# Global model instance
hunyuan_panogen = None
hunyuan_scenegen = None

def initialize_models():
    """Initialize HunyuanWorld models"""
    global hunyuan_panogen, hunyuan_scenegen
    try:
        from hy3dworld.panogen import PanoGen
        from hy3dworld.scenegen import SceneGen
        
        device = "cuda" if torch.cuda.is_available() else "cpu"
        
        hunyuan_panogen = PanoGen(
            device=device,
            fp8_gemm=True,
            fp8_attention=True
        )
        
        hunyuan_scenegen = SceneGen(
            device=device,
            fp8_gemm=True,
            fp8_attention=True
        )
        
        return "✅ HunyuanWorld-1.0 initialized successfully!"
    except Exception as e:
        return f"❌ Error: {str(e)}\n{traceback.format_exc()}"

def generate_text2world(prompt, labels_fg1, labels_fg2, scene_class):
    """Generate 3D world from text"""
    global hunyuan_panogen, hunyuan_scenegen
    
    if hunyuan_panogen is None or hunyuan_scenegen is None:
        return None, None, "Please initialize models first!"
    
    try:
        output_dir = Path(tempfile.mkdtemp(prefix="hunyuan_"))
        
        # Step 1: Generate panorama
        hunyuan_panogen.generate(
            prompt=prompt,
            output_path=str(output_dir)
        )
        
        pano_path = output_dir / "panorama.png"
        
        # Step 2: Generate 3D scene
        labels_fg1_list = labels_fg1.split() if labels_fg1 else []
        labels_fg2_list = labels_fg2.split() if labels_fg2 else []
        
        hunyuan_scenegen.generate(
            image_path=str(pano_path),
            labels_fg1=labels_fg1_list,
            labels_fg2=labels_fg2_list,
            classes=scene_class,
            output_path=str(output_dir)
        )
        
        mesh_file = output_dir / "scene_mesh.glb"
        
        if mesh_file.exists():
            return str(pano_path), str(mesh_file), "✅ Generation successful!"
        else:
            return str(pano_path), None, f"⚠️ Panorama generated, mesh not found in: {output_dir}"
            
    except Exception as e:
        return None, None, f"❌ Error: {str(e)}\n{traceback.format_exc()}"

def generate_image2world(image, labels_fg1, labels_fg2, scene_class):
    """Generate 3D world from image"""
    global hunyuan_panogen, hunyuan_scenegen
    
    if hunyuan_panogen is None or hunyuan_scenegen is None:
        return None, None, "Please initialize models first!"
    
    try:
        output_dir = Path(tempfile.mkdtemp(prefix="hunyuan_"))
        
        # Step 1: Generate panorama
        hunyuan_panogen.generate(
            prompt="",
            image_path=image,
            output_path=str(output_dir)
        )
        
        pano_path = output_dir / "panorama.png"
        
        # Step 2: Generate 3D scene
        labels_fg1_list = labels_fg1.split() if labels_fg1 else []
        labels_fg2_list = labels_fg2.split() if labels_fg2 else []
        
        hunyuan_scenegen.generate(
            image_path=str(pano_path),
            labels_fg1=labels_fg1_list,
            labels_fg2=labels_fg2_list,
            classes=scene_class,
            output_path=str(output_dir)
        )
        
        mesh_file = output_dir / "scene_mesh.glb"
        
        if mesh_file.exists():
            return str(pano_path), str(mesh_file), "✅ Generation successful!"
        else:
            return str(pano_path), None, f"⚠️ Panorama generated, mesh not found in: {output_dir}"
            
    except Exception as e:
        return None, None, f"❌ Error: {str(e)}\n{traceback.format_exc()}"

# Create Gradio Interface
with gr.Blocks(title="HunyuanWorld-1.0", theme=gr.themes.Soft()) as demo:
    gr.Markdown("# 🎨 HunyuanWorld-1.0 Studio")
    gr.Markdown("Generate high-quality 360° immersive 3D worlds with semantic layering")
    
    # Initialization
    with gr.Accordion("🔧 Model Initialization", open=True):
        gr.Markdown("Initialize the model before first use (takes ~2 minutes)")
        init_btn = gr.Button("Initialize HunyuanWorld-1.0", variant="primary", size="lg")
        status = gr.Textbox(label="Status", interactive=False)
    
    # Generation Tabs
    with gr.Tabs():
        with gr.Tab("📝 Text to World"):
            with gr.Row():
                with gr.Column():
                    text_prompt = gr.Textbox(
                        label="Text Prompt",
                        placeholder="A serene mountain lake at sunset with pine trees...",
                        lines=4
                    )
                    text_fg1 = gr.Textbox(
                        label="Foreground Layer 1 (optional)",
                        placeholder="e.g., trees rocks flowers",
                        info="Close objects - space-separated labels"
                    )
                    text_fg2 = gr.Textbox(
                        label="Foreground Layer 2 (optional)",
                        placeholder="e.g., mountains clouds sky",
                        info="Distant objects - space-separated labels"
                    )
                    text_class = gr.Dropdown(
                        choices=["outdoor", "indoor"],
                        value="outdoor",
                        label="Scene Class"
                    )
                    text_btn = gr.Button("Generate World", variant="primary", size="lg")
                
                with gr.Column():
                    text_pano = gr.Image(label="Generated Panorama", type="filepath")
                    text_mesh = gr.Model3D(label="3D World (GLB)", clear_color=[0.0, 0.0, 0.0, 0.0])
                    text_status = gr.Textbox(label="Status", interactive=False)
        
        with gr.Tab("🖼️ Image to World"):
            with gr.Row():
                with gr.Column():
                    img_input = gr.Image(label="Input Image", type="filepath")
                    img_fg1 = gr.Textbox(
                        label="Foreground Layer 1 (optional)",
                        placeholder="e.g., stones flowers"
                    )
                    img_fg2 = gr.Textbox(
                        label="Foreground Layer 2 (optional)",
                        placeholder="e.g., trees mountains"
                    )
                    img_class = gr.Dropdown(
                        choices=["outdoor", "indoor"],
                        value="outdoor",
                        label="Scene Class"
                    )
                    img_btn = gr.Button("Generate World", variant="primary", size="lg")
                
                with gr.Column():
                    img_pano = gr.Image(label="Generated Panorama", type="filepath")
                    img_mesh = gr.Model3D(label="3D World (GLB)", clear_color=[0.0, 0.0, 0.0, 0.0])
                    img_status = gr.Textbox(label="Status", interactive=False)
    
    # Information
    with gr.Accordion("ℹ️ About HunyuanWorld-1.0", open=False):
        gr.Markdown("""
        ### Features
        - 🌐 360° panoramic world generation
        - 🎯 Semantic object layering for interactivity
        - 📦 GLB mesh export for Unity/Unreal/VR
        - 🎨 High-quality immersive environments
        
        ### Generation Time
        - Text/Image to Panorama: ~1-2 minutes
        - Panorama to 3D World: ~2-3 minutes
        - **Total**: ~3-5 minutes per world
        
        ### Best Use Cases
        - VR/AR experiences
        - Game development
        - Architectural visualization
        - Virtual tours
        
        ### Model Info
        - Based on FLUX.1-dev
        - PyTorch 2.5.0 with CUDA 12.4
        - Supports outdoor and indoor scenes
        
        ### Resources
        - [GitHub](https://github.com/Tencent-Hunyuan/HunyuanWorld-1.0)
        - [Demo](https://3d.hunyuan.tencent.com/sceneTo3D)
        """)
    
    # Connect events
    init_btn.click(fn=initialize_models, outputs=status)
    
    text_btn.click(
        fn=generate_text2world,
        inputs=[text_prompt, text_fg1, text_fg2, text_class],
        outputs=[text_pano, text_mesh, text_status]
    )
    
    img_btn.click(
        fn=generate_image2world,
        inputs=[img_input, img_fg1, img_fg2, img_class],
        outputs=[img_pano, img_mesh, img_status]
    )

if __name__ == "__main__":
    demo.launch(
        server_name="0.0.0.0",
        server_port=7860,
        share=True,
        show_error=True
    )
