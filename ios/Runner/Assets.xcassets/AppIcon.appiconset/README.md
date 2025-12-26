# iOS App Icon Requirements

## Required Icon Sizes

Place PNG files in this directory with exact names:

### iPhone
- `Icon-20@2x.png` - 40x40 px (Spotlight, Settings)
- `Icon-20@3x.png` - 60x60 px (Spotlight, Settings)
- `Icon-29@2x.png` - 58x58 px (Settings)
- `Icon-29@3x.png` - 87x87 px (Settings)
- `Icon-40@2x.png` - 80x80 px (Spotlight)
- `Icon-40@3x.png` - 120x120 px (Spotlight)
- `Icon-60@2x.png` - 120x120 px (App)
- `Icon-60@3x.png` - 180x180 px (App)

### iPad
- `Icon-20.png` - 20x20 px (Spotlight, Settings)
- `Icon-20@2x.png` - 40x40 px (Spotlight, Settings)
- `Icon-29.png` - 29x29 px (Settings)
- `Icon-29@2x.png` - 58x58 px (Settings)
- `Icon-40.png` - 40x40 px (Spotlight)
- `Icon-40@2x.png` - 80x80 px (Spotlight)
- `Icon-76.png` - 76x76 px (App)
- `Icon-76@2x.png` - 152x152 px (App)
- `Icon-83.5@2x.png` - 167x167 px (iPad Pro)

### App Store
- `Icon-1024.png` - 1024x1024 px (App Store listing)

## Design Guidelines

### Colors
- Primary: Blue (#2196F3) - Represents health and trust
- Secondary: Orange (#FF9800) - Represents energy and food
- Accent: Green (#4CAF50) - Represents healthy living

### Icon Design Suggestions

**Option 1: Fork & Plate**
```
┌─────────────────┐
│                 │
│   🍽️  🍴       │
│                 │
│   TürkKalori   │
│                 │
└─────────────────┘
```
- Minimalist fork and plate icon
- Gradient background (blue to green)
- Modern, clean look

**Option 2: Calorie Ring**
```
┌─────────────────┐
│                 │
│      ⭕️        │
│    /  |  \     │
│   🍎 🥗 🥖    │
│                 │
└─────────────────┘
```
- Circular progress ring
- Turkish food icons inside
- Vibrant, colorful

**Option 3: Letter T**
```
┌─────────────────┐
│                 │
│       T         │
│     ─────       │
│      │          │
│   (stylized)    │
│                 │
└─────────────────┘
```
- Stylized "T" for TürkKalori
- Food elements integrated
- Professional, brand-focused

### Technical Requirements

✅ **Format**: PNG (no transparency for 1024x1024)
✅ **Color Space**: sRGB or Display P3
✅ **No Alpha Channel**: For App Store icon
✅ **No Text**: Avoid small text (unreadable at small sizes)
✅ **Consistent Design**: Same visual across all sizes
✅ **Rounded Corners**: iOS automatically applies mask
✅ **Safe Area**: Keep important elements away from edges

### Tools for Generation

1. **Figma/Sketch**: Design at 1024x1024, export all sizes
2. **Online Generators**:
   - https://appicon.co
   - https://makeappicon.com
   - https://resizeappicon.com
3. **Command Line** (ImageMagick):
   ```bash
   # Install ImageMagick
   brew install imagemagick

   # Generate from 1024x1024 source
   convert Icon-Source-1024.png -resize 40x40 Icon-20@2x.png
   convert Icon-Source-1024.png -resize 60x60 Icon-20@3x.png
   # ... repeat for all sizes
   ```

### Quick Generation Script

Save as `generate_icons.sh`:

```bash
#!/bin/bash

SOURCE="Icon-Source-1024.png"

if [ ! -f "$SOURCE" ]; then
    echo "Error: $SOURCE not found!"
    echo "Place your 1024x1024 icon as Icon-Source-1024.png"
    exit 1
fi

# iPhone
convert $SOURCE -resize 40x40 Icon-20@2x.png
convert $SOURCE -resize 60x60 Icon-20@3x.png
convert $SOURCE -resize 58x58 Icon-29@2x.png
convert $SOURCE -resize 87x87 Icon-29@3x.png
convert $SOURCE -resize 80x80 Icon-40@2x.png
convert $SOURCE -resize 120x120 Icon-40@3x.png
convert $SOURCE -resize 120x120 Icon-60@2x.png
convert $SOURCE -resize 180x180 Icon-60@3x.png

# iPad
convert $SOURCE -resize 20x20 Icon-20.png
convert $SOURCE -resize 40x40 Icon-20@2x.png
convert $SOURCE -resize 29x29 Icon-29.png
convert $SOURCE -resize 58x58 Icon-29@2x.png
convert $SOURCE -resize 40x40 Icon-40.png
convert $SOURCE -resize 80x80 Icon-40@2x.png
convert $SOURCE -resize 76x76 Icon-76.png
convert $SOURCE -resize 152x152 Icon-76@2x.png
convert $SOURCE -resize 167x167 Icon-83.5@2x.png

# App Store
cp $SOURCE Icon-1024.png

echo "✅ All icons generated!"
```

Usage:
```bash
chmod +x generate_icons.sh
./generate_icons.sh
```

## Validation

Before submitting to App Store:

1. ✅ All sizes present
2. ✅ No transparency in 1024x1024
3. ✅ Consistent design across sizes
4. ✅ No copyrighted content
5. ✅ Readable at small sizes
6. ✅ Follows Apple Human Interface Guidelines

## Next Steps

1. Get icon designed by a graphic designer
2. Generate all required sizes
3. Place files in this directory
4. Build and test in Xcode
5. Submit to App Store

## Resources

- [Apple HIG - App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [App Icon Generator](https://appicon.co)
- [iOS Icon Templates](https://applypixels.com/template/ios-icon/)
