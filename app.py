"""
Gradio Web App for 3D World Generation
Integrates HunyuanWorld-1.0 and WorldGen models
"""

import gradio as gr
import torch
import os
import sys
from pathlib import Path
from PIL import Image
import tempfile
import traceback

# Add model directories to path
HUNYUAN_PATH = Path("HunyuanWorld-1.0")
WORLDGEN_PATH = Path("WorldGen")

# Global model instances
hunyuan_panogen = None
worldgen_model = None

def initialize_hunyuan():
    """Initialize HunyuanWorld-1.0 model"""
    global hunyuan_panogen
    try:
        sys.path.insert(0, str(HUNYUAN_PATH))
        from hy3dworld.panogen import PanoGen
        
        hunyuan_panogen = PanoGen(
            device="cuda" if torch.cuda.is_available() else "cpu",
            fp8_gemm=True,  # Use quantization for lower memory
            fp8_attention=True
        )
        return "HunyuanWorld-1.0 initialized successfully!"
    except Exception as e:
        return f"Error initializing HunyuanWorld: {str(e)}\n{traceback.format_exc()}"

def initialize_worldgen():
    """Initialize WorldGen model"""
    global worldgen_model
    try:
        sys.path.insert(0, str(WORLDGEN_PATH))
        from worldgen import WorldGen
        
        worldgen_model = WorldGen(
            mode="t2s",
            device=torch.device("cuda" if torch.cuda.is_available() else "cpu"),
            low_vram=True  # Enable for consumer GPUs
        )
        return "WorldGen initialized successfully!"
    except Exception as e:
        return f"Error initializing WorldGen: {str(e)}\n{traceback.format_exc()}"

def generate_hunyuan_text2world(prompt, labels_fg1, labels_fg2, scene_class):
    """Generate 3D world using HunyuanWorld from text"""
    global hunyuan_panogen
    
    if hunyuan_panogen is None:
        return None, None, "Please initialize HunyuanWorld-1.0 first!"
    
    try:
        # Create output directory
        output_dir = Path(tempfile.mkdtemp(prefix="hunyuan_"))
        
        # Step 1: Generate panorama
        pano_result = hunyuan_panogen.generate(
            prompt=prompt,
            output_path=str(output_dir)
        )
        
        pano_path = output_dir / "panorama.png"
        
        # Step 2: Generate 3D scene
        sys.path.insert(0, str(HUNYUAN_PATH))
        from hy3dworld.scenegen import SceneGen
        
        scenegen = SceneGen(
            device="cuda" if torch.cuda.is_available() else "cpu",
            fp8_gemm=True,
            fp8_attention=True
        )
        
        labels_fg1_list = labels_fg1.split() if labels_fg1 else []
        labels_fg2_list = labels_fg2.split() if labels_fg2 else []
        
        scene_result = scenegen.generate(
            image_path=str(pano_path),
            labels_fg1=labels_fg1_list,
            labels_fg2=labels_fg2_list,
            classes=scene_class,
            output_path=str(output_dir)
        )
        
        # Find output files
        mesh_file = output_dir / "scene_mesh.glb"
        
        if mesh_file.exists():
            return str(pano_path), str(mesh_file), "Generation successful!"
        else:
            return str(pano_path), None, f"Generation completed but mesh not found. Check: {output_dir}"
            
    except Exception as e:
        return None, None, f"Error: {str(e)}\n{traceback.format_exc()}"

def generate_hunyuan_image2world(image, labels_fg1, labels_fg2, scene_class):
    """Generate 3D world using HunyuanWorld from image"""
    global hunyuan_panogen
    
    if hunyuan_panogen is None:
        return None, None, "Please initialize HunyuanWorld-1.0 first!"
    
    try:
        # Create output directory
        output_dir = Path(tempfile.mkdtemp(prefix="hunyuan_"))
        
        # Step 1: Generate panorama from image
        pano_result = hunyuan_panogen.generate(
            prompt="",
            image_path=image,
            output_path=str(output_dir)
        )
        
        pano_path = output_dir / "panorama.png"
        
        # Step 2: Generate 3D scene
        sys.path.insert(0, str(HUNYUAN_PATH))
        from hy3dworld.scenegen import SceneGen
        
        scenegen = SceneGen(
            device="cuda" if torch.cuda.is_available() else "cpu",
            fp8_gemm=True,
            fp8_attention=True
        )
        
        labels_fg1_list = labels_fg1.split() if labels_fg1 else []
        labels_fg2_list = labels_fg2.split() if labels_fg2 else []
        
        scene_result = scenegen.generate(
            image_path=str(pano_path),
            labels_fg1=labels_fg1_list,
            labels_fg2=labels_fg2_list,
            classes=scene_class,
            output_path=str(output_dir)
        )
        
        # Find output files
        mesh_file = output_dir / "scene_mesh.glb"
        
        if mesh_file.exists():
            return str(pano_path), str(mesh_file), "Generation successful!"
        else:
            return str(pano_path), None, f"Generation completed but mesh not found. Check: {output_dir}"
            
    except Exception as e:
        return None, None, f"Error: {str(e)}\n{traceback.format_exc()}"

def generate_worldgen_text2scene(prompt, use_sharp, return_mesh):
    """Generate 3D scene using WorldGen from text"""
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
        
        return str(output_file), "Generation successful!"
        
    except Exception as e:
        return None, f"Error: {str(e)}\n{traceback.format_exc()}"

def generate_worldgen_image2scene(image, prompt, use_sharp, return_mesh):
    """Generate 3D scene using WorldGen from image"""
    global worldgen_model
    
    if worldgen_model is None:
        return None, "Please initialize WorldGen first!"
    
    try:
        # Switch to image-to-scene mode if needed
        if worldgen_model.mode != "i2s":
            worldgen_model = None
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
        
        return str(output_file), "Generation successful!"
        
    except Exception as e:
        return None, f"Error: {str(e)}\n{traceback.format_exc()}"

# Create Gradio Interface
with gr.Blocks(title="3D World Generation Studio", theme=gr.themes.Soft()) as demo:
    gr.Markdown("# 🌍 3D World Generation Studio")
    gr.Markdown("Generate immersive 3D worlds using **HunyuanWorld-1.0** or **WorldGen**")
    
    # Model Initialization Section
    with gr.Accordion("🔧 Model Initialization", open=True):
        gr.Markdown("Initialize the models before use. This may take a few minutes on first run.")
        with gr.Row():
            with gr.Column():
                init_hunyuan_btn = gr.Button("Initialize HunyuanWorld-1.0", variant="primary")
                hunyuan_status = gr.Textbox(label="Status", interactive=False)
            with gr.Column():
                init_worldgen_btn = gr.Button("Initialize WorldGen", variant="primary")
                worldgen_status = gr.Textbox(label="Status", interactive=False)
    
    # Main Generation Tabs
    with gr.Tabs():
        # HunyuanWorld-1.0 Tab
        with gr.Tab("🎨 HunyuanWorld-1.0"):
            gr.Markdown("### Text or Image to 3D World")
            gr.Markdown("Generate high-quality 360° immersive 3D worlds with semantic layering")
            
            with gr.Tabs():
                with gr.Tab("Text to World"):
                    with gr.Row():
                        with gr.Column():
                            hy_text_prompt = gr.Textbox(
                                label="Text Prompt",
                                placeholder="A beautiful landscape with mountains and a river...",
                                lines=3
                            )
                            hy_text_fg1 = gr.Textbox(
                                label="Foreground Layer 1 (optional)",
                                placeholder="e.g., stones flowers",
                                info="Space-separated object labels"
                            )
                            hy_text_fg2 = gr.Textbox(
                                label="Foreground Layer 2 (optional)",
                                placeholder="e.g., trees mountains",
                                info="Space-separated object labels"
                            )
                            hy_text_class = gr.Dropdown(
                                choices=["outdoor", "indoor"],
                                value="outdoor",
                                label="Scene Class"
                            )
                            hy_text_btn = gr.Button("Generate World", variant="primary")
                        
                        with gr.Column():
                            hy_text_pano = gr.Image(label="Generated Panorama", type="filepath")
                            hy_text_mesh = gr.Model3D(label="3D World (GLB)", clear_color=[0.0, 0.0, 0.0, 0.0])
                            hy_text_status = gr.Textbox(label="Status", interactive=False)
                
                with gr.Tab("Image to World"):
                    with gr.Row():
                        with gr.Column():
                            hy_img_input = gr.Image(label="Input Image", type="filepath")
                            hy_img_fg1 = gr.Textbox(
                                label="Foreground Layer 1 (optional)",
                                placeholder="e.g., stones flowers"
                            )
                            hy_img_fg2 = gr.Textbox(
                                label="Foreground Layer 2 (optional)",
                                placeholder="e.g., trees mountains"
                            )
                            hy_img_class = gr.Dropdown(
                                choices=["outdoor", "indoor"],
                                value="outdoor",
                                label="Scene Class"
                            )
                            hy_img_btn = gr.Button("Generate World", variant="primary")
                        
                        with gr.Column():
                            hy_img_pano = gr.Image(label="Generated Panorama", type="filepath")
                            hy_img_mesh = gr.Model3D(label="3D World (GLB)", clear_color=[0.0, 0.0, 0.0, 0.0])
                            hy_img_status = gr.Textbox(label="Status", interactive=False)
        
        # WorldGen Tab
        with gr.Tab("⚡ WorldGen"):
            gr.Markdown("### Fast 3D Scene Generation")
            gr.Markdown("Generate 3D scenes in seconds with Gaussian Splatting")
            
            with gr.Tabs():
                with gr.Tab("Text to Scene"):
                    with gr.Row():
                        with gr.Column():
                            wg_text_prompt = gr.Textbox(
                                label="Text Prompt",
                                placeholder="A cozy bedroom with modern furniture...",
                                lines=3
                            )
                            wg_text_sharp = gr.Checkbox(
                                label="Use ML-Sharp (experimental)",
                                value=False,
                                info="May produce better results"
                            )
                            wg_text_mesh = gr.Checkbox(
                                label="Return Mesh (instead of Gaussian Splat)",
                                value=False
                            )
                            wg_text_btn = gr.Button("Generate Scene", variant="primary")
                        
                        with gr.Column():
                            wg_text_output = gr.Model3D(label="3D Scene", clear_color=[0.0, 0.0, 0.0, 0.0])
                            wg_text_status = gr.Textbox(label="Status", interactive=False)
                
                with gr.Tab("Image to Scene"):
                    with gr.Row():
                        with gr.Column():
                            wg_img_input = gr.Image(label="Input Image", type="filepath")
                            wg_img_prompt = gr.Textbox(
                                label="Additional Prompt (optional)",
                                placeholder="",
                                lines=2
                            )
                            wg_img_sharp = gr.Checkbox(
                                label="Use ML-Sharp (experimental)",
                                value=False
                            )
                            wg_img_mesh = gr.Checkbox(
                                label="Return Mesh (instead of Gaussian Splat)",
                                value=False
                            )
                            wg_img_btn = gr.Button("Generate Scene", variant="primary")
                        
                        with gr.Column():
                            wg_img_output = gr.Model3D(label="3D Scene", clear_color=[0.0, 0.0, 0.0, 0.0])
                            wg_img_status = gr.Textbox(label="Status", interactive=False)
    
    # Information Section
    with gr.Accordion("ℹ️ Model Information", open=False):
        gr.Markdown("""
        ### HunyuanWorld-1.0
        - **Features**: 360° immersive worlds, semantic layering, mesh export
        - **Best for**: High-quality outdoor/indoor scenes with detailed objects
        - **Output**: GLB mesh format
        
        ### WorldGen
        - **Features**: Fast generation (seconds), Gaussian Splatting, flexible rendering
        - **Best for**: Quick prototyping, diverse scene styles
        - **Output**: PLY format (Gaussian Splat or Mesh)
        
        ### System Requirements
        - CUDA-capable GPU (recommended: 16GB+ VRAM)
        - For lower VRAM: Models use quantization and low-memory modes
        """)
    
    # Connect events
    init_hunyuan_btn.click(fn=initialize_hunyuan, outputs=hunyuan_status)
    init_worldgen_btn.click(fn=initialize_worldgen, outputs=worldgen_status)
    
    hy_text_btn.click(
        fn=generate_hunyuan_text2world,
        inputs=[hy_text_prompt, hy_text_fg1, hy_text_fg2, hy_text_class],
        outputs=[hy_text_pano, hy_text_mesh, hy_text_status]
    )
    
    hy_img_btn.click(
        fn=generate_hunyuan_image2world,
        inputs=[hy_img_input, hy_img_fg1, hy_img_fg2, hy_img_class],
        outputs=[hy_img_pano, hy_img_mesh, hy_img_status]
    )
    
    wg_text_btn.click(
        fn=generate_worldgen_text2scene,
        inputs=[wg_text_prompt, wg_text_sharp, wg_text_mesh],
        outputs=[wg_text_output, wg_text_status]
    )
    
    wg_img_btn.click(
        fn=generate_worldgen_image2scene,
        inputs=[wg_img_input, wg_img_prompt, wg_img_sharp, wg_img_mesh],
        outputs=[wg_img_output, wg_img_status]
    )

if __name__ == "__main__":
    demo.launch(
        server_name="0.0.0.0",  # Make accessible from other machines
        server_port=7860,
        share=True,  # Create a public URL
        show_error=True
    )
