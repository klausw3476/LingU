"""
Gradio Web App for WorldGen
Fast 3D scene generation in seconds
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
WORLDGEN_PATH = Path("WorldGen")
sys.path.insert(0, str(WORLDGEN_PATH))

# Global model instance
worldgen_model = None

def initialize_model():
    """Initialize WorldGen model"""
    global worldgen_model
    try:
        from worldgen import WorldGen
        
        worldgen_model = WorldGen(
            mode="t2s",
            device=torch.device("cuda" if torch.cuda.is_available() else "cpu"),
            low_vram=True
        )
        return "✅ WorldGen initialized successfully!"
    except Exception as e:
        return f"❌ Error: {str(e)}\n{traceback.format_exc()}"

def generate_text2scene(prompt, use_sharp, return_mesh):
    """Generate 3D scene from text"""
    global worldgen_model
    
    if worldgen_model is None:
        return None, "Please initialize WorldGen first!"
    
    try:
        output_dir = Path(tempfile.mkdtemp(prefix="worldgen_"))
        
        # Generate scene
        result = worldgen_model.generate_world(
            prompt=prompt,
            use_sharp=use_sharp,
            return_mesh=return_mesh
        )
        
        # Save output
        if return_mesh:
            import open3d as o3d
            output_file = output_dir / "scene_mesh.ply"
            o3d.io.write_triangle_mesh(str(output_file), result)
        else:
            output_file = output_dir / "scene_splat.ply"
            result.save(str(output_file))
        
        return str(output_file), "✅ Generation successful!"
        
    except Exception as e:
        return None, f"❌ Error: {str(e)}\n{traceback.format_exc()}"

def generate_image2scene(image, prompt, use_sharp, return_mesh):
    """Generate 3D scene from image"""
    global worldgen_model
    
    if worldgen_model is None:
        return None, "Please initialize WorldGen first!"
    
    try:
        # Switch to i2s mode if needed
        if worldgen_model.mode != "i2s":
            from worldgen import WorldGen
            worldgen_model = WorldGen(
                mode="i2s",
                device=torch.device("cuda" if torch.cuda.is_available() else "cpu"),
                low_vram=True
            )
        
        output_dir = Path(tempfile.mkdtemp(prefix="worldgen_"))
        
        # Load image
        img = Image.open(image) if isinstance(image, str) else image
        
        # Generate scene
        result = worldgen_model.generate_world(
            image=img,
            prompt=prompt,
            use_sharp=use_sharp,
            return_mesh=return_mesh
        )
        
        # Save output
        if return_mesh:
            import open3d as o3d
            output_file = output_dir / "scene_mesh.ply"
            o3d.io.write_triangle_mesh(str(output_file), result)
        else:
            output_file = output_dir / "scene_splat.ply"
            result.save(str(output_file))
        
        return str(output_file), "✅ Generation successful!"
        
    except Exception as e:
        return None, f"❌ Error: {str(e)}\n{traceback.format_exc()}"

# Create Gradio Interface
with gr.Blocks(title="WorldGen", theme=gr.themes.Soft()) as demo:
    gr.Markdown("# ⚡ WorldGen Studio")
    gr.Markdown("Generate 3D scenes in seconds with Gaussian Splatting")
    
    # Initialization
    with gr.Accordion("🔧 Model Initialization", open=True):
        gr.Markdown("Initialize the model before first use (takes ~1 minute)")
        init_btn = gr.Button("Initialize WorldGen", variant="primary", size="lg")
        status = gr.Textbox(label="Status", interactive=False)
    
    # Generation Tabs
    with gr.Tabs():
        with gr.Tab("📝 Text to Scene"):
            with gr.Row():
                with gr.Column():
                    text_prompt = gr.Textbox(
                        label="Text Prompt",
                        placeholder="A cozy modern bedroom with warm lighting...",
                        lines=4
                    )
                    text_sharp = gr.Checkbox(
                        label="Use ML-Sharp (experimental)",
                        value=False,
                        info="May produce better results, slightly slower"
                    )
                    text_mesh = gr.Checkbox(
                        label="Return Mesh (instead of Gaussian Splat)",
                        value=False,
                        info="Mesh is compatible with game engines"
                    )
                    text_btn = gr.Button("Generate Scene", variant="primary", size="lg")
                
                with gr.Column():
                    text_output = gr.Model3D(label="3D Scene (PLY)", clear_color=[0.0, 0.0, 0.0, 0.0])
                    text_status = gr.Textbox(label="Status", interactive=False)
        
        with gr.Tab("🖼️ Image to Scene"):
            with gr.Row():
                with gr.Column():
                    img_input = gr.Image(label="Input Image", type="filepath")
                    img_prompt = gr.Textbox(
                        label="Additional Prompt (optional)",
                        placeholder="Style guidance or modifications...",
                        lines=2
                    )
                    img_sharp = gr.Checkbox(
                        label="Use ML-Sharp (experimental)",
                        value=False
                    )
                    img_mesh = gr.Checkbox(
                        label="Return Mesh (instead of Gaussian Splat)",
                        value=False
                    )
                    img_btn = gr.Button("Generate Scene", variant="primary", size="lg")
                
                with gr.Column():
                    img_output = gr.Model3D(label="3D Scene (PLY)", clear_color=[0.0, 0.0, 0.0, 0.0])
                    img_status = gr.Textbox(label="Status", interactive=False)
    
    # Information
    with gr.Accordion("ℹ️ About WorldGen", open=False):
        gr.Markdown("""
        ### Features
        - ⚡ Ultra-fast generation (10-30 seconds)
        - 🎮 Gaussian Splatting for real-time rendering
        - 🔄 Support for both mesh and splat outputs
        - 🎨 Works with text prompts and images
        - 🧪 Experimental ML-Sharp for better quality
        
        ### Generation Time
        - Text/Image to Scene: **10-30 seconds**
        - With ML-Sharp: ~20-40 seconds
        
        ### Best Use Cases
        - Rapid prototyping
        - Concept exploration
        - Style variations
        - Quick asset generation
        
        ### Model Info
        - Based on FLUX.1-dev + Gaussian Splatting
        - PyTorch 2.6.0+ with CUDA 12.4
        - Python 3.11+
        
        ### Resources
        - [GitHub](https://github.com/ZiYang-xie/WorldGen)
        - [Website](https://worldgen.github.io/)
        """)
    
    # Connect events
    init_btn.click(fn=initialize_model, outputs=status)
    
    text_btn.click(
        fn=generate_text2scene,
        inputs=[text_prompt, text_sharp, text_mesh],
        outputs=[text_output, text_status]
    )
    
    img_btn.click(
        fn=generate_image2scene,
        inputs=[img_input, img_prompt, img_sharp, img_mesh],
        outputs=[img_output, img_status]
    )

if __name__ == "__main__":
    demo.launch(
        server_name="0.0.0.0",
        server_port=7861,  # Different port
        share=True,
        show_error=True
    )
