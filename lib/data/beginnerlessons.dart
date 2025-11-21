// Updated LessonManager with Photography Course Integration
// Data provider classes for the first 8 days

class BeginnerLessonsData {
  static List<Map<String, dynamic>> get lessons {
    return [
      // Day 1: What is Photography?
      {
        'id': 'lesson_001',
        'day': 1,
        'title': 'What is Photography?',
        'subtitle': 'Understanding the basics of capturing light',
        'description':
            'Learn what photography means, its history, and the fundamental components of every photograph.',
        'content':
            '''**Photography means clicking a photo using a camera or mobile phone.**

A photo can be of:
• A person (like your mom or friend)
• A place (your room, garden, or road)  
• A thing (like a cup, flower, or chair)
• A moment (like someone laughing or the sunset)

📷 The word *Photography* is made from:
• Photo = Light
• Graphy = Drawing or writing

So, Photography means drawing or writing with light.

**🖐️ A Little History of Photography**

Long ago, people didn't have cameras. They used to paint or draw pictures. Then came a smart idea: the Camera Obscura -- a dark box with a tiny hole. Light passed through the hole and made an image inside the box.

📸 The First Real Photo:
• In 1826, a man named Joseph Niépce took the world's first photograph
• It took him 8 hours to take one photo!

**🇮🇳 Photography in India**
• The first known photo in India was taken in the 1840s
• Lala Deen Dayal (1844–1905) was India's first great photographer
• He took photos of palaces, royals, and daily life

**💡 Why is Photography Important?**

Photography helps us:
✅ Save beautiful memories
✅ Express our thoughts without words
✅ Show emotions (like love, joy, sadness)
✅ Notice small details in life
✅ Make a career or earn money
✅ Make people smile 😊

**👁️ How Does a Camera Work?**

Think of your camera like your eyes:
1. Light enters the lens (just like your eye gets light)
2. Inside the camera, there is a sensor (like your retina)
3. The camera captures the image and saves it

**🧩 4 Things Every Photo Has**

1. **Light** - No light = no photo
2. **Subject** - The main thing in the photo
3. **Framing/Composition** - How you place the subject
4. **Timing** - When you click the photo''',
        'estimatedDuration': 25,
        'type': 'theory',
        'difficulty': 'beginner',
        'categories': ['Basics', 'History', 'Theory'],
        'objectives': [
          'Understand what photography means',
          'Learn the basic history of photography',
          'Identify the 4 essential elements of every photo',
          'Understand how a camera works like an eye',
        ],
        'exercises': [
          {
            'id': 'exercise_001_01',
            'title': 'First Photo Practice',
            'description':
                'Take your first intentional photographs to understand the basics',
            'steps': [
              'Take a photo of a cup or glass',
              'Take a photo of a flower or plant',
              'Take a photo of a window or light coming through it',
              'Take a photo of a person (ask permission first!)',
              'Take a photo of a shadow on the wall',
            ],
            'requirements': {
              'camera': 'Any camera or mobile phone',
              'time': '15 minutes',
              'location': 'Indoor and outdoor',
            },
            'estimatedTime': 15,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Photography': 'Taking pictures using light',
            'Light': 'Brightness from sun, bulb, etc.',
            'Subject': 'The main thing in a photo',
            'Framing': 'How you place things in a photo',
            'Timing': 'The moment you click the photo',
            'Camera': 'Device to take photos',
          },
          'quote':
              'You don\'t need a big camera. You just need to see beauty in simple things.',
        },
      },

      // Day 2: Types of Cameras
      {
        'id': 'lesson_002',
        'day': 2,
        'title': 'Types of Cameras',
        'subtitle': 'DSLR, Mirrorless, Mobile & More',
        'description':
            'Explore different camera types and understand their strengths and weaknesses.',
        'content': '''**✋ What is a Camera?**

A camera is a tool used to capture photos using light.

Today, we will learn about different types of cameras:
1. Mobile Camera 📱
2. DSLR Camera 📸
3. Mirrorless Camera 📷
4. Film Camera 🎞️
5. Instant Camera 🖼️
6. Action Camera 🎥
7. Drone Camera 🚁
8. Compact/Point-and-Shoot Camera 📷

**📱 1. Mobile Camera**
• Found in smartphones
• Easy to carry and always with you
• Most people start photography with this

✅ Pros: Simple to use, always in your pocket, great for quick shots
❌ Cons: Small sensor, not great in low light, limited manual control
📊 Best For: Beginners, casual photography, social media

**📸 2. DSLR Camera (Digital Single Lens Reflex)**
• Big camera with a mirror inside
• Used by professional photographers

✅ Pros: Excellent photo quality, manual control, works well in low light, changeable lenses
❌ Cons: Heavy and big, expensive
📊 Best For: Portraits, weddings, studio work

**📷 3. Mirrorless Camera**
• Newer technology, no mirror inside
• Lightweight with high quality

✅ Pros: Compact, fast focus, excellent image and video, changeable lenses
❌ Cons: Battery life shorter, slightly costly
📊 Best For: Travel, content creation, video/photo hybrid

**🎞️ 4. Film Camera**
• Uses film rolls to capture images
• Photos are developed later on paper

✅ Pros: Vintage style, high-quality detail and texture
❌ Cons: Film is costly and needs development, no preview
📊 Best For: Art, retro-style photography

**📌 Your mobile camera is more than enough to start!**''',
        'estimatedDuration': 20,
        'type': 'theory',
        'difficulty': 'beginner',
        'categories': ['Equipment', 'Camera Types'],
        'objectives': [
          'Identify different types of cameras',
          'Understand pros and cons of each camera type',
          'Choose the right camera for your needs',
          'Learn about camera evolution from film to digital',
        ],
        'exercises': [
          {
            'id': 'exercise_002_01',
            'title': 'Camera Comparison Practice',
            'description':
                'Compare photo quality and features across different camera types',
            'steps': [
              'Take a photo of a person (portrait)',
              'Take a photo of an object (cup, book)',
              'Take a photo outdoors (tree, street)',
              'If you have access to other cameras, try the same shots',
              'Compare quality, focus, brightness, and look',
            ],
            'requirements': {
              'camera': 'Mobile phone minimum, other cameras optional',
              'subjects': 'Various subjects for comparison',
              'time': '20 minutes',
            },
            'estimatedTime': 20,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'DSLR': 'Big camera with mirror and viewfinder',
            'Mirrorless': 'Modern camera without mirror',
            'Film': 'Old-style roll used for taking pictures',
            'Drone': 'Flying camera for aerial shots',
            'Compact': 'Small camera, easy to carry',
          },
          'quote': 'The best camera is the one you have with you.',
        },
      },

      // Day 3: Understanding ISO
      {
        'id': 'lesson_003',
        'day': 3,
        'title': 'Understanding ISO',
        'subtitle': 'Your Camera\'s Sensitivity to Light',
        'description':
            'Learn how ISO controls light sensitivity and affects photo quality.',
        'content': '''**📷 What is ISO?**

ISO is your camera's **sensitivity to light**.

• A **low ISO** (like 100) means **less sensitive** to light
• A **high ISO** (like 3200) means **more sensitive** to light

👉 Think of ISO like your eyes:
• In bright sunlight ☀️, you don't need to squint (ISO 100)
• At night 🌙, your eyes try hard to see (ISO 1600+)

**🔍 Why is ISO Important?**

ISO helps control **how bright or dark your photo looks** --- especially when light is low.

• You increase ISO when it's **too dark**
• You keep ISO low when it's **bright or sunny**

But there's a catch:
📸 **Higher ISO = More Brightness but More Grain (Noise)**

**🌄 ISO Values (Simple Chart)**

| ISO Value | Light Situation | Result |
|-----------|----------------|---------|
| 100-200 | Sunny daylight | Sharp and clean photo |
| 400-800 | Cloudy, indoors | Bright enough, little noise |
| 1600-3200 | Evening, low light | Bright photo, visible noise |
| 6400+ | Very dark/nighttime | Very grainy, low quality image |

**📱 ISO on Mobile vs DSLR vs Mirrorless**

• 📱 **Mobile**: ISO is automatic, but some phones allow manual ISO (Pro mode)
• 📸 **DSLR & Mirrorless**: Full control. You can manually set ISO from 100 to 12800 or more

Mobile phones today use **AI to reduce noise** at high ISO. Still, DSLRs give **cleaner results**.

**🇮🇳📸 Indian & Global Use**

• In **Indian weddings**, photographers raise ISO for low-light temples or halls
• In **night festivals (like Diwali)**, ISO helps capture bright lights in dark areas
• **Wildlife photographers** often shoot early morning or late evening --- high ISO is common''',
        'estimatedDuration': 25,
        'type': 'theory',
        'difficulty': 'beginner',
        'categories': ['Technical Settings', 'Exposure', 'Light'],
        'objectives': [
          'Understand what ISO means and how it works',
          'Learn when to use high vs low ISO',
          'Recognize the trade-off between brightness and noise',
          'Practice ISO settings in different lighting conditions',
        ],
        'exercises': [
          {
            'id': 'exercise_003_01',
            'title': 'ISO Experiment',
            'description':
                'Practice using different ISO settings in various lighting conditions',
            'steps': [
              'Take a photo in sunlight with ISO 100',
              'Take a photo indoors with ISO 800',
              'Take a photo in dim light with ISO 1600+',
              'Compare the brightness and grain in each photo',
              'Try the same scene with different ISO values',
            ],
            'requirements': {
              'camera': 'Mobile with manual mode or DSLR',
              'lighting': 'Various lighting conditions',
              'time': '30 minutes',
            },
            'estimatedTime': 30,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'ISO': 'Camera\'s sensitivity to light',
            'Noise': 'Grain or dots in photo when ISO is high',
            'Manual Mode': 'You control all camera settings yourself',
            'Exposure': 'How bright or dark the photo is',
            'Sensor': 'Part of the camera that catches the image',
          },
          'quote': 'A noisy photo is better than a blurry one.',
        },
      },

      // Day 4: Aperture
      {
        'id': 'lesson_004',
        'day': 4,
        'title': 'Aperture',
        'subtitle': 'The Eye of Your Camera',
        'description':
            'Learn how aperture controls light and depth of field in your photos.',
        'content': '''**👁️ What is Aperture?**

**Aperture** is the opening inside your lens that lets light into the camera.

👉 Think of it like your eye's pupil:
• In bright light ☀️ your pupil gets small (small aperture)
• In darkness 🌙 your pupil opens wide (big aperture)

Aperture is measured in **f-numbers** like:
• **f/1.8** -- big opening, lets in more light
• **f/16** -- small opening, lets in less light

**🔢 Understanding f-Number (f-Stop)**

This can feel confusing at first:
• **Smaller f-number = Bigger opening = More light**
• **Larger f-number = Smaller opening = Less light**

| f-number | Opening Size | Light | Blur (Background) |
|----------|--------------|-------|-------------------|
| f/1.4 | Very big | High | Very blurry |
| f/2.8 | Big | Medium | Blurry |
| f/8 | Medium-small | Low | Little blur |
| f/16 | Very small | Very Low | Sharp background |

**🎨 How Aperture Affects Photos**

**1. Brightness**
• Bigger aperture (f/1.8) = brighter photo
• Smaller aperture (f/16) = darker photo

**2. Depth of Field (DOF)**
• **Shallow DOF** (f/1.8): Subject is clear, background is blurry
• **Deep DOF** (f/16): Everything from front to back is clear

**📸 Real Life Examples**

• 📱 **Mobile Portrait Mode** simulates wide aperture (f/2.0) for blur
• 📷 **DSLR with f/1.8 lens**: Great for portraits with creamy background
• 🌄 **Landscape photography**: Uses f/11 or f/16 for sharp details

**🇮🇳 Use in India + World**

• **Indian Weddings**: Photographers often use wide aperture (f/2.8) to blur background during couple portraits
• **Street Photography**: Uses f/4 to f/8 to keep more in focus
• **Architecture/Temples**: f/8 to f/11 keeps structures sharp''',
        'estimatedDuration': 30,
        'type': 'theory',
        'difficulty': 'beginner',
        'categories': ['Technical Settings', 'Exposure', 'Depth of Field'],
        'objectives': [
          'Understand what aperture is and how it works',
          'Learn the relationship between f-numbers and opening size',
          'Master depth of field control',
          'Practice creative background blur techniques',
        ],
        'exercises': [
          {
            'id': 'exercise_004_01',
            'title': 'Aperture Practice',
            'description':
                'Experiment with different aperture settings to understand depth of field',
            'steps': [
              'Take a photo with the lowest f-number your camera allows (e.g., f/2.0)',
              'Take the same photo with a high f-number (e.g., f/11)',
              'Compare brightness and background blur',
              'If using mobile, try Portrait vs Normal photo modes',
              'Observe how the background changes in each shot',
            ],
            'requirements': {
              'camera':
                  'Camera with manual aperture control or mobile with portrait mode',
              'subject': 'Person or object with background',
              'time': '25 minutes',
            },
            'estimatedTime': 25,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Aperture': 'Opening inside the lens',
            'f-number': 'Size of the lens opening',
            'Depth of Field': 'How much of the photo is in focus',
            'Background Blur': 'Soft look behind the subject',
            'Portrait Mode': 'Phone setting that gives blurred background',
          },
          'quote':
              'Blur in the background brings focus to the story in the front.',
        },
      },

      // Day 5: Shutter Speed
      {
        'id': 'lesson_005',
        'day': 5,
        'title': 'Shutter Speed',
        'subtitle': 'Freezing and Showing Motion',
        'description':
            'Learn how shutter speed controls motion and creates dynamic effects in photography.',
        'content': '''**📸 What is Shutter Speed?**

**Shutter speed** means **how fast or slow** your camera takes a photo.

👉 Imagine your camera's shutter like an **eyelid**:
• Blink quickly = freezes moment (fast shutter)
• Blink slowly = captures movement (slow shutter)

It's measured in seconds or fractions:
• **1/1000 sec** = very fast
• **1/30 sec** = slower  
• **1 sec or more** = very slow

⏱️ Common Shutter Speeds:
• 1/4000 (very fast)
• 1/500
• 1/125
• 1/30
• 1 sec
• 5 sec
• 30 sec (long exposure)

**⚡ Fast Shutter Speed**

• Example: 1/1000 or 1/500 second
• Freezes fast actions: sports, birds, dancing

📸 Used in:
• Indian weddings: dancing shots
• Wildlife and street photos
• Kids playing, splashing water
• Sports like cricket, football

✅ Best in good light or daylight

**🐢 Slow Shutter Speed**

• Example: 1/10 sec, 1 sec, 5 sec
• Shows motion blur: car lights, waterfalls, people moving

📸 Used in:
• Light trails during Diwali, Christmas, or New Year
• Waterfalls in hills (like Himachal, Kerala)
• Holi celebrations with color flying
• Fire dance in village fairs

📌 Use a **tripod or stable surface** to avoid blurry photos with slow shutter.

**💡 Shutter Speed and Light**

• **Fast shutter** = less light enters = darker image
• **Slow shutter** = more light enters = brighter image

You must adjust **ISO and Aperture** to keep the photo well-lit.

**🗺️ Indian & Global Examples**

• 🇮🇳 **India**:
  - Wedding photographers use both fast and slow speeds
  - Monsoon: capturing water splashes (fast) or rain trails (slow)
  - Devotional events like Aarti or festivals with fire/dance

• 🌍 **Global**:
  - Light trails in cities like Tokyo, New York
  - Northern lights in long exposures (5+ sec)
  - Sports and action shots in Olympics, football matches''',
        'estimatedDuration': 30,
        'type': 'theory',
        'difficulty': 'beginner',
        'categories': ['Technical Settings', 'Motion', 'Creative Effects'],
        'objectives': [
          'Understand how shutter speed affects motion',
          'Learn to freeze action with fast shutter speeds',
          'Create motion blur effects with slow shutter speeds',
          'Master the relationship between shutter speed and light',
        ],
        'exercises': [
          {
            'id': 'exercise_005_01',
            'title': 'Motion Control Practice',
            'description':
                'Experiment with different shutter speeds to control motion in your photos',
            'steps': [
              'Find something moving (person walking, fan, bike)',
              'Take a photo with fast shutter (1/1000) to freeze motion',
              'Take the same subject with slow shutter (1/10 or 1 sec)',
              'Compare which one is sharp vs which has motion blur',
              'Try night shots with light trails from cars or candles',
            ],
            'requirements': {
              'camera': 'Camera with manual shutter control',
              'subjects': 'Moving objects or people',
              'support': 'Tripod or stable surface for slow shutter',
              'time': '35 minutes',
            },
            'estimatedTime': 35,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Shutter Speed': 'How fast your camera takes the photo',
            'Motion Blur': 'Soft lines or movement in photo',
            'Fast Shutter': 'Freezes motion',
            'Slow Shutter': 'Shows movement',
            'Tripod': 'Stand to keep the camera steady',
            'Long Exposure': 'Very slow shutter photo (1 sec or more)',
            'Light Trails': 'Streaks of moving lights (cars, candles)',
          },
          'quote': 'Sometimes blur tells a better story than clarity.',
        },
      },

      // Day 6: The Exposure Triangle
      {
        'id': 'lesson_006',
        'day': 6,
        'title': 'The Exposure Triangle',
        'subtitle': 'Balancing Light in Photography',
        'description':
            'Master the relationship between ISO, Aperture, and Shutter Speed for perfect exposure.',
        'content': '''**🔺 What is the Exposure Triangle?**

The **Exposure Triangle** is made of three main settings that control how your photo looks:

1. **ISO** -- Light sensitivity
2. **Aperture** -- Size of lens opening (f-number)  
3. **Shutter Speed** -- How long light hits the camera sensor

Each one affects **exposure** (how bright/dark your photo is).

📸 **Perfect photo = Proper balance of all three**

**🧠 How Each Part Works**

| Setting | What it Does | Affects |
|---------|-------------|---------|
| ISO | Sensitivity to light | Brightness & noise |
| Aperture (f/) | Size of lens opening | Brightness & blur |
| Shutter Speed | Time light is captured | Brightness & motion |

**⚖️ Balance Examples:**

1. **Bright day photo**:
   • ISO 100
   • f/11  
   • Shutter 1/1000 sec

2. **Indoor low light**:
   • ISO 800
   • f/2.8
   • Shutter 1/60 sec

3. **Creative motion photo (light trails)**:
   • ISO 100
   • f/8
   • Shutter 5 sec

4. **Portrait with background blur**:
   • ISO 200
   • f/1.8
   • Shutter 1/500 sec

**🚦 What Happens if You Don't Balance?**

• Too much light = **Overexposed** (photo is too bright, no detail)
• Too little light = **Underexposed** (photo is too dark, no clarity)
• Wrong combo = blur, grainy images, or harsh shadows

✅ Always check your **exposure meter** in camera. It helps guide you to neutral (0).

**🎥 Exposure Triangle in Video**

Just like photos, exposure triangle applies to video:
• ISO = brightness
• Aperture = depth + brightness  
• Shutter speed = motion smoothness

🎬 Common video rule: **Shutter Speed = 2x Frame Rate**
• If filming at 30fps → shutter = 1/60 sec

**🇮🇳 Indian + Global Use Examples**

• **Indian temples** (dim light): ISO 1600, f/2.8, 1/60 sec
• **Outdoor dance** (bright sun): ISO 100, f/4, 1/2000 sec
• **Global city lights**: Long exposure with tripod -- ISO 100, f/11, 10 sec
• **Wedding portraits**: Soft blur with wide aperture and low ISO''',
        'estimatedDuration': 35,
        'type': 'theory',
        'difficulty': 'beginner',
        'categories': ['Technical Settings', 'Exposure', 'Balance'],
        'objectives': [
          'Understand the relationship between ISO, Aperture, and Shutter Speed',
          'Learn to balance exposure settings for different scenarios',
          'Recognize overexposed and underexposed photos',
          'Apply exposure triangle principles to both photo and video',
        ],
        'exercises': [
          {
            'id': 'exercise_006_01',
            'title': 'Exposure Triangle Practice',
            'description':
                'Practice balancing the three exposure settings in different lighting conditions',
            'steps': [
              'Take a photo with high ISO, low shutter speed (ISO 1600 / f/5.6 / 1/20)',
              'Take the same subject with wide aperture, medium ISO (ISO 400 / f/1.8 / 1/200)',
              'Create a fully balanced setup for the same scene',
              'Compare which is too bright, too dark, or has better blur',
              'Try filming a short video using the 2x frame rate rule',
            ],
            'requirements': {
              'camera': 'Manual camera controls',
              'subjects': 'Various lighting scenarios',
              'time': '40 minutes',
            },
            'estimatedTime': 40,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Exposure': 'How bright or dark a photo is',
            'Overexposed': 'Too bright photo',
            'Underexposed': 'Too dark photo',
            'Exposure Meter': 'Shows if photo is correctly exposed',
            'Balance': 'Keeping ISO, aperture, shutter in harmony',
            'ND Filter': 'Reduces light entering lens (for video)',
          },
          'quote': 'A good photo is not just light -- it\'s balanced light.',
        },
      },

      // Day 7: White Balance
      {
        'id': 'lesson_007',
        'day': 7,
        'title': 'White Balance',
        'subtitle': 'Getting Natural Colors in Your Photos',
        'description':
            'Learn how to correct colors and use white balance creatively in different lighting conditions.',
        'content': '''**🌈 What is White Balance?**

White Balance (WB) helps make **colors look natural** in a photo.

Different light sources have different **color temperatures**:
• A candle gives a warm orange light 🔥
• Tube lights give cool blue light ❄️

Without white balance, your photo might look too yellow or too blue.

📷 WB adjusts the camera to match the color of light.

**🌡️ Color Temperature Basics**

Color is measured in **Kelvin (K)**:

| Light Source | Color Temp (Kelvin) | Color Tone |
|--------------|-------------------|------------|
| Candle Light | 1000-2000K | Very Warm |
| Tungsten Bulb | 2500-3200K | Warm |
| Sunrise/Sunset | 3000-4000K | Golden |
| Daylight | 5000-5500K | Neutral |
| Cloudy Sky | 6000-7000K | Cool |
| Shade/Overcast | 7000-9000K | Very Cool |

🎨 Cooler color = more blue
🔥 Warmer color = more orange

**⚙️ Common White Balance Modes**

Most cameras and phones offer these WB presets:
• **Auto WB (AWB)**: Let camera decide
• **Daylight** ☀️: Use in sunlight
• **Cloudy** ☁️: Adds warmth  
• **Tungsten/Incandescent** 💡: Reduces yellow indoor light
• **Fluorescent**: Fixes blue-green tones
• **Shade**: Warms up cool shadow light
• **Custom / Kelvin**: You set exact color temperature

📌 Tip: Try each setting to understand the change it makes.

**📱 White Balance in Mobile and DSLR**

• 📱 On phones: Use apps like Lightroom or Pro Mode for WB
• 📷 DSLRs: You can set WB manually or even choose Kelvin value (advanced)
• 🎥 Video: Set white balance manually to keep color consistent in clips

📸 RAW format allows you to fix white balance easily in editing

**🧠 Creative Use of White Balance**

White balance isn't just correction -- it's also **creativity**:

🎨 You can use incorrect WB for creative effects:
• **Cool tone** for a night or sad mood
• **Warm tone** for happy or vintage scenes

📸 Many fashion photographers use **warmer WB** for golden glow.

**🇮🇳 Indian + Global Photography Use**

• **Indian weddings**: Often use warm lights → set to Tungsten or Kelvin ~3200K
• **Outdoor shoots in golden hour**: Daylight WB gives best colors
• **Fashion shoots with mixed lighting**: Use Custom WB or shoot RAW
• **Night photography**: Manual WB avoids strange color shifts from street lamps''',
        'estimatedDuration': 25,
        'type': 'theory',
        'difficulty': 'beginner',
        'categories': ['Technical Settings', 'Color', 'Light Quality'],
        'objectives': [
          'Understand what white balance is and why it matters',
          'Learn different white balance modes and when to use them',
          'Master color temperature and Kelvin scale basics',
          'Use white balance creatively for mood and atmosphere',
        ],
        'exercises': [
          {
            'id': 'exercise_007_01',
            'title': 'White Balance Comparison',
            'description':
                'Test different white balance settings to see their effects on color',
            'steps': [
              'Take the same photo in 5 different White Balance modes: Auto, Daylight, Tungsten, Cloudy, Custom',
              'Compare which looks too blue or too yellow',
              'Identify which feels closest to natural colors',
              'Try indoor, outdoor, and sunset lighting',
              'Create a mood photo using incorrect WB for artistic effect',
            ],
            'requirements': {
              'camera': 'Camera with white balance controls',
              'lighting': 'Various light sources (indoor, outdoor, mixed)',
              'time': '30 minutes',
            },
            'estimatedTime': 30,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'White Balance': 'Makes colors look natural in different light',
            'Kelvin (K)': 'Unit to measure color temperature',
            'Auto WB': 'Camera automatically sets white balance',
            'Color Cast': 'Unwanted color tone (too blue, too yellow)',
            'Custom WB': 'Manually adjusted white balance',
            'Warm Tone': 'Yellow-orange coloring',
            'Cool Tone': 'Blue coloring',
          },
          'quote':
              'Light has color -- and white balance helps you show it truthfully.',
        },
      },

      // Day 8: Understanding Natural Light
      {
        'id': 'lesson_008',
        'day': 8,
        'title': 'Understanding Natural Light',
        'subtitle': 'Morning vs Noon vs Evening',
        'description':
            'Learn how natural light changes throughout the day and when to shoot for the best results.',
        'content': '''**🌞 What is Natural Light?**

Natural light is the light that comes from the **sun**. Unlike artificial lights (like bulbs or LEDs), it changes all day long.

As a beginner, learning how sunlight works will help you decide **when** to shoot and how your photos will look.

**🕗 How Light Changes Through the Day**

| Time of Day | Light Type | Characteristics | Best For |
|-------------|------------|----------------|----------|
| Morning (6-9am) | Soft, Golden Light | Warm tones, long shadows | Portraits, landscapes |
| Noon (11am-2pm) | Harsh, Bright | Strong light, hard shadows, white tone | Product shots (with diffuser) |
| Evening (4-6pm) | Soft, Warm Light | Similar to morning, golden tone | Portraits, outdoor shoots |
| Golden Hour | Softest Golden | 1 hour after sunrise / before sunset | Dreamy portraits, nature |
| Blue Hour | Cool, Soft Blue | After sunset / before sunrise | Cityscapes, creative low light |

**☀️ Why Time Matters**

The **quality of sunlight** affects your image:
• **Soft Light** (morning/evening): smooth shadows, gentle skin tones
• **Harsh Light** (midday): deep shadows, high contrast, not ideal for portraits

📸 Beginners tip: Start shooting early morning or late afternoon for easier, beautiful light.

**🌏 Indian + Global Examples**

• **India (Varanasi Ghats, sunrise)** -- Soft fog + golden tones
• **South India temples at noon** -- Use shaded areas or reflectors  
• **Desert sunset in Rajasthan** -- Rich, warm tones perfect for silhouettes
• **Global** -- Eiffel Tower at golden hour, NYC at blue hour

**🎥 Light & Video**

• Morning/evening light gives a soft, cinematic look
• Use a **reflector** to bounce light in shadow areas
• Avoid midday unless using diffusers or shaded areas

**🌤️ Weather and Natural Light**

• **Cloudy days**: Act like a giant softbox, perfect for portraits
• **Rainy days**: Dramatic mood, great for moody shots
• **Clear sunny days**: Best for landscapes but harsh for people
• **Overcast**: Even, soft light for any subject''',
        'estimatedDuration': 20,
        'type': 'theory',
        'difficulty': 'beginner',
        'categories': ['Natural Light', 'Time of Day', 'Light Quality'],
        'objectives': [
          'Understand how natural light changes throughout the day',
          'Learn the best times to shoot for different subjects',
          'Recognize golden hour and blue hour opportunities',
          'Master working with different weather conditions',
        ],
        'exercises': [
          {
            'id': 'exercise_008_01',
            'title': 'Natural Light Timeline',
            'description':
                'Document how natural light changes by photographing the same subject at different times',
            'steps': [
              'Choose one subject (person, object, or scene)',
              'Photograph it in morning light (before 9am)',
              'Photograph it at midday (around 1pm)',
              'Photograph it in evening light (after 4pm)',
              'Compare soft shadows vs harsh shadows',
              'Try to capture during golden hour if possible',
            ],
            'requirements': {
              'subject': 'Same subject for all shots',
              'timing': 'Different times of day',
              'location': 'Outdoor or window light',
              'time': 'Throughout the day',
            },
            'estimatedTime': 60,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Natural Light': 'Light from the sun',
            'Golden Hour':
                'Soft warm light just after sunrise or before sunset',
            'Harsh Light': 'Strong bright light that creates hard shadows',
            'Soft Light': 'Gentle light with smooth shadows',
            'Blue Hour': 'Cool soft light just after sunset',
          },
          'quote':
              'Light is the soul of photography. Natural light gives it life.',
        },
      },

      // Day 9: Artificial Light Basics
      {
        'id': 'lesson_009',
        'day': 9,
        'title': 'Artificial Light Basics',
        'subtitle': 'Lamps, Phone Lights, LED',
        'description':
            'Learn to work with artificial light sources and create professional-looking photos at home.',
        'content': '''**💡 What is Artificial Light?**

Artificial light is any **non-natural** light source -- created by humans, like:
• LED panels
• Tube lights
• Lamps
• Mobile flashlight
• Ring lights

This light can be used **anytime**, even at night or indoors.

**🔦 Types of Artificial Light Sources**

| Light Type | Example Use | Characteristics |
|------------|-------------|----------------|
| LED Lights | Portraits, Product shoots | Energy-efficient, bright, adjustable color temp |
| Ring Light | Selfies, Beauty shots | Soft, even light, great for faces |
| Mobile Flashlight | Quick lighting, on the go | Hard, direct light |
| Lamps | Home portraits, indoor mood | Warm tone, soft if diffused |
| Tube Light | Room lighting | Flat, bright, can be harsh |

📸 Tip: Use white paper or cloth to **soften harsh lights**.

**🔄 Hard Light vs Soft Light**

| Type | How It Looks | When to Use |
|------|-------------|-------------|
| Hard Light | Sharp shadows, contrast | Dramatic portraits, fashion |
| Soft Light | Smooth, low shadows | Portraits, beauty, storytelling |

🎨 Soft light is better for beginners. Use **diffusers** or bounce light off walls.

**🔁 Mixing Natural + Artificial Light**

Many photographers use both.
• Shoot near a **window** with a **lamp** or **LED fill light**
• Balance the **color temperature** (cool light + warm light = balance)
• Use white balance setting to match the mix

**🇮🇳 Indian + Global Examples**

• **Mobile phone flash** at Indian festivals or street portraits
• **Ring light** for makeup/fashion reels on Instagram
• **LED panels** in wedding events or indoor mandaps
• **Global** -- studio setups for YouTube creators and fashion bloggers

**🎥 Artificial Light in Video**

• LED lights are great for continuous lighting
• Add softboxes or umbrellas to make video light natural
• Use **practical lights** (lamps, fairy lights) for background interest

**💡 DIY Lighting Setup at Home**

• **Soft key light**: Table lamp + white sheet/tissue paper
• **Fill light**: Phone flashlight + bounce off white wall
• **Background light**: LED strip or fairy lights
• **Reflector**: White cardboard or bedsheet''',
        'estimatedDuration': 25,
        'type': 'theory',
        'difficulty': 'beginner',
        'categories': ['Artificial Light', 'DIY Setup', 'Light Control'],
        'objectives': [
          'Understand different types of artificial light sources',
          'Learn to create soft light from hard sources',
          'Master mixing artificial and natural light',
          'Set up basic lighting at home with common items',
        ],
        'exercises': [
          {
            'id': 'exercise_009_01',
            'title': 'DIY Lighting Experiment',
            'description':
                'Create professional-looking photos using common household lights',
            'steps': [
              'Try mobile torch + tissue paper for makeshift soft light',
              'Use ring light or table lamp + white wall bounce',
              'Mix natural window light + one artificial light',
              'Compare which looks softest on faces',
              'Create a short photo series using only artificial lights',
            ],
            'requirements': {
              'lights': 'Mobile flashlight, lamps, or LED lights',
              'diffusers': 'Tissue paper, white cloth, or wall',
              'subject': 'Person or object to light',
              'time': '30 minutes',
            },
            'estimatedTime': 30,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Artificial Light':
                'Light from human-made sources like bulbs or LEDs',
            'Diffuser': 'Material that softens harsh light',
            'Hard Light': 'Strong light with deep shadows',
            'Soft Light': 'Gentle light with smooth shadows',
            'Fill Light': 'Extra light to brighten dark parts',
          },
          'quote':
              'You don\'t need expensive gear to light a scene -- just creativity.',
        },
      },

      // Day 10: Rule of Thirds
      {
        'id': 'lesson_010',
        'day': 10,
        'title': 'Rule of Thirds',
        'subtitle': 'Easy Composition Hack',
        'description':
            'Master the most fundamental composition technique to make your photos more engaging.',
        'content': '''**📏 What is the Rule of Thirds?**

The Rule of Thirds is a simple way to **compose a photo**.

Imagine breaking your image into 9 equal parts using 2 vertical and 2 horizontal lines:

```
|---|---|---|
|---|---|---|
|---|---|---|
```

The 4 points where these lines cross are called **focus points**. Placing your subject on these points makes your photo more balanced and interesting.

📸 Most cameras and phones allow you to turn on this grid in settings.

**🎯 Why Use the Rule of Thirds?**

• Draws attention naturally
• Creates space and balance
• Looks more professional
• Avoids placing the subject directly in the center (which can look boring)

✅ Tip: For landscapes, place the **horizon** on top or bottom third -- not the middle.

**📌 How to Use It**

• Place **eyes** of a person on the top third
• Place **a tree or building** on the left or right third  
• Use the **empty space** to tell more story

Use the grid to plan your shot **before pressing the shutter**.

**🇮🇳 Indian + Global Examples**

• **Taj Mahal framed on right third**, sky on left
• **Indian bride** off-center, background blurred
• **Sunset in Goa** with sun placed on lower third
• **Eiffel Tower** or **New York skyline** following this rule for depth

**🎥 Rule of Thirds in Video**

• Keep speaker's eyes at top third
• Use thirds to lead viewer's eye across the frame
• Helps keep interviews balanced and natural

**🔄 When to Break the Rule**

Rules are made to be broken! Sometimes center composition works better:
• Symmetrical subjects (like reflections)
• Patterns or textures
• When you want to create tension or focus
• Portrait photography with strong eye contact

But learn the rule first before breaking it creatively.''',
        'estimatedDuration': 20,
        'type': 'theory',
        'difficulty': 'beginner',
        'categories': ['Composition', 'Framing', 'Visual Design'],
        'objectives': [
          'Understand the Rule of Thirds concept',
          'Learn to use gridlines for better composition',
          'Practice placing subjects on focus points',
          'Know when to follow and when to break the rule',
        ],
        'exercises': [
          {
            'id': 'exercise_010_01',
            'title': 'Rule of Thirds Practice',
            'description':
                'Apply the Rule of Thirds to different types of photography',
            'steps': [
              'Turn on gridlines in your camera/phone settings',
              'Take a portrait with eyes on the top third line',
              'Take a landscape with horizon on top or bottom third',
              'Take a photo of an object placed on left or right third',
              'Take the same 3 shots with subjects in the center',
              'Compare which compositions look more dynamic',
            ],
            'requirements': {
              'camera': 'Any camera with grid option',
              'subjects': 'Person, landscape, and object',
              'time': '25 minutes',
            },
            'estimatedTime': 25,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Rule of Thirds': 'Guideline that divides image into 9 parts',
            'Focus Points': 'Cross points of the 9-part grid',
            'Composition': 'How elements are arranged in a photo',
            'Gridlines': 'Lines on screen that help frame your shot',
            'Framing': 'Positioning your subject inside the photo',
          },
          'quote':
              'Learn the rules like a pro, so you can break them like an artist. -- Pablo Picasso',
        },
      },

      // Day 11: Leading Lines, Framing & Balance
      {
        'id': 'lesson_011',
        'day': 11,
        'title': 'Leading Lines, Framing & Balance',
        'subtitle': 'Advanced Composition Techniques',
        'description':
            'Learn to use leading lines, natural framing, and visual balance to create compelling photographs.',
        'content': '''**➿ What are Leading Lines?**

Leading lines are lines that guide the viewer's eyes through the photo. They **lead attention** to the main subject.

They can be:
• Roads  • Rivers  • Walls  • Handrails  • Bridges  • Light or shadow patterns

📸 Use these lines to point toward your subject, making the photo more interesting and focused.

**🖼️ What is Framing in Photography?**

Framing means using **objects around your subject** to draw attention to it.
Like: • A window frame  • Tree branches  • Doorways  • Arches

It gives depth and helps separate the subject from the background.

📷 Tip: Shoot through something to add framing.

**⚖️ What is Balance in a Photo?**

Balance means that your photo **feels stable**. It's not too heavy on one side.
You can balance your photo by:
• Putting a subject on one side + empty space on the other
• Using color or brightness to balance objects
• Making sure the visual weight is even

Balance is not always symmetry. It's about feeling right.

**🇮🇳 Indian + Global Examples**

• **Indian railway tracks** leading to a far temple = leading lines
• **Bride under arch doorway** = framing
• **Colorful street art** + empty wall = visual balance
• **European alleyways** as leading lines to subjects
• **Desert roads** in Rajasthan for travel photos

**🎥 Video Composition**

• Use leading lines in streets to guide the eye
• Frame interviews using doorways or background items
• Keep background and subject balanced in frame''',
        'estimatedDuration': 25,
        'type': 'theory',
        'difficulty': 'beginner',
        'categories': ['Composition', 'Visual Design', 'Advanced Techniques'],
        'objectives': [
          'Use leading lines to guide viewer attention',
          'Create natural frames within your compositions',
          'Achieve visual balance in your photographs',
          'Combine multiple composition techniques effectively',
        ],
        'exercises': [
          {
            'id': 'exercise_011_01',
            'title': 'Composition Techniques Practice',
            'description':
                'Apply leading lines, framing, and balance in your photography',
            'steps': [
              'Find and photograph leading lines (roads, railings, walls)',
              'Create a frame within your photo (shoot through something)',
              'Practice visual balance with subjects and empty space',
              'Combine multiple techniques in one photo',
              'Use mirrors or windows for creative framing',
            ],
            'requirements': {
              'subjects': 'Various scenes with natural lines and frames',
              'locations': 'Indoor and outdoor environments',
              'time': '35 minutes',
            },
            'estimatedTime': 35,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Leading Lines': 'Lines that guide eyes to the main subject',
            'Framing': 'Using surroundings to draw focus on your subject',
            'Balance': 'Equal visual weight in photo',
            'Depth': 'Sense of distance in a photo',
            'Composition': 'How photo elements are arranged',
          },
          'quote':
              'Great photos don\'t just show things---they lead your eyes and tell a story.',
        },
      },

      // Day 12: Backgrounds & Color
      {
        'id': 'lesson_012',
        'day': 12,
        'title': 'Backgrounds & Color in Photography',
        'subtitle': 'Making Your Subject Stand Out',
        'description':
            'Master the use of backgrounds and color to create impactful and emotionally resonant photographs.',
        'content': '''**🧱 Why Backgrounds Matter**

A background can make or break a photo. A **clean and simple background** makes your subject stand out.

Avoid: • Messy rooms • Crowds • Distracting elements (like poles or trash)
Instead, choose: • Plain walls • Nature (trees, sky) • Colorful but not busy backgrounds

**🎨 Using Color in Photos**

Color affects the mood and feel of your photo.

| Color | Feel / Mood | Use In |
|-------|------------|--------|
| Red | Bold, Passionate | Fashion, Action, Festivals |
| Blue | Calm, Sad, Peaceful | Nature, Portraits |
| Yellow | Happy, Bright | Outdoor, Kids |
| Black/White | Dramatic, Classic | Fashion, Street, Artistic |
| Green | Nature, Fresh | Landscapes, Outdoors |

🎯 Use color to match the story you want to tell.

**🪄 Subject vs Background**

Make sure your subject doesn't **blend in** with the background.

📌 Tips:
• Use opposite colors (red outfit + green background)
• Use blur (shallow depth of field)
• Keep background clean

**🇮🇳 Indian + Global Examples**

• Indian bride in red against neutral temple walls = contrast
• Holi colors with plain sky background = focus on action
• French street art with model in black = strong contrast''',
        'estimatedDuration': 20,
        'type': 'theory',
        'difficulty': 'beginner',
        'categories': ['Color Theory', 'Backgrounds', 'Visual Impact'],
        'objectives': [
          'Choose appropriate backgrounds for your subjects',
          'Use color psychology to enhance your photos',
          'Create contrast between subject and background',
          'Apply color theory to storytelling',
        ],
        'exercises': [
          {
            'id': 'exercise_012_01',
            'title': 'Background and Color Practice',
            'description':
                'Experiment with different backgrounds and color combinations',
            'steps': [
              'Take a photo with a messy background',
              'Take the same subject with a clean background',
              'Create strong color contrast between subject and background',
              'Try a black & white version to study composition',
              'Experiment with different colored backgrounds',
            ],
            'requirements': {
              'subjects': 'Various subjects with different backgrounds',
              'colors': 'Different colored backgrounds or clothing',
              'time': '25 minutes',
            },
            'estimatedTime': 25,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Background': 'What\'s behind your subject',
            'Contrast': 'Strong difference in color or light',
            'Color Theory': 'How colors work together',
            'Visual Mood': 'Feeling created by color and tone',
            'Clean Shot': 'A photo without distractions',
          },
          'quote':
              'A good background supports the subject like a stage supports a performer.',
        },
      },

      // Day 13: Practice Day
      {
        'id': 'lesson_013',
        'day': 13,
        'title': 'Practice Day',
        'subtitle': 'Shoot a Story in 5 Photos',
        'description':
            'Apply everything you\'ve learned to create a cohesive photo story that demonstrates your growing skills.',
        'content': '''**📖 What is a Photo Story?**

A photo story is a **series of photos** that together tell a complete idea or feeling. You don't need fancy gear---just good planning and observation.

**🧭 How to Plan Your Story**

Choose a topic like:
• A day in your life  • A local market  • Preparing a dish  • A small festival event

Plan:
1. Wide Shot (shows the scene)
2. Medium Shot (shows subject in environment)  
3. Close-up (details)
4. Action Shot (movement or emotion)
5. Final/Ending Shot (wraps the story)

**📷 Story Structure**

• **Beginning**: Set the scene, establish context
• **Middle**: Show the main action or subject
• **Details**: Capture important small elements
• **Emotion**: Include human connection or feeling
• **End**: Provide closure or conclusion

**🎬 Tips for Storytelling**

• Keep your story simple and focused
• Think of beginning, middle, and end
• Use light and color to support your narrative
• One strong emotion = one great story
• Don't try to tell everything - focus on one main idea''',
        'estimatedDuration': 60,
        'type': 'project',
        'difficulty': 'beginner',
        'categories': ['Storytelling', 'Project Work', 'Creative Practice'],
        'objectives': [
          'Plan and execute a complete photo story',
          'Apply composition and technical skills together',
          'Create emotional connection through photography',
          'Develop narrative thinking in visual work',
        ],
        'exercises': [
          {
            'id': 'exercise_013_01',
            'title': '5-Photo Story Project',
            'description':
                'Create a complete story using exactly 5 photographs',
            'steps': [
              'Choose a simple story topic from your daily life',
              'Plan your 5 shots: wide, medium, close-up, action, ending',
              'Shoot your story using natural light only',
              'Review and select your best 5 images',
              'Arrange them in storytelling order',
              'Share with someone and ask what story they see',
            ],
            'requirements': {
              'story_topic': 'Simple, personal narrative',
              'shots': 'Exactly 5 photos',
              'editing': 'Minimal editing only',
              'time': '60 minutes',
            },
            'estimatedTime': 60,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Photo Story': 'Series of images that tell a complete narrative',
            'Narrative': 'The story or sequence of events',
            'Visual Flow': 'How images work together in sequence',
            'Story Arc': 'Beginning, middle, and end structure',
            'Context': 'Background information that helps understanding',
          },
          'quote':
              'A camera tells more truth in five frames than a paragraph of words.',
        },
      },

      // Day 14: Feedback & Self-Review
      {
        'id': 'lesson_014',
        'day': 14,
        'title': 'Feedback & Self-Review',
        'subtitle': 'Improve Your Shots',
        'description':
            'Learn to critically evaluate your own work and seek constructive feedback for continuous improvement.',
        'content': '''**🧐 Why Review Matters**

Looking at your own photos after the shoot helps you learn. Every photo teaches you:
• What worked  • What didn't  • What to do next time

**📋 Checklist for Reviewing a Photo**

✅ Is the subject clear?
✅ Is the lighting good?
✅ Is the photo balanced?
✅ Any distractions in the background?
✅ Does it tell a story or emotion?

**🙋 How to Ask for Feedback**

Ask friends or other photographers:
• What do you feel when you see this photo?
• Is the subject clear?
• What would you improve?

📌 Don't ask "Is it good?" --- ask specific questions.

**🛠️ How to Improve**

• Practice based on feedback
• Re-shoot your weak photos
• Try editing for better result
• Keep old photos to compare your growth

**📈 Self-Assessment Questions**

• What was I trying to achieve with this photo?
• Did I succeed in my goal?
• What technical aspects worked well?
• What would I do differently next time?
• How does this compare to my earlier work?''',
        'estimatedDuration': 30,
        'type': 'review',
        'difficulty': 'beginner',
        'categories': ['Self-Assessment', 'Feedback', 'Improvement'],
        'objectives': [
          'Develop critical evaluation skills for your own work',
          'Learn to ask for and receive constructive feedback',
          'Create improvement plans based on analysis',
          'Track your progress over time',
        ],
        'exercises': [
          {
            'id': 'exercise_014_01',
            'title': 'Photo Review and Feedback Session',
            'description':
                'Critically analyze your recent work and gather feedback',
            'steps': [
              'Select 5 photos from Day 13 project',
              'Review them using the checklist criteria',
              'Ask a friend or family member for their feedback',
              'Identify one photo to re-shoot based on feedback',
              'Re-shoot that photo with improvements',
              'Compare original vs improved version',
            ],
            'requirements': {
              'photos': '5 recent photos for review',
              'feedback_source': 'Friend, family member, or online community',
              'time': '45 minutes',
            },
            'estimatedTime': 45,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Feedback': 'Helpful opinion to improve',
            'Review': 'Look again with focus',
            'Critique': 'Friendly analysis',
            'Self-Assessment': 'Evaluating your own work',
            'Improvement': 'Making something better',
          },
          'quote': 'Your best photo is the one you understand the most.',
        },
      },

      // Day 15: Portrait Photography at Home
      {
        'id': 'lesson_015',
        'day': 15,
        'title': 'Portrait Photography at Home',
        'subtitle': 'Using Window Light',
        'description':
            'Master the art of portrait photography using natural window light and simple home setups.',
        'content': '''**🌞 Why Window Light Is Powerful**

Window light is soft, free, and creates a natural look. It wraps gently around the face, giving depth and beauty.

🕒 Best Time: Morning or late evening
📍 Setup: Near a window, curtains for softening light

🪟 Window light helps you learn:
• Direction of light  • Shadow vs highlight  • Mood and emotion through angles

**🧍 Posing + Emotion**

Try these beginner-friendly poses:
• Seated by the window, looking outside
• Looking toward light for drama
• Using a prop (cup, book, dupatta)

Let your subject relax. Talk to them. Get natural expressions.

**💡 Window Light Techniques**

• **Front lighting**: Subject faces the window (even, soft light)
• **Side lighting**: Subject at 45° to window (dramatic shadows)
• **Back lighting**: Subject between you and window (rim light, silhouettes)
• **Diffused lighting**: Use sheer curtains to soften harsh sunlight

**🇮🇳 Indian Context**

• Grandmother in saree near jharokha
• Child by balcony light
• Portrait using morning pooja light
• Traditional clothing with cultural window frames

**📸 Camera Settings for Window Portraits**

• Use wide aperture (f/1.8-f/2.8) for background blur
• Focus on the eyes closest to camera
• Expose for the face, not the bright window
• Use reflector (white paper/cloth) to fill shadows''',
        'estimatedDuration': 35,
        'type': 'practice',
        'difficulty': 'beginner',
        'categories': ['Portrait Photography', 'Natural Light', 'Home Studio'],
        'objectives': [
          'Master window light for portrait photography',
          'Learn basic posing and direction techniques',
          'Create professional-looking portraits at home',
          'Understand light direction and its effects',
        ],
        'exercises': [
          {
            'id': 'exercise_015_01',
            'title': 'Window Light Portrait Session',
            'description':
                'Create a variety of portrait styles using only window light',
            'steps': [
              'Take a portrait with subject facing the window',
              'Take a side-lit portrait (subject at 45° to window)',
              'Create a backlit silhouette',
              'Use soft curtain light for a gentle look',
              'Capture a smiling candid moment',
              'Try using a cultural prop or traditional clothing',
            ],
            'requirements': {
              'location': 'Near a window with good natural light',
              'subject': 'Willing person to pose',
              'props': 'Optional cultural items or simple props',
              'time': '40 minutes',
            },
            'estimatedTime': 40,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Portrait': 'A photo of a person',
            'Natural Light': 'Light from the sun',
            'Silhouette': 'Dark shape against light',
            'Rim Light': 'Light that outlines the subject',
            'Fill Light': 'Additional light to brighten shadows',
          },
          'quote':
              'The best portraits feel like they know you---even if you\'re a stranger.',
        },
      },

      // Day 16: Object/Product Photography
      {
        'id': 'lesson_016',
        'day': 16,
        'title': 'Object/Product Photography',
        'subtitle': 'Use Household Items',
        'description':
            'Learn to photograph objects and products with professional results using simple home setups.',
        'content': '''**🧴 What to Photograph**
• Jewelry • Perfume bottles • Books or spectacles • Handcrafted items (rangoli plate, diya)

**🛏️ DIY Setup Tips**
• Use white chart paper or dupatta for background
• Torch + tissue paper = soft light
• Books = tripod • CDs, foil = reflectors
🎯 Trick: Shoot by a window in daytime

**🖼️ Frame the Object**
• Keep background plain • Shoot top-down or from eye level • Leave breathing space around object

**📸 Product Photography Techniques**

• **Flat lay**: Top-down view for multiple objects
• **Eye level**: Shows object naturally as you see it
• **Low angle**: Makes object look important
• **Close-up details**: Shows texture and quality

**💡 Lighting Setup for Products**

• Window light is best for natural look
• Use white paper to bounce light and fill shadows
• Avoid direct flash - it creates harsh reflections
• Multiple angles: try rotating the object for best light

**🇮🇳 Indian Items to Practice With**

• Traditional jewelry or accessories
• Spices in small bowls
• Handmade crafts or pottery
• Cultural items like diyas or decorative plates
• Books or artistic objects

**📱 Mobile Settings for Products**

• Use macro mode if available
• Focus carefully on the main feature
• Keep steady or use a makeshift tripod
• Take multiple shots from different angles''',
        'estimatedDuration': 25,
        'type': 'practice',
        'difficulty': 'beginner',
        'categories': ['Product Photography', 'DIY Setup', 'Objects'],
        'objectives': [
          'Master product photography basics',
          'Create clean backgrounds',
          'Use natural light effectively',
          'Learn different shooting angles for objects',
        ],
        'exercises': [
          {
            'id': 'exercise_016_01',
            'title': 'Product Photography Practice',
            'description':
                'Photograph various household items with professional presentation',
            'steps': [
              'Photograph a kitchen item (spice jar)',
              'Photograph a beauty product (cream)',
              'Photograph a handmade object',
              'Try 3 angles: flat lay, eye level, creative close-up',
              'Practice with different backgrounds (white, colored, textured)',
            ],
            'requirements': {
              'items': 'Various household products',
              'setup': 'Clean background and good light',
              'backgrounds': 'White paper, cloth, or other clean surfaces',
              'time': '30 minutes',
            },
            'estimatedTime': 30,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Product Photography': 'Professional photos of objects',
            'Flat Lay': 'Top-down view of objects',
            'Macro': 'Very close-up photography',
            'Reflector': 'Surface that bounces light',
            'Background': 'Surface behind the object',
          },
          'quote': 'Even a teaspoon can shine with the right light and angle.',
        },
      },

      {
        'id': 'lesson_017',
        'day': 17,
        'title': 'Everyday Storytelling',
        'subtitle': 'Document Your Day',
        'description':
            'Learn to tell compelling photo stories using your daily life and create meaningful visual narratives.',
        'content': '''**📖 What is Visual Storytelling?**

Visual storytelling is showing a day, moment, or emotion with 3-5 photos that work together to tell a complete story.

Great stories have:
• **Beginning, middle, end**
• **Real emotion**
• **Authentic moments**
• **A clear focus or theme**

**🎒 What to Capture in Daily Life**

Your ordinary moments can become extraordinary stories:
• Making chai in morning light
• Your street view from the balcony
• Cutting vegetables for dinner
• Small interactions with family
• Evening activities or routines

**📷 Story Structure for Daily Documentation**

1. **Wide shot** -- Set the scene (your room, kitchen, street)
2. **Medium shot** -- Show the activity (person cooking, reading)
3. **Close-up** -- Detail (hands, tools, expressions)
4. **Emotion** -- Capture feelings (concentration, joy, reflection)
5. **Ending** -- Something quiet or final (finished meal, sunset)

**🇮🇳 Indian Daily Life Story Ideas**

• Morning pooja ritual in 5 frames
• Street vendor preparing food
• Grandmother's evening knitting routine
• Children playing in the courtyard
• Festival preparation at home
• Monsoon day through your window

**🎬 Tips for Authentic Storytelling**

• **Don't stage** -- capture real moments
• **Be patient** -- wait for natural emotions
• **Get close** -- don't be afraid to move closer
• **Use natural light** -- avoid flash for authentic feel
• **Focus on one main idea** -- keep it simple

**📱 Technical Tips for Story Shooting**

• Shoot in good light (near windows, outdoors)
• Keep camera steady for each shot
• Vary your angles (high, low, eye level)
• Don't over-edit -- maintain natural feel''',
        'estimatedDuration': 40,
        'type': 'practice',
        'difficulty': 'beginner',
        'categories': ['Storytelling', 'Documentary', 'Daily Life'],
        'objectives': [
          'Create compelling stories from everyday moments',
          'Master the 5-shot story structure',
          'Develop an eye for meaningful details',
          'Practice authentic documentary photography',
        ],
        'exercises': [
          {
            'id': 'exercise_017_01',
            'title': 'Daily Life Story Project',
            'description':
                'Create a complete visual story from your daily routine',
            'steps': [
              'Choose one daily activity (cooking, studying, evening walk)',
              'Plan your 5 shots: wide, medium, close-up, emotion, ending',
              'Shoot the story using only natural light',
              'Focus on real moments, not posed shots',
              'Arrange photos in storytelling sequence',
              'Share with someone without captions - can they understand the story?',
            ],
            'requirements': {
              'activity': 'Any daily routine or activity',
              'shots': 'Exactly 5 photos telling complete story',
              'lighting': 'Natural light only',
              'time': '45 minutes',
            },
            'estimatedTime': 45,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Visual Storytelling': 'Telling stories through images',
            'Documentary': 'Recording real life as it happens',
            'Authentic': 'Real and unposed moments',
            'Narrative': 'A story with beginning, middle, end',
            'Wide Shot': 'Shows entire scene or location',
          },
          'quote': 'Don\'t shoot what it looks like. Shoot what it feels like.',
        },
      },

      // Day 18: Black & White Photography
      {
        'id': 'lesson_018',
        'day': 18,
        'title': 'Black & White Photography',
        'subtitle': 'When and Why',
        'description':
            'Understand when to remove color and how black & white photography can enhance emotion and focus.',
        'content': '''**🖤 Why Black & White Photography?**

Black & white photography removes the distraction of color and helps viewers focus on:
• **Emotion and mood**
• **Shapes and patterns**
• **Light and shadows**
• **Textures and details**
• **The essence of the subject**

**🎨 When to Choose Black & White**

**Best subjects for B&W:**
• Portraits with strong emotions
• Old buildings and monuments
• Street photography and daily life
• Dramatic weather (rain, storms, fog)
• High contrast scenes
• Busy markets (removes color clutter)
• Textures (fabric, wood, skin, walls)

**When to keep color:**
• Flowers and nature (color is the story)
• Food photography
• Festivals and celebrations
• Fashion with important color elements

**📷 What Makes a Good B&W Photo**

• **Strong contrast** between light and dark areas
• **Interesting textures** and patterns
• **Clear subject** that stands out
• **Good composition** (rule of thirds, leading lines)
• **Emotional connection** or story

**🇮🇳 Indian Subjects Perfect for B&W**

• Old heritage buildings and forts
• Portraits of elderly people with character lines
• Monsoon scenes with dramatic clouds
• Street vendors and market scenes
• Religious ceremonies and rituals
• Rural life and farming activities
• Traditional crafts and artisans at work

**📱 Converting to Black & White**

**In camera:** Most phones have B&W mode in camera settings
**In editing:** Convert color photos using:
• Phone gallery editor
• Snapseed: Tools > Black & White
• Instagram filters
• Lightroom Mobile

**✨ B&W Editing Tips**

• Increase contrast slightly for drama
• Adjust highlights and shadows
• Don't over-sharpen
• Keep some detail in both bright and dark areas
• Experiment with different B&W styles (high contrast, soft, vintage)''',
        'estimatedDuration': 25,
        'type': 'theory',
        'difficulty': 'beginner',
        'categories': [
          'Black & White',
          'Artistic Expression',
          'Post-Processing',
        ],
        'objectives': [
          'Understand when and why to use black & white',
          'Learn to see scenes without color',
          'Master contrast and texture in B&W photography',
          'Convert and edit black & white photos effectively',
        ],
        'exercises': [
          {
            'id': 'exercise_018_01',
            'title': 'Black & White Photography Practice',
            'description':
                'Create powerful black & white images focusing on emotion and composition',
            'steps': [
              'Take a portrait focusing on emotion and character',
              'Photograph textures (fabric, wall, hands, wood)',
              'Capture architecture or old buildings',
              'Shoot a busy scene (market, street) and see how B&W simplifies it',
              'Convert all to black & white and compare with color versions',
              'Adjust contrast and shadows for better drama',
            ],
            'requirements': {
              'subjects': 'Portrait, texture, architecture, busy scene',
              'editing': 'Convert to B&W and adjust contrast',
              'comparison': 'Compare B&W vs color versions',
              'time': '35 minutes',
            },
            'estimatedTime': 35,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Contrast': 'Difference between light and dark areas',
            'Texture': 'Surface quality you can see or feel',
            'Highlights': 'Brightest parts of the photo',
            'Shadows': 'Darkest parts of the photo',
            'Monochrome': 'Another term for black & white',
          },
          'quote': 'Color records. Black & white reveals.',
        },
      },

      // Day 19: Mobile Photography Like DSLR
      {
        'id': 'lesson_019',
        'day': 19,
        'title': 'How to Shoot with Mobile Like a DSLR',
        'subtitle': 'Manual Controls and Pro Techniques',
        'description':
            'Learn to use your mobile phone\'s manual controls to achieve professional-looking results.',
        'content': '''**📱 Unlocking Your Phone's Potential**

Modern smartphones have powerful cameras that can create DSLR-quality photos when used correctly. The key is learning to use **manual controls** instead of just point-and-shoot auto mode.

**🔧 Finding Manual/Pro Mode**

**Android phones:** Look for "Pro", "Manual", or "Expert" mode in camera app
**iPhones:** Use third-party apps like Lightroom Mobile, ProCam, or VSCO
**Camera apps to try:**
• Lightroom Mobile (free, powerful)
• Open Camera (Android, free)
• ProCam (iOS, paid but professional)
• Footej Camera (Android)

**⚙️ Manual Settings Explained**

**ISO:** Controls brightness and grain
• Sunny day: ISO 100-200
• Indoors: ISO 400-800
• Low light: ISO 1600+ (expect some grain)

**Shutter Speed:** Controls motion and light
• Fast action: 1/500s or faster
• Portraits: 1/125s to 1/250s
• Night/low light: 1/30s or slower (use tripod)

**Focus:** Tap to focus manually
• Portrait: Focus on closest eye
• Landscape: Focus 1/3 into the scene
• Macro: Use manual focus for precision

**White Balance:** Control color temperature
• Daylight: 5500K
• Cloudy: 6500K
• Indoor tungsten: 3200K
• Shade: 7500K

**📸 DSLR-Style Techniques with Mobile**

**Shallow Depth of Field (Background Blur):**
• Get close to subject
• Use Portrait mode if available
• Use widest aperture setting (lowest f-number)
• Create distance between subject and background

**Sharp Landscapes:**
• Use smaller aperture (higher f-number)
• Focus 1/3 into the scene
• Use tripod for sharp results
• Shoot in good light

**Action Photography:**
• Use Sport mode or fast shutter speed
• Continuous autofocus if available
• Burst mode for best shot selection
• Keep phone steady and track the action

**🇮🇳 Indian Photography Scenarios**

• **Wedding portraits:** Use Portrait mode + manual exposure
• **Street photography:** Manual focus + faster shutter
• **Monuments:** Small aperture + tripod for sharpness
• **Festivals:** High ISO + fast shutter for action
• **Food photography:** Macro focus + soft light''',
        'estimatedDuration': 30,
        'type': 'practice',
        'difficulty': 'beginner',
        'categories': [
          'Mobile Photography',
          'Manual Controls',
          'Technical Skills',
        ],
        'objectives': [
          'Master manual controls on mobile phones',
          'Achieve DSLR-like results with smartphones',
          'Understand when to use different shooting modes',
          'Create professional-looking photos with mobile',
        ],
        'exercises': [
          {
            'id': 'exercise_019_01',
            'title': 'Mobile Manual Mode Practice',
            'description':
                'Practice using manual controls to create professional-looking mobile photos',
            'steps': [
              'Download a manual camera app (Lightroom Mobile recommended)',
              'Take a bright outdoor photo using ISO 100, fast shutter',
              'Shoot an indoor portrait using higher ISO and manual focus',
              'Create background blur by getting close to subject',
              'Take a night photo using tripod and slow shutter',
              'Compare your manual shots with auto mode versions',
            ],
            'requirements': {
              'app': 'Manual camera app (Lightroom Mobile, Open Camera, etc.)',
              'scenarios': 'Outdoor, indoor, portrait, night photography',
              'comparison': 'Manual vs auto mode shots',
              'time': '40 minutes',
            },
            'estimatedTime': 40,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Manual Mode': 'You control camera settings yourself',
            'Pro Mode': 'Advanced camera controls on phone',
            'Burst Mode': 'Taking multiple photos quickly',
            'Continuous Focus': 'Camera keeps refocusing on moving subjects',
            'Macro Focus': 'Very close-up photography',
          },
          'quote': 'It\'s not the gear, it\'s the control in your hands.',
        },
      },

      // Day 20: Low Light Photography
      {
        'id': 'lesson_020',
        'day': 20,
        'title': 'How to Shoot in Low Light',
        'subtitle': 'Without Flash',
        'description':
            'Master techniques for capturing beautiful photos in dark environments using available light sources.',
        'content': '''**🌙 Why Avoid Flash?**

Flash can create harsh, unnatural light that:
• Flattens facial features
• Creates red-eye effect
• Eliminates natural atmosphere
• Disturbs people and events

Learning to use available light creates more **natural and beautiful** photos.

**🔦 Finding Light in Dark Places**

**Natural light sources to look for:**
• Window light (even at night)
• Street lights and shop signs
• Candles, diyas, or oil lamps
• TV or phone screen glow
• Car headlights
• Fire or bonfire light

**Artificial light sources:**
• LED panels or ring lights
• Table lamps with lampshades
• Fairy lights or string lights
• Torch/flashlight (diffused with tissue)

**📱 Camera Settings for Low Light**

**Mobile phones:**
• Use Night mode if available
• Increase ISO (1600-6400)
• Use manual focus
• Hold very steady or use tripod
• Take multiple shots

**Manual settings:**
• Higher ISO (accept some grain for the shot)
• Wider aperture (lower f-number)
• Slower shutter speed (but watch for blur)
• Focus manually on subject

**🧘‍♂️ Staying Steady in Low Light**

• **Brace yourself:** Use wall, table, or your body
• **Breathing technique:** Take breath, hold, shoot, exhale
• **Timer function:** Use 2-3 second timer to avoid shake
• **Makeshift tripod:** Stack books, use phone stand
• **Both hands:** Hold phone with both hands firmly

**🎨 Creative Low Light Techniques**

**Silhouettes:**
• Place subject between you and light source
• Expose for the bright background
• Keep subject as dark shape

**Rim lighting:**
• Light comes from behind subject
• Creates beautiful outline glow
• Great for portraits and objects

**Mood lighting:**
• Single candle or diya
• Soft, warm, intimate feel
• Perfect for festivals or spiritual moments

**🇮🇳 Indian Low Light Opportunities**

• **Diwali celebrations:** Candles and diyas
• **Evening aarti:** Temple or home prayers
• **Street food stalls:** Warm artificial lighting
• **Wedding ceremonies:** Avoid flash, use ambient light
• **Monsoon evenings:** Soft window light
• **Festival lights:** Colorful decorations

**⚠️ Common Low Light Mistakes**

• Using digital zoom (makes grain worse)
• Moving too much (causes blur)
• Expecting perfection (some grain is okay)
• Not getting close enough to light source
• Forgetting to clean lens (reduces available light)''',
        'estimatedDuration': 35,
        'type': 'practice',
        'difficulty': 'beginner',
        'categories': ['Low Light', 'Available Light', 'Night Photography'],
        'objectives': [
          'Shoot in low light without using flash',
          'Find and use available light sources creatively',
          'Master camera stability techniques',
          'Create mood and atmosphere in dark environments',
        ],
        'exercises': [
          {
            'id': 'exercise_020_01',
            'title': 'Low Light Photography Challenge',
            'description':
                'Practice shooting in various low light conditions using only available light',
            'steps': [
              'Take a portrait lit by window light in evening',
              'Photograph an object using candle or diya light',
              'Create a silhouette against bright background',
              'Capture the glow from a phone or TV screen',
              'Take a street scene using only street lighting',
              'Practice holding steady - compare with/without support',
            ],
            'requirements': {
              'lighting': 'Various low light sources (no flash)',
              'stability': 'Practice with and without camera support',
              'subjects': 'Portrait, object, silhouette, screen glow, street',
              'time': '45 minutes',
            },
            'estimatedTime': 45,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Available Light': 'Existing light in the scene',
            'Grain/Noise': 'Dots that appear in low light photos',
            'Rim Light': 'Light that outlines the subject from behind',
            'Ambient Light': 'General light in the environment',
            'Camera Shake': 'Blur from moving camera during exposure',
          },
          'quote': 'Darkness isn\'t empty---it\'s a canvas of light.',
        },
      },

      // Day 21: One Light Portrait Challenge
      {
        'id': 'lesson_021',
        'day': 21,
        'title': 'Practice Day',
        'subtitle': 'One Light Portrait Challenge',
        'description':
            'Master portrait lighting by using only one light source to create dramatic and beautiful portraits.',
        'content': '''**💡 Why One Light Portrait Challenge?**

Using only one light source teaches you to:
• **Control light direction** and intensity
• **Understand shadows** and highlights
• **Create mood and drama**
• **Work with limited resources**
• **Focus on the subject's expression**

Great photographers often start with just one light because it's **simple yet powerful**.

**🔦 Light Sources You Can Use**

**Natural sources:**
• Window light (soft, even)
• Doorway light (directional)
• Balcony or terrace light
• Golden hour sunlight

**Artificial sources:**
• Table lamp with lampshade
• Mobile flashlight (diffused with tissue paper)
• LED panel or ring light
• Single candle or diya (for mood)
• Computer or TV screen (for creative effects)

**📐 Light Positioning Techniques**

**Front lighting:** Light faces the subject
• Effect: Even, soft lighting
• Good for: Beauty portraits, clear features
• Setup: Light directly in front, slightly above eye level

**45-degree lighting:** Light at angle to subject
• Effect: Dramatic shadows, dimension
• Good for: Character portraits, artistic shots
• Setup: Light 45 degrees to side and slightly above

**Side lighting:** Light from the side
• Effect: Half face lit, half in shadow
• Good for: Dramatic mood, mystery
• Setup: Light directly to one side of subject

**Back lighting:** Light behind subject
• Effect: Rim light, silhouette
• Good for: Creative portraits, spiritual mood
• Setup: Subject between you and light source

**🧍‍♀️ Posing Tips for One Light**

• **Face the light** for even illumination
• **Turn slightly away** for more dramatic shadows
• **Use hands naturally** - don't pose stiffly
• **Focus on eyes** - they should catch the light
• **Relax and talk** to get natural expressions

**🎨 Creative One Light Ideas**

• **Candle portraits:** Warm, intimate lighting
• **Window silhouettes:** Subject against bright window
• **Phone screen glow:** Modern, tech-inspired look
• **Golden hour magic:** Soft, warm outdoor light
• **Lamp shade softness:** Diffused indoor lighting

**🇮🇳 Indian Cultural One Light Portraits**

• **Diya or oil lamp lighting:** Traditional and spiritual
• **Saree or dupatta as diffuser:** Soften harsh light
• **Jharokha (window) portraits:** Traditional framing
• **Morning pooja light:** Spiritual and peaceful
• **Festival lighting:** Colorful and celebratory

**📱 Technical Settings**

• **Focus on the eyes** closest to camera
• **Expose for the face**, not the background
• **Use Portrait mode** if available for blur
• **Keep ISO low** to reduce grain
• **Use timer** to avoid camera shake''',
        'estimatedDuration': 50,
        'type': 'project',
        'difficulty': 'beginner',
        'categories': [
          'Portrait Photography',
          'Lighting',
          'Creative Challenge',
        ],
        'objectives': [
          'Master single light source portrait techniques',
          'Understand light direction and shadow control',
          'Create dramatic and beautiful portraits',
          'Develop lighting creativity with limited resources',
        ],
        'exercises': [
          {
            'id': 'exercise_021_01',
            'title': 'One Light Portrait Project',
            'description':
                'Create a series of portraits using only one light source in different ways',
            'steps': [
              'Set up near a window for natural one-light portraits',
              'Take a front-lit portrait (soft, even lighting)',
              'Create a 45-degree angle dramatic portrait',
              'Try side lighting for half-shadow effect',
              'Experiment with backlighting for rim light or silhouette',
              'Use artificial light (lamp, candle, phone) for creative mood',
              'Compare all shots and select your best one-light portrait',
            ],
            'requirements': {
              'light_source': 'Single light only (natural or artificial)',
              'positions': 'Try at least 4 different light positions',
              'subject': 'Willing portrait subject',
              'time': '60 minutes',
            },
            'estimatedTime': 60,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'One Light': 'Using only one light source',
            'Light Direction': 'Where the light comes from relative to subject',
            'Rim Light': 'Light that outlines the subject from behind',
            'Front Light': 'Light coming from camera direction',
            'Side Light': 'Light coming from the side of subject',
          },
          'quote':
              'With one light and a vision, you can tell a thousand stories.',
        },
      },

      // Day 22: Basic Photo Editing
      {
        'id': 'lesson_022',
        'day': 22,
        'title': 'Basics of Photo Editing',
        'subtitle': 'Using Snapseed or Lightroom Mobile',
        'description':
            'Learn essential photo editing skills using free mobile apps to enhance your photos professionally.',
        'content': '''**🛠️ Why Edit Your Photos?**

Photo editing helps you:
• **Correct exposure** problems (too dark/bright)
• **Enhance colors** and mood
• **Remove distractions** or unwanted elements
• **Improve composition** through cropping
• **Express your creative vision**

Think of editing as **finishing your photo**, not fixing bad photography.

**📲 Best Free Editing Apps**

**Snapseed (Google):**
• Completely free
• Professional tools
• Easy to learn
• Works on Android and iOS

**Lightroom Mobile (Adobe):**
• Free version available
• Professional-grade editing
• Cloud sync
• Preset filters

**🔧 Essential Editing Tools Explained**

**Brightness:** Makes the whole photo lighter or darker
• Use when photo is too dark or too bright overall

**Contrast:** Difference between light and dark areas
• Increase for more dramatic look
• Decrease for softer, gentler feel

**Highlights:** Brightest parts of your photo
• Lower to recover blown-out bright areas
• Useful for sky or bright windows

**Shadows:** Darkest parts of your photo
• Raise to brighten dark areas
• Helpful for faces in shadow

**Saturation:** Intensity of colors
• Increase for more vibrant colors
• Decrease for muted, natural look

**Clarity/Structure:** Adds sharpness to edges
• Increase for crisp, detailed look
• Use sparingly to avoid over-sharpening

**Temperature:** Warmth or coolness of colors
• Move toward yellow for warmer feel
• Move toward blue for cooler mood

**📱 Snapseed Basic Workflow**

1. **Open photo** in Snapseed
2. **Tools > Tune Image** for basic adjustments
3. **Adjust brightness, contrast, saturation**
4. **Tools > Crop** to improve composition
5. **Tools > Healing** to remove small distractions
6. **Export** your edited photo

**🎨 Editing Guidelines for Beginners**

• **Start with small adjustments** (don't overdo it)
• **Edit with the end goal in mind** (what story are you telling?)
• **Keep it natural** - avoid heavy filters
• **Compare with original** regularly
• **Save original and edited versions**

**🇮🇳 Editing Indian Photography**

• **Wedding photos:** Warm up skin tones, brighten faces
• **Festival shots:** Enhance colors but keep them realistic
• **Street photography:** Increase contrast for dramatic look
• **Food photography:** Warm colors, bright highlights
• **Portrait photography:** Soften skin, brighten eyes

**⚠️ Common Editing Mistakes**

• **Over-saturation:** Colors look fake and cartoonish
• **Too much clarity:** Creates harsh, unnatural look
• **Extreme contrast:** Loses detail in highlights/shadows
• **Heavy filters:** Distracts from the subject
• **Not cropping:** Missing chance to improve composition''',
        'estimatedDuration': 30,
        'type': 'practice',
        'difficulty': 'beginner',
        'categories': ['Photo Editing', 'Post-Processing', 'Digital Skills'],
        'objectives': [
          'Learn basic photo editing tools and techniques',
          'Use Snapseed or Lightroom Mobile effectively',
          'Enhance photos while maintaining natural look',
          'Develop personal editing style',
        ],
        'exercises': [
          {
            'id': 'exercise_022_01',
            'title': 'Basic Photo Editing Practice',
            'description':
                'Edit different types of photos using essential tools',
            'steps': [
              'Download Snapseed or Lightroom Mobile (free)',
              'Edit a portrait: adjust brightness, contrast, and skin tones',
              'Edit a landscape: enhance sky and colors',
              'Edit an indoor photo: brighten shadows, reduce highlights',
              'Practice cropping to improve composition',
              'Compare all edited versions with originals',
            ],
            'requirements': {
              'app': 'Snapseed or Lightroom Mobile',
              'photos': 'Portrait, landscape, indoor photo',
              'edits': 'Basic adjustments + cropping',
              'time': '40 minutes',
            },
            'estimatedTime': 40,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Editing': 'Adjusting photos after taking them',
            'Exposure': 'How bright or dark the photo is',
            'Highlights': 'Brightest areas in the photo',
            'Shadows': 'Darkest areas in the photo',
            'Saturation': 'How intense the colors are',
            'Crop': 'Cut parts of photo to improve framing',
          },
          'quote': 'Editing is how you finish the story your photo began.',
        },
      },

      // Day 23: Portrait Editing
      {
        'id': 'lesson_023',
        'day': 23,
        'title': 'How to Edit Skin & Light in Portraits',
        'subtitle': 'Natural Beauty Enhancement',
        'description':
            'Learn to enhance portraits while maintaining natural beauty and realistic skin tones.',
        'content': '''**🧴 Philosophy of Portrait Editing**

Good portrait editing should:
• **Enhance natural beauty**, not create artificial perfection
• **Maintain realistic skin texture**
• **Improve lighting and exposure**
• **Keep the person recognizable**
• **Support the mood and story**

Remember: The goal is to make people look like the **best version of themselves**.

**👁️ Eye Enhancement Techniques**

**Brightening eyes:**
• Use Snapseed's **Selective tool**
• Tap on the eyes
• Increase **brightness** slightly (+10 to +20)
• Add subtle **structure/clarity** for sparkle

**Sharpening eyes:**
• Use **Details tool** in Snapseed
• Focus on just the iris and eyelashes
• Don't over-sharpen

**🌟 Skin Smoothing (Natural Approach)**

**Basic skin enhancement:**
• Use **Healing tool** for spots and blemishes
• **Portrait tool** for overall skin softening
• Keep **texture visible** - don't make skin plastic
• Work on small areas at a time

**Advanced skin editing:**
• Use **Brush tool** to selectively brighten/darken skin
• **Dodge** (brighten) under-eye circles gently
• **Burn** (darken) any harsh highlights on forehead

**💡 Fixing Light on Faces**

**Balancing facial lighting:**
• **Brighten shadows** under eyes, nose, chin
• **Reduce hot spots** on forehead, nose bridge
• Use **Selective tool** for precise adjustments
• Keep lighting looking natural

**Color correction:**
• Adjust **temperature** for skin tone
• Indian skin often looks good with slightly warm temperature
• Fix **color casts** from artificial lighting

**🎨 Snapseed Portrait Workflow**

1. **Basic adjustments:** Brightness, contrast, highlights, shadows
2. **Healing tool:** Remove obvious blemishes
3. **Portrait tool:** Gentle skin smoothing (30-50% maximum)
4. **Selective tool:** Brighten eyes and balance face lighting
5. **Details tool:** Sharpen eyes subtly
6. **Final check:** Compare with original

**🇮🇳 Editing Indian Portraits**

**Traditional portraits:**
• Enhance jewelry and clothing details
• Warm up gold and red tones
• Brighten face while keeping traditional makeup natural

**Wedding photography:**
• Balance harsh flash lighting
• Enhance bridal attire colors
• Soften skin while keeping cultural authenticity

**Family portraits:**
• Consistent skin tones across family members
• Gentle enhancement for older family members
• Keep children's natural expressions intact

**⚠️ What NOT to Do**

• **Over-smooth skin** - lose natural texture
• **Whiten teeth too much** - looks unnatural
• **Change face structure** - not realistic
• **Remove all wrinkles** from older people - part of their character
• **Make eyes unnaturally bright** - should still look human

**📱 Mobile Portrait Editing Tips**

• **Zoom in** while editing for precision
• **Use small adjustments** (+/- 10-20 maximum)
• **Edit on bright phone screen** for accurate colors
• **Take breaks** to see with fresh eyes
• **Save original and edited versions**''',
        'estimatedDuration': 35,
        'type': 'practice',
        'difficulty': 'beginner',
        'categories': [
          'Portrait Editing',
          'Skin Retouching',
          'Beauty Enhancement',
        ],
        'objectives': [
          'Edit portraits while maintaining natural beauty',
          'Balance lighting on faces effectively',
          'Enhance eyes and skin texture appropriately',
          'Develop ethical portrait editing practices',
        ],
        'exercises': [
          {
            'id': 'exercise_023_01',
            'title': 'Natural Portrait Enhancement',
            'description':
                'Practice enhancing portraits while keeping them natural and realistic',
            'steps': [
              'Select 2-3 portrait photos with different lighting conditions',
              'Basic adjustments: fix overall exposure and contrast',
              'Use Healing tool to remove only obvious blemishes',
              'Gently brighten eyes using Selective tool',
              'Balance face lighting - brighten shadows, reduce hot spots',
              'Apply minimal skin smoothing (30-50% maximum)',
              'Compare before/after - ensure person still looks like themselves',
            ],
            'requirements': {
              'photos': '2-3 portrait photos',
              'editing': 'Natural enhancement only',
              'comparison': 'Before/after comparison',
              'time': '45 minutes',
            },
            'estimatedTime': 45,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Skin Smoothing': 'Reducing blemishes while keeping texture',
            'Selective Tool': 'Edit specific areas of photo',
            'Healing Tool': 'Remove spots and unwanted elements',
            'Color Cast': 'Unwanted color tint in photo',
            'Hot Spots': 'Overly bright areas on skin',
          },
          'quote': 'Real beauty lives in soft light and honest skin.',
        },
      },
      {
        'id': 'lesson_024',
        'day': 24,
        'title': 'Adding Filters Without Losing Natural Look',
        'subtitle': 'Subtle Enhancement Techniques',
        'description':
            'Learn to apply filters and presets while maintaining natural, professional-looking results.',
        'content': '''**🎨 The Art of Subtle Filtering**

Filters and presets can enhance your photos, but the key is **restraint**. The best edits are often invisible - they enhance the mood without making the photo look obviously processed.

**📱 Types of Filters and Where to Find Them**

**Built-in phone filters:**
• Usually too strong for professional use
• Good for quick social media posts
• Try at 30-50% intensity

**Snapseed "Looks":**
• More subtle and professional
• Can be adjusted after applying
• Good starting points for editing

**Lightroom Mobile presets:**
• Professional-grade filters
• Free and paid options available
• Highly customizable

**🎯 Choosing the Right Filter Style**

**Portrait photography:**
• Warm, soft filters
• Film emulation presets
• Avoid high contrast or saturated looks

**Landscape photography:**
• Enhance natural colors
• Slightly increase contrast
• Bring out sky details

**Street photography:**
• Black & white conversions
• Vintage film looks
• Moody, contrasty styles

**🛠️ How to Apply Filters Properly**

**Step 1: Basic corrections first**
• Fix exposure, highlights, shadows
• Correct white balance
• Crop and straighten

**Step 2: Apply filter at reduced intensity**
• Start at 30-50% strength
• See how it affects the overall mood

**Step 3: Fine-tune individual elements**
• Adjust specific areas if needed
• Ensure skin tones look natural
• Check that details aren't lost

**🇮🇳 Filters for Indian Photography**

• **Wedding photography:** Warm, golden presets that enhance reds and golds
• **Festival photography:** Vibrant but natural color enhancement
• **Portrait photography:** Film emulation for timeless look
• **Street photography:** Vintage film looks for nostalgic feel

**⚠️ Common Filter Mistakes**

• Over-saturation making colors look fake
• Too much contrast losing detail
• Heavy vignetting that distracts
• Unrealistic skin tones
• Inconsistent looks across similar photos''',
        'estimatedDuration': 25,
        'type': 'practice',
        'difficulty': 'beginner',
        'categories': ['Photo Editing', 'Filters', 'Style Development'],
        'objectives': [
          'Apply filters while maintaining natural look',
          'Understand different filter styles and when to use them',
          'Develop personal editing style',
          'Avoid common filtering mistakes',
        ],
        'exercises': [
          {
            'id': 'exercise_024_01',
            'title': 'Natural Filter Application Practice',
            'description':
                'Practice applying various filters while keeping photos looking natural and professional',
            'steps': [
              'Select 3 different types of photos (portrait, landscape, object)',
              'Try 3 different filter styles on each photo',
              'Apply each filter at 30-50% intensity',
              'Compare filtered versions with originals',
              'Choose the most natural-looking enhancement for each',
              'Create a consistent style across all three photos',
            ],
            'requirements': {
              'photos': '3 different types (portrait, landscape, object)',
              'filters': 'Try at least 3 different filter styles',
              'intensity': 'Test at reduced intensity (30-50%)',
              'time': '35 minutes',
            },
            'estimatedTime': 35,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Filter': 'A preset look for editing photos',
            'Preset': 'Pre-made editing setup',
            'Intensity': 'How strong the filter effect is',
            'Film Emulation': 'Filter that mimics old film camera',
            'Vignetting': 'Darkening around edges of photo',
          },
          'quote': 'A good filter should whisper, not shout.',
        },
      },

      // Day 25: Cropping, Straightening & Exporting
      {
        'id': 'lesson_025',
        'day': 25,
        'title': 'Cropping, Straightening & Exporting',
        'subtitle': 'Final Photo Preparation',
        'description':
            'Master the final steps of photo editing: improving composition through cropping and preparing images for sharing.',
        'content': '''**✂️ The Power of Cropping**

Cropping is often the **most important edit** you can make. It can:
• **Improve composition** dramatically
• **Remove distractions** from edges
• **Change the story** of your photo
• **Fix framing mistakes** made while shooting

**📐 Cropping Guidelines**

**Rule of Thirds in cropping:**
• Place important elements on grid lines
• Eyes on upper third line for portraits
• Horizon on upper or lower third for landscapes

**Aspect ratios for different uses:**
• **Square (1:1):** Instagram posts, profile pictures
• **4:5 vertical:** Instagram stories, portrait posts
• **16:9 horizontal:** YouTube thumbnails, landscape photos
• **Original ratio:** Often best for printing

**🧭 Straightening Your Photos**

**Why straighten?**
• Tilted horizons look unprofessional
• Crooked buildings are distracting
• Straight lines create visual stability

**How to straighten:**
• Use horizon as reference line
• For architecture, use building edges
• Slight adjustments (1-3 degrees) often enough

**📤 Exporting Your Photos**

**Export settings for different purposes:**

**Instagram posting:**
• Resolution: 1080 x 1080 (square) or 1080 x 1350 (4:5)
• Format: JPEG, Quality: 90-95%

**Printing:**
• Resolution: 300 DPI minimum
• Format: JPEG (high quality)

**Website/blog:**
• Width: 1200-2000 pixels maximum
• Format: JPEG for photos

**WhatsApp sharing:**
• Smaller file size for quick sending
• 800-1200 pixels wide usually sufficient

**🔧 Export Workflow**

1. **Final edit check** - Review all adjustments
2. **Crop and straighten** - Apply rule of thirds, remove distractions
3. **Choose export settings** - Select resolution based on use
4. **Save with descriptive name** - Include date and subject

**📱 Mobile Export Tips**

**Snapseed export:**
• Export > Save (saves to gallery)
• Maintains high quality by default

**Lightroom Mobile:**
• Share > Export As > Choose settings
• Can export to cloud storage''',
        'estimatedDuration': 20,
        'type': 'practice',
        'difficulty': 'beginner',
        'categories': ['Photo Editing', 'Composition', 'File Management'],
        'objectives': [
          'Master cropping for better composition',
          'Learn to straighten photos professionally',
          'Understand export settings for different platforms',
          'Organize and name files effectively',
        ],
        'exercises': [
          {
            'id': 'exercise_025_01',
            'title': 'Cropping and Export Practice',
            'description':
                'Practice improving photos through cropping and prepare them for different platforms',
            'steps': [
              'Select 3 photos that need composition improvement',
              'Crop each using Rule of Thirds for better framing',
              'Straighten any tilted horizons or buildings',
              'Export one photo for Instagram (square)',
              'Export one photo for printing (high resolution)',
              'Export one photo for WhatsApp sharing (compressed)',
              'Compare before/after crops to see improvement',
            ],
            'requirements': {
              'photos': '3 photos needing composition improvement',
              'crops': 'Apply Rule of Thirds',
              'exports': 'Different formats for different platforms',
              'time': '30 minutes',
            },
            'estimatedTime': 30,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Crop': 'Cut parts of photo to improve framing',
            'Aspect Ratio': 'Width to height proportion of image',
            'Resolution': 'Image quality in pixels',
            'DPI': 'Dots per inch - print quality measure',
            'Export': 'Save final image for sharing',
          },
          'quote':
              'Framing your photo is like choosing your words in a sentence.',
        },
      },

      // Day 26: Organizing Your Photos
      {
        'id': 'lesson_026',
        'day': 26,
        'title': 'Organizing Your Photos',
        'subtitle': 'Digital Photo Management',
        'description':
            'Learn effective strategies for organizing, storing, and managing your growing photo collection.',
        'content': '''**📁 Why Organization Matters**

As you take more photos, organization becomes crucial for:
• **Finding specific photos quickly**
• **Keeping only your best work**
• **Backing up important memories**
• **Tracking your progress as a photographer**
• **Preparing for sharing or printing**

**🗂️ Folder Structure Ideas**

**By Date:**
• 2025_01_January
• 2025_02_February
• Easy to find recent photos

**By Subject:**
• Portraits
• Landscapes
• Street_Photography
• Family_Events
• Good for photographers with specific interests

**By Event:**
• 2025_Wedding_Priya
• 2025_Diwali_Celebration
• 2025_Kashmir_Trip
• Perfect for important occasions

**🌟 Rating and Selection System**

**Star rating system:**
• ⭐⭐⭐⭐⭐ Portfolio worthy, best work
• ⭐⭐⭐⭐ Very good, worth sharing
• ⭐⭐⭐ Good, keep for memories
• ⭐⭐ Okay, might delete later
• ⭐ Poor, consider deleting

**Color coding:**
• **Red:** Portfolio/best work
• **Yellow:** Good for social media
• **Green:** Family/personal memories
• **Blue:** Learning/practice shots

**🧹 Photo Culling Process**

**Step 1: First pass (Keep/Delete)**
• Delete obviously bad photos (blurry, wrong exposure)
• Keep everything that might be worth editing
• Be ruthless with duplicates

**Step 2: Second pass (Rating)**
• Rate remaining photos 1-5 stars
• Focus on technical quality and composition
• Consider emotional value for personal photos

**Step 3: Final selection**
• Keep only 4-5 star photos for portfolio
• Archive 3 star photos for memories
• Delete 1-2 star photos to save space

**☁️ Backup Strategies**

**3-2-1 Rule:**
• **3 copies** of important photos
• **2 different storage types** (phone + cloud)
• **1 offsite backup** (cloud storage)

**Free backup options:**
• Google Photos (15GB free)
• iCloud (5GB free)
• OneDrive (5GB free)
• Dropbox (2GB free)

**Paid options for serious photographers:**
• Google Photos (100GB for ₹130/month)
• Adobe Creative Cloud (with Lightroom)
• Amazon Photos (unlimited for Prime members)

**📱 Mobile Organization Tools**

**Built-in gallery apps:**
• Most phones allow album creation
• Basic folder organization
• Limited editing and rating features

**Google Photos:**
• Automatic backup
• Face recognition
• Smart search features
• Shared albums

**Adobe Lightroom Mobile:**
• Professional organization
• Cloud sync across devices
• Advanced search and filtering
• Editing history preserved

**🇮🇳 Indian Photography Organization**

**Festival photos:**
• Create yearly festival albums
• Separate by festival type (Diwali, Holi, etc.)
• Include family and cultural celebrations

**Travel photography:**
• Organize by destination
• Include both tourist spots and local culture
• Add location tags for easy searching

**Family events:**
• Weddings, birthdays, graduations
• Organize by family member or event type
• Consider sharing albums with extended family

**📝 File Naming Best Practices**

**Consistent naming convention:**
• Date_Event_Subject (2025_01_15_Portrait_Mom)
• Location_Date (Mumbai_2025_01_15)
• Event_Date_Number (Wedding_2025_01_15_001)

**Avoid:**
• Special characters (@, #, &)
• Very long names
• Inconsistent formatting
• Generic names (IMG_001, Photo1)''',
        'estimatedDuration': 30,
        'type': 'organization',
        'difficulty': 'beginner',
        'categories': ['File Management', 'Digital Organization', 'Workflow'],
        'objectives': [
          'Develop effective photo organization system',
          'Learn to cull and rate photos efficiently',
          'Set up reliable backup strategies',
          'Create searchable file naming conventions',
        ],
        'exercises': [
          {
            'id': 'exercise_026_01',
            'title': 'Photo Organization Project',
            'description':
                'Organize your existing photo collection and set up a management system',
            'steps': [
              'Review your current photo collection (last 50-100 photos)',
              'Delete obviously bad photos (blurry, duplicates)',
              'Create 3-5 folders/albums for organization',
              'Rate your best 20 photos using stars or favorites',
              'Set up automatic backup to cloud storage',
              'Rename 10 photos using consistent naming convention',
              'Create a "Portfolio" album with your top 10 photos',
            ],
            'requirements': {
              'photos': 'Review 50-100 recent photos',
              'organization': 'Create folder/album system',
              'backup': 'Set up cloud backup',
              'time': '45 minutes',
            },
            'estimatedTime': 45,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Photo Culling': 'Process of selecting best photos',
            'Rating': 'Scoring photos by quality (1-5 stars)',
            'Backup': 'Save copy on another device/cloud',
            'Cloud Storage': 'Online storage service',
            'File Naming': 'System for naming photo files',
          },
          'quote': 'The best photo is the one you can find again.',
        },
      },

      // Day 27: Sharing Your Work
      {
        'id': 'lesson_027',
        'day': 27,
        'title': 'Sharing Your Work',
        'subtitle': 'Instagram Tips and Building Confidence',
        'description':
            'Learn how to share your photography confidently and build an audience on social media platforms.',
        'content': '''**📲 Why Share Your Photography?**

Sharing your work helps you:
• **Get feedback** from other photographers
• **Build confidence** in your abilities
• **Connect with photography community**
• **Document your learning journey**
• **Inspire others to start photography**

**📸 Instagram Photography Tips**

**Profile setup:**
• Use a clear profile picture (preferably your photo)
• Write a simple bio: "Learning photography | 30-day journey"
• Include location if comfortable
• Link to other platforms or website

**Posting strategy:**
• **Consistency:** Post 2-3 times per week
• **Quality over quantity:** Better to post less frequently with good photos
• **Mix content:** Portraits, landscapes, behind-the-scenes
• **Tell stories:** Each post should have a story or lesson

**Caption writing:**
• Start with the story behind the photo
• Share what you learned while taking it
• Ask questions to encourage engagement
• Keep it authentic and personal

**Hashtag strategy for beginners:**
• Use 5-10 relevant hashtags
• Mix popular and niche tags
• Include location-based tags
• Examples: #beginnerphotographer #learnphotography #mobilephotography #mumbaistreets

**📱 Technical Tips for Instagram**

**Image specifications:**
• Square posts: 1080 x 1080 pixels
• Portrait posts: 1080 x 1350 pixels
• Stories: 1080 x 1920 pixels
• Reels: 1080 x 1920 pixels

**Quality optimization:**
• Upload high-resolution images
• Avoid heavy filters that reduce quality
• Use consistent editing style
• Maintain good lighting in photos

**🌟 Building Confidence**

**Start small:**
• Share with friends and family first
• Post in beginner photography groups
• Don't expect immediate likes or followers
• Focus on documenting your journey

**Dealing with criticism:**
• Ask for constructive feedback, not just "likes"
• Learn from negative comments (ignore mean ones)
• Remember everyone starts somewhere
• Focus on improvement, not perfection

**🇮🇳 Indian Photography Community**

**Local hashtags:**
• #indiaclicks #photographers_of_india
• #streetphotographyindia #incredibleindia
• City-specific: #delhidiaries #mumbai_igers #chennaiphotography

**Photography groups to join:**
• Indian Photography Community (Facebook)
• Local photography meetups
• Instagram photography challenges
• WhatsApp groups for local photographers

**📝 Content Ideas for Beginners**

**Behind-the-scenes:**
• Show your setup for a photo
• Explain your camera settings
• Share mistakes and how you fixed them

**Before and after:**
• Original photo vs edited version
• Show your editing process
• Explain what you changed and why

**Learning posts:**
• Share daily photography tips
• Document your 30-day journey
• Show progress from day 1 to day 30

**🎯 Engagement Strategies**

**Be genuine:**
• Comment meaningfully on others' photos
• Ask questions about their techniques
• Share others' work (with credit)
• Participate in photography challenges

**Collaborate:**
• Take photos with other beginners
• Create photo walks with friends
• Tag photographers who inspire you
• Share photography tips you've learned

**🛡️ Online Safety and Ethics**

**Privacy considerations:**
• Don't share photos with location tags of your home
• Be careful about sharing personal information
• Ask permission before posting photos of others
• Respect cultural and religious sensitivities

**Copyright and credit:**
• Only post photos you took yourself
• Give credit when sharing others' work
• Understand that your photos have copyright protection
• Watermark important photos if concerned about theft''',
        'estimatedDuration': 25,
        'type': 'social',
        'difficulty': 'beginner',
        'categories': [
          'Social Media',
          'Community Building',
          'Photography Sharing',
        ],
        'objectives': [
          'Build confidence in sharing photography work',
          'Learn Instagram best practices for photographers',
          'Connect with photography community',
          'Develop authentic personal voice and style',
        ],
        'exercises': [
          {
            'id': 'exercise_027_01',
            'title': 'First Instagram Photography Post',
            'description':
                'Create and share your first photography post with confidence',
            'steps': [
              'Choose your best photo from the past week',
              'Write a caption telling the story behind the photo',
              'Add 5-8 relevant hashtags',
              'Post and share what you learned while taking it',
              'Engage with 3 other beginner photographers\' posts',
              'Follow 5 photographers whose style you admire',
              'Join one photography group or community online',
            ],
            'requirements': {
              'photo': 'Your best recent photograph',
              'caption': 'Personal story about the photo',
              'engagement': 'Comment on others\' work meaningfully',
              'time': '30 minutes',
            },
            'estimatedTime': 30,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Hashtag': 'A tag to group similar content (#photography)',
            'Engagement': 'Likes, comments, and shares on posts',
            'Caption': 'Text you write with your photo',
            'Community': 'Group of people with shared interests',
            'Behind-the-scenes': 'Showing the process of creating',
          },
          'quote': 'You never grow if you never show.',
        },
      },

      // Day 28: Feedback Day
      {
        'id': 'lesson_028',
        'day': 28,
        'title': 'Feedback Day',
        'subtitle': 'Pick 3 Best Photos You Took This Month',
        'description':
            'Critically evaluate your month\'s work, select your best photographs, and seek constructive feedback.',
        'content': '''**🔍 The Importance of Self-Evaluation**

After 28 days of learning, it's time to look back and see your progress. This process helps you:
• **Recognize your growth** as a photographer
• **Identify your strengths** and preferred subjects
• **Understand areas** that need more practice
• **Build confidence** in your abilities
• **Plan future learning** directions

**📊 Evaluation Criteria**

**Technical quality:**
• Is the photo sharp and well-exposed?
• Are the colors natural and pleasing?
• Is the composition strong?
• Does it follow photography principles you've learned?

**Emotional impact:**
• Does the photo tell a story?
• Does it evoke emotion in viewers?
• Is there a clear subject and message?
• Would you be proud to show this to others?

**Personal growth:**
• Does this photo show improvement from your early work?
• Did you apply specific techniques you learned?
• Does it represent your developing style?
• What challenges did you overcome to create it?

**🏆 Selection Process**

**Step 1: Initial review (10 minutes)**
• Look through all photos from the past 28 days
• Identify 10-15 photos that stand out
• Consider variety: portraits, landscapes, objects, etc.

**Step 2: Technical assessment (10 minutes)**
• Check each photo for technical quality
• Eliminate any with obvious technical flaws
• Focus on sharp, well-exposed images

**Step 3: Emotional evaluation (10 minutes)**
• Which photos make you feel something?
• Which ones tell the clearest stories?
• Which represent moments you want to remember?

**Step 4: Final selection (5 minutes)**
• Choose your top 3 photographs
• Ensure they show different aspects of your learning
• Pick photos that represent your best work

**💭 Questions for Self-Reflection**

**For each selected photo, ask:**
• What was I trying to achieve with this photograph?
• What techniques did I use (rule of thirds, lighting, etc.)?
• What do I like most about this image?
• What would I do differently if I took it again?
• How does this compare to my photos from Day 1?

**🗣️ Seeking Feedback**

**Who to ask:**
• Photography friends or family members
• Online photography communities
• Other participants in photography courses
• Local photography groups

**How to ask for feedback:**
• Be specific: "What do you think about the composition?"
• Ask open questions: "What feeling does this give you?"
• Request constructive criticism: "How could I improve this?"
• Don't ask just "Do you like it?" - that's not helpful

**Good feedback questions:**
• "What draws your eye first in this photo?"
• "Does the story come across clearly?"
• "How does the lighting work for you?"
• "What would you change about this composition?"

**🇮🇳 Sharing Your Journey**

**Document your progress:**
• Create a before/after comparison (Day 1 vs Day 28)
• Write about your biggest photography lessons
• Share your challenges and breakthroughs
• Inspire others who are starting their journey

**Cultural considerations:**
• If photographing people, ensure you have permission to share
• Respect privacy and cultural sensitivities
• Celebrate the diversity of Indian photography subjects
• Share what makes your local area special

**📈 Planning Next Steps**

**Based on your top 3 photos, identify:**
• **Strengths:** What type of photography do you excel at?
• **Interests:** What subjects do you enjoy most?
• **Improvements needed:** What areas need more practice?
• **Next goals:** What do you want to learn next?

**Future learning directions:**
• If you love portraits → Learn more about posing and lighting
• If landscapes appeal to you → Study composition and timing
• If street photography excites you → Practice storytelling
• If macro interests you → Learn about close-up techniques''',
        'estimatedDuration': 45,
        'type': 'review',
        'difficulty': 'beginner',
        'categories': [
          'Self-Assessment',
          'Portfolio Selection',
          'Progress Evaluation',
        ],
        'objectives': [
          'Critically evaluate a month of photography work',
          'Select best photographs using objective criteria',
          'Seek and receive constructive feedback',
          'Plan future photography learning direction',
        ],
        'exercises': [
          {
            'id': 'exercise_028_01',
            'title': 'Monthly Portfolio Selection',
            'description':
                'Select your best 3 photographs from the month and gather feedback',
            'steps': [
              'Review all photos taken during the 30-day course',
              'Create a shortlist of 10-15 strong candidates',
              'Apply technical and emotional criteria to narrow down',
              'Select your final 3 best photographs',
              'Write one paragraph about each photo (story, technique, learnings)',
              'Share with a friend/family member and ask for honest feedback',
              'Compare your Day 28 photos with your Day 1 photos',
              'Document your biggest improvements and learnings',
            ],
            'requirements': {
              'review': 'All photos from 30-day course',
              'selection': 'Top 3 photographs with rationale',
              'feedback': 'Get opinion from at least one other person',
              'time': '60 minutes',
            },
            'estimatedTime': 60,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Portfolio': 'Collection of your best work',
            'Critique': 'Detailed analysis of artwork',
            'Self-Assessment': 'Evaluating your own work',
            'Technical Quality': 'Camera settings and clarity',
            'Emotional Impact': 'How photo makes viewers feel',
          },
          'quote':
              'Every photo you take is a step forward. Look back only to see how far you\'ve come.',
        },
      },

      // Day 29: Final Assignment
      {
        'id': 'lesson_029',
        'day': 29,
        'title': 'Final Assignment',
        'subtitle': 'Shoot a Mini Series (3-5 Photos)',
        'description':
            'Create your capstone project: a cohesive photo series that demonstrates all the skills you\'ve learned.',
        'content': '''**🎯 What is a Photo Series?**

A photo series is a collection of 3-5 related photographs that work together to tell a complete story or explore a theme. It's different from random individual photos because:
• **All photos connect** to a central theme or story
• **Consistent style** and editing approach
• **Planned composition** and flow between images
• **Complete narrative** with beginning, middle, and end

**📝 Planning Your Series**

**Choose a theme:**
• **Daily life:** Your morning routine, family dinner, evening walk
• **Local culture:** Street food vendor, local market, traditional craft
• **Personal story:** Learning photography, a hobby, a relationship
• **Seasonal moment:** Monsoon, festival preparation, harvest time
• **Character study:** Portrait series of one person in different moods

**Series structure (3-5 photos):**
1. **Establishing shot:** Wide view showing the setting/context
2. **Medium shot:** Main subject in their environment
3. **Detail shot:** Close-up of important elements
4. **Action/emotion:** Key moment or feeling
5. **Conclusion:** Final image that completes the story

**📸 Technical Consistency**

**Maintain similar:**
• **Lighting style:** All natural light or all artificial
• **Color palette:** Warm tones, cool tones, or black & white
• **Editing approach:** Same filter/preset at consistent intensity
• **Composition style:** Similar framing and rule of thirds usage

**Vary for interest:**
• **Shot sizes:** Wide, medium, close-up
• **Angles:** Eye level, high angle, low angle
• **Focus points:** Different subjects within the theme

**🇮🇳 Indian Series Ideas**

**Cultural themes:**
• Chai wallah preparing and serving tea
• Grandmother cooking traditional meal
• Local temple morning rituals
• Street art in your neighborhood
• Monsoon through your window

**Personal themes:**
• Your photography learning journey
• Family gathering preparation
• Student life during exams
• Local festival celebration
• Evening life in your locality

**🎨 Storytelling Through Series**

**Narrative flow:**
• **Beginning:** Set the scene, introduce the subject
• **Development:** Show process, action, or change
• **Climax:** Key moment of emotion or action
• **Resolution:** Conclusion, reflection, or result

**Emotional arc:**
• Consider the feeling journey through your series
• Start calm, build tension, resolve peacefully
• Or: Show transformation, growth, or discovery

**📱 Shooting Tips for Series**

**Before shooting:**
• Scout your location if needed
• Plan your shots but be open to spontaneous moments
• Ensure good lighting throughout the series
• Bring any props or equipment needed

**During shooting:**
• Take multiple versions of each planned shot
• Capture extra moments that support the story
• Pay attention to consistent lighting
• Don't rush - take time for each image

**After shooting:**
• Review all images before final selection
• Choose photos that work well together
• Edit consistently across all images
• Test different ordering of the series

**🖥️ Editing Your Series**

**Consistency checklist:**
• Similar exposure and contrast levels
• Consistent color temperature/white balance
• Same editing style and intensity
• Matching cropping approach where appropriate

**Series-specific edits:**
• Ensure all photos complement each other
• No single photo should look drastically different
• Adjust individual photos to support overall narrative
• Consider black & white for timeless feel

**📖 Presentation Tips**

**Order matters:**
• Arrange photos in narrative sequence
• Consider visual flow from one image to next
• Strong opening and closing images
• Build tension and release appropriately

**Sharing your series:**
• Instagram carousel posts work well for series
• Include caption explaining the story/theme
• Number the photos (1/4, 2/4, etc.)
• Ask viewers which image resonates most''',
        'estimatedDuration': 90,
        'type': 'project',
        'difficulty': 'beginner',
        'categories': ['Photo Series', 'Storytelling', 'Final Project'],
        'objectives': [
          'Plan and execute a cohesive photo series',
          'Apply all learned photography techniques together',
          'Demonstrate storytelling through sequential images',
          'Create portfolio-worthy work as course capstone',
        ],
        'exercises': [
          {
            'id': 'exercise_029_01',
            'title': 'Mini Photo Series Project',
            'description':
                'Create a complete 3-5 photo series demonstrating your photography journey',
            'steps': [
              'Choose a theme that interests you personally',
              'Plan your 3-5 shots: wide, medium, close-up, action, conclusion',
              'Scout location and plan lighting (use natural light)',
              'Shoot your series, taking multiple versions of each shot',
              'Review and select the best image for each part of story',
              'Edit consistently across all images',
              'Arrange in narrative order that tells complete story',
              'Share with title and brief explanation of your story',
            ],
            'requirements': {
              'series': '3-5 related photos telling one story',
              'planning': 'Clear theme and shot list',
              'consistency': 'Consistent editing and style',
              'time': '90 minutes',
            },
            'estimatedTime': 90,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Photo Series': 'Collection of related images telling one story',
            'Theme': 'Central idea connecting all photos',
            'Narrative Flow': 'How story progresses through images',
            'Visual Consistency': 'Similar look and feel across photos',
            'Capstone Project': 'Final project demonstrating all skills',
          },
          'quote': 'One photo speaks. A series tells a full story.',
        },
      },

      // Day 30: Graduation
      {
        'id': 'lesson_030',
        'day': 30,
        'title': 'Graduation',
        'subtitle': 'Celebrate + Share Your Work!',
        'description':
            'Celebrate completing your 30-day photography journey and plan your continued learning path.',
        'content': '''**🎓 Congratulations, You Did It!**

You have completed 30 days of dedicated photography learning! This is a significant achievement that many people start but few finish. You should be proud of:
• **Consistency:** Showing up every day for learning
• **Growth:** Developing new skills and creative vision
• **Courage:** Sharing your work and seeking feedback
• **Dedication:** Completing exercises and challenges

**📈 How Much You've Learned**

**Technical skills:**
• Camera settings (ISO, Aperture, Shutter Speed)
• Lighting techniques (natural and artificial)
• Composition rules and when to break them
• Mobile photography with manual controls
• Basic photo editing and enhancement

**Creative skills:**
• Seeing photographic opportunities in daily life
• Telling stories through images
• Developing personal style and vision
• Understanding light and shadow
• Creating emotional connection through photos

**🎯 Reflection Questions**

**Look back at your journey:**
• What type of photography do you enjoy most?
• Which lesson or technique had the biggest impact?
• How have your photos improved from Day 1 to Day 30?
• What challenged you the most during this course?
• What surprised you about photography?

**🏆 Creating Your Graduation Portfolio**

**Select your best work:**
• Choose 5-10 photos that represent your best work
• Include variety: portraits, landscapes, objects, series
• Show progression from early to recent work
• Pick photos that make you feel proud

**Document your journey:**
• Create a before/after comparison (Day 1 vs Day 30)
• Write about your biggest breakthrough moment
• Share your favorite photograph and why it's special
• List three things you learned about yourself

**📱 Graduation Celebration Ideas**

**Share your achievement:**
• Post a photo carousel showing your best work
• Write about your 30-day photography journey
• Use hashtag #MyFirst30DaysOfPhotography
• Thank people who supported your learning

**Print your work:**
• Choose 1-3 photos to print and frame
• Display them in your home or office
• Give prints as gifts to family members
• Create a small photo album of your journey

**🚀 What's Next? Continuing Your Photography Journey**

**Immediate next steps:**
• Continue taking photos daily (even just one)
• Join local photography groups or communities
• Practice one technique repeatedly until mastered
• Experiment with new subjects and styles

**Advanced learning options:**
• **Specialized courses:** Portrait, landscape, street photography
• **Technical skills:** Advanced editing, lighting setups
• **Equipment:** Consider upgrading camera if interested
• **Projects:** 365-day photo challenge, photo book creation

**🇮🇳 Photography Opportunities in India**

**Local subjects to explore:**
• Document changing seasons in your area
• Capture local festivals and cultural events
• Explore architectural heritage in your city
• Street photography in markets and public spaces
• Portrait series of local craftspeople or artists

**Photography communities to join:**
• Delhi Photography Club, Mumbai Photography Meetup
• Online groups: Indian Photography Community
• Instagram hashtags: #IndiaClicks #PhotographersOfIndia
• Local camera stores often host photography walks

**📚 Resources for Continued Learning**

**Free online resources:**
• YouTube channels: Mango Street, Sean Tucker, Jamie Windsor
• Instagram accounts: @bradengunem @jordanhammond @bradengunem
• Websites: PetaPixel, Digital Photography School

**Books to read:**
• "Understanding Exposure" by Bryan Peterson
• "The Art of Photography" by Bruce Barnbaum
• "Street Photography" by Vivian Maier

**💡 Final Photography Tips**

**Remember these principles:**
• **Light is everything** - always consider your lighting
• **Composition guides the eye** - use it intentionally
• **Story matters more than gear** - focus on content
• **Practice makes progress** - shoot regularly
• **Mistakes are learning opportunities** - embrace them

**Keep growing:**
• Challenge yourself with new subjects monthly
• Seek feedback from other photographers
• Study work of photographers you admire
• Never stop experimenting and learning

**🎉 Final Words**

Photography is a lifelong journey of discovery. You've built a strong foundation in these 30 days, but this is just the beginning. The camera is now a tool for seeing the world differently, capturing memories, and expressing your unique perspective.

Keep shooting, keep learning, and most importantly, keep enjoying the process. The world needs your unique vision and voice through photography.

**Welcome to the wonderful world of photography. You are now a photographer!**''',
        'estimatedDuration': 60,
        'type': 'celebration',
        'difficulty': 'beginner',
        'categories': ['Graduation', 'Reflection', 'Future Planning'],
        'objectives': [
          'Celebrate completion of 30-day photography course',
          'Reflect on learning journey and progress made',
          'Create graduation portfolio of best work',
          'Plan continued photography learning and growth',
        ],
        'exercises': [
          {
            'id': 'exercise_030_01',
            'title': 'Photography Graduation Project',
            'description':
                'Celebrate your achievement and plan your continued photography journey',
            'steps': [
              'Select your top 5 photos from the entire 30-day course',
              'Create a before/after comparison (Day 1 vs Day 30 photos)',
              'Write a reflection: What did you learn? What surprised you?',
              'Share your graduation post on social media with your journey',
              'Choose one photo to print or frame as a celebration',
              'Plan your next photography goal or project',
              'Join one photography community or group for continued learning',
              'Take a final "graduation selfie" with your camera/phone',
            ],
            'requirements': {
              'portfolio': 'Top 5 photos from entire course',
              'reflection': 'Written summary of learning journey',
              'celebration': 'Share achievement publicly',
              'planning': 'Set next photography goal',
              'time': '60 minutes',
            },
            'estimatedTime': 60,
          },
        ],
        'imageUrls': [],
        'technicalDetails': {
          'vocabulary': {
            'Portfolio': 'Collection of your best photographic work',
            'Graduation': 'Completion of learning journey',
            'Reflection': 'Thinking about what you\'ve learned',
            'Photography Journey': 'Ongoing process of learning and growth',
            'Community': 'Group of photographers who support each other',
          },
          'quote':
              'You\'re not just taking photos now---you\'re making them. The world needs your unique vision. Keep shooting! 📷',
        },
      },
    ];
  }
}
