# 🎨 Example Prompts & Results

This guide provides tested prompts for both models with expected results and tips.

## 🏔️ HunyuanWorld-1.0 Examples

### Outdoor Landscapes

#### 1. Mountain Lake
**Prompt**: `"A serene mountain lake at sunset with pine trees and snow-capped peaks"`

**Configuration**:
- Foreground Layer 1: `trees rocks`
- Foreground Layer 2: `mountains clouds`
- Scene Class: `outdoor`

**Expected Result**: 
- Panoramic view with layered depth
- Separate object layers for interactivity
- GLB mesh export
- Generation time: ~3-4 minutes

**Best For**: VR experiences, nature scenes

---

#### 2. Desert Oasis
**Prompt**: `"A desert oasis with palm trees, sand dunes, and a small water pool under blue sky"`

**Configuration**:
- Foreground Layer 1: `palms water stones`
- Foreground Layer 2: `dunes clouds`
- Scene Class: `outdoor`

**Expected Result**: Detailed desert environment with layered elements

---

#### 3. Tropical Beach
**Prompt**: `"Tropical beach paradise with white sand, turquoise water, palm trees, and a wooden pier"`

**Configuration**:
- Foreground Layer 1: `pier palms sand`
- Foreground Layer 2: `ocean sky`
- Scene Class: `outdoor`

**Expected Result**: Immersive beach scene with separated objects

---

### Indoor Scenes

#### 4. Modern Living Room
**Prompt**: `"Modern minimalist living room with large windows, contemporary furniture, and wooden floors"`

**Configuration**:
- Foreground Layer 1: `furniture plants`
- Foreground Layer 2: `windows paintings`
- Scene Class: `indoor`

**Expected Result**: Clean interior with separated furniture pieces

---

#### 5. Medieval Castle Hall
**Prompt**: `"Medieval castle throne room with stone walls, torches, banners, and a grand throne"`

**Configuration**:
- Foreground Layer 1: `throne torches`
- Foreground Layer 2: `banners tapestries`
- Scene Class: `indoor`

**Expected Result**: Atmospheric castle interior

---

### Fantasy & Sci-Fi

#### 6. Enchanted Forest
**Prompt**: `"Enchanted mystical forest with glowing mushrooms, fireflies, and magical mist at twilight"`

**Configuration**:
- Foreground Layer 1: `mushrooms flowers`
- Foreground Layer 2: `trees fog`
- Scene Class: `outdoor`

**Expected Result**: Magical forest atmosphere

---

#### 7. Alien Planet
**Prompt**: `"Alien planet landscape with purple vegetation, strange rock formations, and two moons in the sky"`

**Configuration**:
- Foreground Layer 1: `plants crystals`
- Foreground Layer 2: `rocks mountains`
- Scene Class: `outdoor`

**Expected Result**: Otherworldly environment

---

## ⚡ WorldGen Examples

### Quick Prototypes

#### 1. Cozy Bedroom
**Prompt**: `"A cozy modern bedroom with a large bed, nightstands, warm lighting, and minimal decor"`

**Settings**:
- Use ML-Sharp: ✅ Yes
- Return Mesh: ⬜ No (Gaussian Splat)

**Expected Result**:
- Generation time: ~10-15 seconds
- Detailed bedroom scene
- Good for rapid iteration

---

#### 2. Sci-Fi Laboratory
**Prompt**: `"Futuristic laboratory with glowing screens, high-tech equipment, and neon lighting"`

**Settings**:
- Use ML-Sharp: ✅ Yes
- Return Mesh: ✅ Yes

**Expected Result**:
- Fast generation
- Mesh output for game engines
- Sci-fi aesthetic

---

#### 3. Japanese Garden
**Prompt**: `"Traditional Japanese zen garden with stone path, bamboo, small bridge over pond, and cherry blossoms"`

**Settings**:
- Use ML-Sharp: ✅ Yes
- Return Mesh: ⬜ No

**Expected Result**: Peaceful garden scene with natural elements

---

#### 4. Underground Cave
**Prompt**: `"Underground cave system with stalactites, stalagmites, underground lake, and bioluminescent crystals"`

**Settings**:
- Use ML-Sharp: ✅ Yes
- Return Mesh: ⬜ No

**Expected Result**: Mysterious cave environment

---

#### 5. Urban Rooftop
**Prompt**: `"Modern urban rooftop terrace with city skyline view, plants, furniture, and string lights at dusk"`

**Settings**:
- Use ML-Sharp: ✅ Yes
- Return Mesh: ✅ Yes

**Expected Result**: Contemporary urban scene

---

## 🖼️ Image-to-World Examples

### Using HunyuanWorld

#### Example 1: Landscape Photo
**Input**: Upload a photo of any landscape
**Additional Prompts**: Leave empty or add details like "at sunset" or "with snow"
**Configuration**: 
- Let the model auto-detect foreground objects
- Or specify: `grass flowers` for Layer 1, `trees sky` for Layer 2

**Expected Result**: 360° panorama extending your image

---

#### Example 2: Interior Photo
**Input**: Upload a room photo
**Configuration**:
- Scene Class: `indoor`
- Foreground: `furniture decorations`

**Expected Result**: Full room panorama

---

### Using WorldGen

#### Example 1: Concept Art
**Input**: Upload concept art or sketch
**Additional Prompt**: `"high quality 3D scene"`
**Settings**: Use ML-Sharp ✅

**Expected Result**: 3D interpretation of the art

---

#### Example 2: Real Photo
**Input**: Upload any real-world photo
**Additional Prompt**: Optional style guidance
**Settings**: Use ML-Sharp ✅, Return Mesh ✅

**Expected Result**: 3D scene based on photo

---

## 💡 Prompt Engineering Tips

### Do's ✅

1. **Be Specific**
   - ❌ "nice room"
   - ✅ "modern bedroom with wooden furniture and large windows"

2. **Include Lighting**
   - ❌ "forest"
   - ✅ "forest at golden hour with sun rays through trees"

3. **Mention Style**
   - ❌ "kitchen"
   - ✅ "rustic farmhouse kitchen with vintage appliances"

4. **Add Atmosphere**
   - ❌ "cave"
   - ✅ "mysterious cave with fog and dim blue lighting"

5. **Specify Details**
   - ❌ "beach"
   - ✅ "tropical beach with white sand, palm trees, and calm turquoise water"

### Don'ts ❌

1. **Avoid Conflicting Elements**
   - ❌ "snowy desert with tropical plants"

2. **Don't Overload**
   - ❌ "forest with trees, flowers, rocks, streams, animals, mushrooms, fog, rain, snow, sunset, mountains, caves, waterfalls..."
   - ✅ "forest with moss-covered rocks and a small stream"

3. **Avoid Abstract Concepts**
   - ❌ "a feeling of happiness"
   - ✅ "bright sunny meadow with colorful wildflowers"

4. **Don't Mix Scales**
   - ❌ "room with mountains inside"

5. **Avoid Unclear References**
   - ❌ "like that one game"
   - ✅ "cyberpunk city street with neon signs"

---

## 🎯 Model Selection Guide

### Use HunyuanWorld When:
- ✅ You need high quality
- ✅ VR/360° experience required
- ✅ Object layering needed
- ✅ Time isn't critical (3-5 min OK)
- ✅ GLB mesh export needed

### Use WorldGen When:
- ✅ Speed is important
- ✅ Rapid prototyping
- ✅ Testing multiple ideas
- ✅ Gaussian Splat workflow
- ✅ Need quick iterations

### Use Both When:
1. Start with WorldGen for quick concepts
2. Refine with HunyuanWorld for final quality
3. Compare approaches
4. Best of both worlds!

---

## 📊 Quality Expectations

### HunyuanWorld-1.0

**Strengths**:
- 🌟 Panoramic consistency
- 🌟 Object separation
- 🌟 Mesh quality
- 🌟 VR-ready

**Limitations**:
- ⏱️ Slower generation
- 💾 Higher VRAM usage
- 🔄 Fixed 360° format

### WorldGen

**Strengths**:
- ⚡ Ultra-fast
- 💾 Lower VRAM
- 🎨 Style flexibility
- 🔄 Mesh or Splat output

**Limitations**:
- 🔍 Less object detail
- 🌐 Not full 360° panoramic
- 🧪 Some experimental features

---

## 🧪 Experimental Features

### WorldGen ML-Sharp Mode
**What**: Enhanced quality using ML-Sharp
**When**: Better results for structured scenes (rooms, buildings)
**Trade-off**: Slightly slower (5-10 sec more)

### HunyuanWorld Background Inpainting
**What**: Better invisible region filling
**When**: Complex panoramas
**Status**: Currently experimental
**Enable**: Requires additional setup (see README)

---

## 📈 Advanced Techniques

### Multi-Pass Generation

1. **First Pass**: Use WorldGen for quick layout
2. **Analyze**: Check composition
3. **Second Pass**: Use HunyuanWorld with refined prompt
4. **Result**: Best quality with efficient workflow

### Layering Strategy (HunyuanWorld)

**Layer 1** (Foreground): Small, close objects
- flowers, stones, furniture, decorations

**Layer 2** (Background): Large, distant objects
- trees, mountains, buildings, clouds

**Result**: Better separation, easier editing

### Image Conditioning

1. **Generate base image**: Use AI image generator
2. **Upload to app**: Use Image-to-World
3. **Refine**: Add specific prompts
4. **Result**: More control over output

---

## 🎬 Use Case Examples

### Game Development
```
Prototype: WorldGen (10 sec)
Final: HunyuanWorld (3 min)
Export: GLB → Unity/Unreal
```

### VR Experience
```
Method: HunyuanWorld only
Output: 360° GLB
Integration: Direct to VR platform
```

### Rapid Concept Art
```
Method: WorldGen with ML-Sharp
Iterations: 10+ variations in 5 minutes
Selection: Pick best for refinement
```

### Architectural Viz
```
Input: Floor plan photo
Method: Image-to-World (both models)
Compare: Style variations
Present: To client
```

---

## 🔄 Iteration Workflow

### For Best Results:

1. **Start Broad**
   - Quick WorldGen generation
   - Test multiple prompts
   - Find what works

2. **Refine Prompt**
   - Add specific details
   - Adjust lighting/atmosphere
   - Fine-tune composition

3. **Final Quality**
   - Use HunyuanWorld
   - Add layering
   - Export for use

4. **Post-Process** (Optional)
   - Edit mesh in Blender
   - Adjust materials
   - Add details

---

## 📝 Prompt Templates

### Outdoor Scene Template
```
"[adjective] [location] with [feature1], [feature2], and [feature3] [time of day/weather]"

Example: "serene mountain valley with wildflowers, a stream, and pine trees at golden hour"
```

### Indoor Scene Template
```
"[style] [room type] with [furniture1], [furniture2], and [lighting] [atmosphere]"

Example: "modern minimalist kitchen with marble counters, pendant lights, and warm ambiance"
```

### Fantasy Template
```
"[magical/alien] [environment] with [unique feature1], [unique feature2], and [atmospheric element]"

Example: "enchanted underwater realm with glowing coral, ancient ruins, and mystical blue fog"
```

---

**Happy generating! 🎨✨**

*Share your best creations and prompts with the community!*
