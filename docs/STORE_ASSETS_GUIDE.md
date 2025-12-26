# Store Assets Guide - TürkKalori

This guide explains all visual assets needed for App Store and Play Store submission.

---

## 📱 App Icons

### iOS App Icons

See detailed guide: `ios/Runner/Assets.xcassets/AppIcon.appiconset/README.md`

**Required Sizes**:
- 20x20 (@2x, @3x)
- 29x29 (@2x, @3x)
- 40x40 (@2x, @3x)
- 60x60 (@2x, @3x)
- 76x76 (@1x, @2x)
- 83.5x83.5 (@2x)
- 1024x1024 (App Store)

### Android App Icons

See detailed guide: `android/app/src/main/res/ANDROID_ICONS_README.md`

**Required Densities**:
- LDPI: 36x36
- MDPI: 48x48
- HDPI: 72x72
- XHDPI: 96x96
- XXHDPI: 144x144
- XXXHDPI: 192x192
- Play Store: 512x512

**Adaptive Icons** (foreground + background):
- MDPI: 108x108
- HDPI: 162x162
- XHDPI: 216x216
- XXHDPI: 324x324
- XXXHDPI: 432x432

---

## 🎨 Feature Graphic

### Play Store Feature Graphic

**Specifications**:
- Size: 1024 x 500 pixels
- Format: PNG or JPEG (24-bit)
- Max file size: 1 MB
- Color space: sRGB

**Design Tips**:
- Keep text readable at small sizes
- Avoid important content at edges
- Use brand colors (#2196F3, #FF9800, #4CAF50)
- Show app's main value proposition

**Content Ideas**:
1. **Left Side** (400x500):
   - App icon or logo
   - Tagline: "Türk Mutfağına Özel AI Destekli Kalori Takibi"

2. **Center** (224x500):
   - Phone mockup with app screenshot
   - Show main feature (home screen or AI recognition)

3. **Right Side** (400x500):
   - Key features with icons:
     - 🍽️ 300+ Türk Yemeği
     - 🤖 AI Yemek Tanıma
     - 📊 Detaylı Takip
     - 🎯 Kişisel Hedefler

**File Name**: `feature_graphic_1024x500.png`
**Location**: `assets/store/feature_graphic_1024x500.png`

---

## 📸 Screenshots

### Requirements

**App Store (iOS)**:
- Minimum: 2 screenshots
- Maximum: 10 screenshots
- Formats:
  - iPhone 6.7": 1290 x 2796 pixels (portrait) or 2796 x 1290 (landscape)
  - iPhone 6.5": 1242 x 2688 pixels (portrait) or 2688 x 1242 (landscape)
  - iPhone 5.5": 1242 x 2208 pixels (portrait) or 2208 x 1242 (landscape)
  - iPad Pro (12.9"): 2048 x 2732 pixels (portrait) or 2732 x 2048 (landscape)

**Play Store (Android)**:
- Minimum: 2 screenshots
- Maximum: 8 screenshots
- Minimum dimension: 320 pixels
- Maximum dimension: 3840 pixels
- Aspect ratio: 16:9 or 9:16
- Format: PNG or JPEG (24-bit)
- Recommended: 1080 x 1920 pixels (portrait) or 1920 x 1080 (landscape)

### Screenshot Sequence

**Screenshot 1: Home Screen - Ana Ekran**
- Show: Daily calorie overview, macro rings, meal cards
- Caption TR: "Günlük kalori ve makro takibinizi tek bakışta görün"
- Caption EN: "See your daily calorie and macro tracking at a glance"
- File: `01_home_screen_1080x1920.png`

**Screenshot 2: AI Food Recognition - AI Yemek Tanıma**
- Show: Camera interface with food photo, AI recognition results
- Caption TR: "Fotoğraftan anlık yemek tanıma ve kalori hesaplama"
- Caption EN: "Instant food recognition and calorie calculation from photos"
- File: `02_ai_recognition_1080x1920.png`

**Screenshot 3: Turkish Food Database - Türk Mutfağı**
- Show: Food search with Turkish dishes, categories
- Caption TR: "300+ Türk yemeği ile zengin veritabanı"
- Caption EN: "Rich database with 300+ Turkish dishes"
- File: `03_food_database_1080x1920.png`

**Screenshot 4: Statistics - İstatistikler**
- Show: Weekly/monthly charts, progress graphs
- Caption TR: "Haftalık ve aylık beslenme analizleri"
- Caption EN: "Weekly and monthly nutrition analysis"
- File: `04_statistics_1080x1920.png`

**Screenshot 5: Recipes - Yemek Tarifleri**
- Show: Recipe list with photos, recipe detail screen
- Caption TR: "Sağlıklı ve lezzetli Türk yemekleri tarifleri"
- Caption EN: "Healthy and delicious Turkish food recipes"
- File: `05_recipes_1080x1920.png`

**Screenshot 6: Weight Tracking - Kilo Takibi**
- Show: Weight chart, goal progress, trend line
- Caption TR: "Hedeflerinize doğru ilerlemenizi grafiklerde takip edin"
- Caption EN: "Track your progress towards goals with charts"
- File: `06_weight_tracking_1080x1920.png`

**Screenshot 7: Social Features - Sosyal Özellikler**
- Show: Leaderboard, achievements, friends
- Caption TR: "Arkadaşlarınızla yarışın ve başarılarınızı paylaşın"
- Caption EN: "Compete with friends and share your achievements"
- File: `07_social_features_1080x1920.png`

**Screenshot 8: Macro Balance - Makro Dengesi**
- Show: Detailed macro breakdown, nutrient timeline
- Caption TR: "Protein, karb ve yağ dengenizi optimize edin"
- Caption EN: "Optimize your protein, carb, and fat balance"
- File: `08_macro_balance_1080x1920.png`

### Screenshot Design Template

Create screenshots with:

1. **Device Frame**: Use mockup tools (Figshot, Screenshot Creator)
2. **Status Bar**: Show realistic time (9:41), full battery, signal
3. **Content**: Use realistic but privacy-safe data
4. **Annotations**: Add text overlays highlighting key features
5. **Background**: Use gradient or solid color matching brand

**Recommended Tools**:
- **Figma**: Design custom screenshots
- **Figshot**: Add device frames
- **Screenshot Creator**: Automate screenshot generation
- **Previewed**: Create marketing screenshots

---

## 🎬 App Preview Video (Optional)

### Specifications

**App Store**:
- Length: 15-30 seconds recommended
- Format: M4V, MP4, or MOV
- Resolution: 1080p (1920x1080) or higher
- Codec: H.264 or HEVC
- Max file size: 500 MB

**Play Store**:
- YouTube video URL
- Length: 30 seconds to 2 minutes recommended
- Orientation: Portrait or landscape

### Video Script (30 seconds)

See `STORE_LISTING_TR.md` and `STORE_LISTING_EN.md` for detailed video scripts.

**Quick Overview**:
1. **00:00-05s**: Logo animation + tagline
2. **05:10s**: Show AI food recognition
3. **10:15s**: Display macro tracking
4. **15:20s**: Show progress charts
5. **20:25s**: Achievement badges
6. **25:30s**: Call to action

### Video Production Tips

- Use screen recording with annotations
- Add background music (royalty-free)
- Include voiceover in Turkish and English
- Show actual app interface, not mockups
- Highlight unique features (Turkish food database, AI recognition)
- End with download CTA

**Recommended Tools**:
- **ScreenFlow** (Mac): Screen recording + editing
- **Camtasia**: Cross-platform screen recorder
- **DaVinci Resolve**: Free video editing
- **Epidemic Sound**: Royalty-free music

---

## 🎨 Design Specifications

### Color Palette

```
Primary Blue:     #2196F3
Secondary Orange: #FF9800
Accent Green:     #4CAF50
Background White: #FFFFFF
Text Dark Gray:   #212121
Text Light Gray:  #757575
Error Red:        #F44336
Success Green:    #4CAF50
```

### Typography

**iOS**:
- Primary: SF Pro Display
- Secondary: SF Pro Text

**Android**:
- Primary: Roboto
- Secondary: Roboto Medium

### Brand Guidelines

**Logo Usage**:
- Minimum size: 32x32 pixels
- Clear space: Equal to logo height
- Don't stretch or distort
- Use on white or blue background only

**App Name**:
- Always: "TürkKalori" (Turkish)
- English: "TurkCalorie"
- Never: "Turk Kalori", "turkkalori", "TURKKALORI"

---

## 📂 File Organization

```
assets/store/
├── icons/
│   ├── ios/
│   │   ├── AppIcon.appiconset/
│   │   └── (all iOS icon sizes)
│   └── android/
│       ├── mipmap-ldpi/
│       ├── mipmap-mdpi/
│       ├── mipmap-hdpi/
│       ├── mipmap-xhdpi/
│       ├── mipmap-xxhdpi/
│       └── mipmap-xxxhdpi/
├── screenshots/
│   ├── ios/
│   │   ├── 6.7-inch/
│   │   ├── 6.5-inch/
│   │   ├── 5.5-inch/
│   │   └── 12.9-inch/
│   └── android/
│       ├── phone/
│       └── tablet/
├── feature_graphic_1024x500.png
├── promo_video_30s.mp4
└── README.md
```

---

## 🛠️ Generation Scripts

### Batch Screenshot Generator

Save as `tools/generate_screenshots.sh`:

```bash
#!/bin/bash

# Generate screenshots for different device sizes
# Requires ImageMagick

SOURCE_DIR="screenshots/source"
IOS_DIR="screenshots/ios"
ANDROID_DIR="screenshots/android"

# iOS 6.7" (iPhone 14 Pro Max, 15 Pro Max)
for img in $SOURCE_DIR/*.png; do
  filename=$(basename "$img")
  convert "$img" -resize 1290x2796 -gravity center -extent 1290x2796 \
    "$IOS_DIR/6.7-inch/$filename"
done

# iOS 6.5" (iPhone 11 Pro Max, XS Max)
for img in $SOURCE_DIR/*.png; do
  filename=$(basename "$img")
  convert "$img" -resize 1242x2688 -gravity center -extent 1242x2688 \
    "$IOS_DIR/6.5-inch/$filename"
done

# Android (1080x1920)
for img in $SOURCE_DIR/*.png; do
  filename=$(basename "$img")
  convert "$img" -resize 1080x1920 -gravity center -extent 1080x1920 \
    "$ANDROID_DIR/phone/$filename"
done

echo "✅ Screenshots generated!"
```

### Feature Graphic Generator

Save as `tools/generate_feature_graphic.sh`:

```bash
#!/bin/bash

# Generate Play Store feature graphic
# Requires ImageMagick

convert -size 1024x500 xc:"#2196F3" \
  -font "Roboto-Bold" -pointsize 48 -fill white \
  -gravity West -annotate +50+0 "TürkKalori" \
  -pointsize 24 \
  -annotate +50+60 "Türk Mutfağına Özel\nAI Destekli Kalori Takibi" \
  assets/store/feature_graphic_1024x500.png

echo "✅ Feature graphic generated!"
echo "⚠️  Edit with Figma/Photoshop for final design"
```

---

## ✅ Pre-Launch Checklist

### Icons
- [ ] iOS icons (all sizes) generated and added
- [ ] Android icons (all densities) generated and added
- [ ] Android adaptive icons (foreground + background) created
- [ ] Play Store 512x512 icon created
- [ ] Icons follow design guidelines (safe zone, colors)

### Screenshots
- [ ] Minimum 2 screenshots prepared
- [ ] Screenshots show key features
- [ ] Captions written in both Turkish and English
- [ ] Screenshots are privacy-safe (no real user data)
- [ ] File names are descriptive and organized

### Feature Graphic
- [ ] 1024x500 feature graphic created
- [ ] Design matches brand colors
- [ ] Text is readable
- [ ] Highlights main value proposition

### Video (Optional)
- [ ] 30-second app preview video created
- [ ] Video shows actual app interface
- [ ] Uploaded to YouTube (for Play Store)
- [ ] Converted to M4V/MP4 (for App Store)

### Metadata
- [ ] App name finalized
- [ ] Subtitle/tagline written
- [ ] Short description (80 chars) written
- [ ] Full description completed
- [ ] Keywords optimized
- [ ] What's new text prepared
- [ ] Privacy policy URL added
- [ ] Terms of service URL added

---

## 📊 Screenshot Localization

Create separate screenshots for each language:

**Turkish Screenshots**: `screenshots/tr/`
**English Screenshots**: `screenshots/en/`

Use localized:
- UI text
- Sample food names
- Captions and annotations

---

## 🔗 Resources

**Design Tools**:
- [Figma](https://figma.com) - UI design
- [Sketch](https://sketch.com) - UI design (Mac)
- [Adobe XD](https://adobe.com/products/xd.html) - UI design

**Mockup Tools**:
- [Figshot](https://figshot.com) - Device frames
- [Screenshot Creator](https://screenshots.pro) - Automated screenshots
- [Previewed](https://previewed.app) - Marketing screenshots
- [MockuPhone](https://mockuphone.com) - Free device mockups

**Icon Generators**:
- [App Icon Generator](https://appicon.co)
- [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/)
- [MakeAppIcon](https://makeappicon.com)

**Image Optimization**:
- [TinyPNG](https://tinypng.com) - PNG compression
- [ImageOptim](https://imageoptim.com) - Mac image optimizer
- [Squoosh](https://squoosh.app) - Web image compressor

**Video Tools**:
- [ScreenFlow](https://www.telestream.net/screenflow/) - Mac screen recording
- [Camtasia](https://www.techsmith.com/video-editor.html) - Cross-platform
- [DaVinci Resolve](https://www.blackmagicdesign.com/products/davinciresolve) - Free video editing

**Stock Media**:
- [Unsplash](https://unsplash.com) - Free photos
- [Pexels](https://pexels.com) - Free photos and videos
- [Epidemic Sound](https://epidemicsound.com) - Royalty-free music

---

**Last Updated**: December 26, 2025
**Version**: 1.0.0
