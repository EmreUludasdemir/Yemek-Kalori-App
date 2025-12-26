# Android App Icon Requirements

## Required Icon Sizes

Place PNG files in corresponding mipmap directories:

### App Icon (Launcher Icon)

| Density | Folder | Size | Filename |
|---------|--------|------|----------|
| LDPI | mipmap-ldpi | 36x36 | ic_launcher.png |
| MDPI | mipmap-mdpi | 48x48 | ic_launcher.png |
| HDPI | mipmap-hdpi | 72x72 | ic_launcher.png |
| XHDPI | mipmap-xhdpi | 96x96 | ic_launcher.png |
| XXHDPI | mipmap-xxhdpi | 144x144 | ic_launcher.png |
| XXXHDPI | mipmap-xxxhdpi | 192x192 | ic_launcher.png |

### Play Store Icon

| Type | Size | Format | Filename |
|------|------|--------|----------|
| Play Store Listing | 512x512 | PNG (32-bit) | ic_launcher_playstore.png |

### Adaptive Icon (Android 8.0+)

For adaptive icons, you need foreground and background layers:

| Density | Size | Foreground | Background |
|---------|------|------------|------------|
| MDPI | 108x108 | ic_launcher_foreground.png | ic_launcher_background.png |
| HDPI | 162x162 | ic_launcher_foreground.png | ic_launcher_background.png |
| XHDPI | 216x216 | ic_launcher_foreground.png | ic_launcher_background.png |
| XXHDPI | 324x324 | ic_launcher_foreground.png | ic_launcher_background.png |
| XXXHDPI | 432x432 | ic_launcher_foreground.png | ic_launcher_background.png |

## Directory Structure

```
android/app/src/main/res/
├── mipmap-ldpi/
│   └── ic_launcher.png (36x36)
├── mipmap-mdpi/
│   ├── ic_launcher.png (48x48)
│   ├── ic_launcher_foreground.png (108x108)
│   └── ic_launcher_background.png (108x108)
├── mipmap-hdpi/
│   ├── ic_launcher.png (72x72)
│   ├── ic_launcher_foreground.png (162x162)
│   └── ic_launcher_background.png (162x162)
├── mipmap-xhdpi/
│   ├── ic_launcher.png (96x96)
│   ├── ic_launcher_foreground.png (216x216)
│   └── ic_launcher_background.png (216x216)
├── mipmap-xxhdpi/
│   ├── ic_launcher.png (144x144)
│   ├── ic_launcher_foreground.png (324x324)
│   └── ic_launcher_background.png (324x324)
├── mipmap-xxxhdpi/
│   ├── ic_launcher.png (192x192)
│   ├── ic_launcher_foreground.png (432x432)
│   └── ic_launcher_background.png (432x432)
└── mipmap-anydpi-v26/
    └── ic_launcher.xml (adaptive icon config)
```

## Design Guidelines

### Safe Zone
- Keep important content within 66dp circle
- Adaptive icons can be masked into different shapes
- System may apply various shapes: circle, square, rounded square, squircle

### Colors
Use same color scheme as iOS:
- Primary: #2196F3 (Blue)
- Secondary: #FF9800 (Orange)
- Accent: #4CAF50 (Green)

### Adaptive Icon Configuration

Create `mipmap-anydpi-v26/ic_launcher.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
```

Or with color background:

```xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
```

Add to `res/values/colors.xml`:
```xml
<color name="ic_launcher_background">#2196F3</color>
```

## Generation Scripts

### Using Android Studio
1. Right-click `res` folder
2. New → Image Asset
3. Select "Launcher Icons (Adaptive and Legacy)"
4. Choose foreground image
5. Set background color or image
6. Click Next → Finish

### Using ImageMagick (Command Line)

Save as `android/generate_icons.sh`:

```bash
#!/bin/bash

SOURCE="icon_source_1024.png"

if [ ! -f "$SOURCE" ]; then
    echo "Error: $SOURCE not found!"
    exit 1
fi

# Legacy icons
convert $SOURCE -resize 36x36 app/src/main/res/mipmap-ldpi/ic_launcher.png
convert $SOURCE -resize 48x48 app/src/main/res/mipmap-mdpi/ic_launcher.png
convert $SOURCE -resize 72x72 app/src/main/res/mipmap-hdpi/ic_launcher.png
convert $SOURCE -resize 96x96 app/src/main/res/mipmap-xhdpi/ic_launcher.png
convert $SOURCE -resize 144x144 app/src/main/res/mipmap-xxhdpi/ic_launcher.png
convert $SOURCE -resize 192x192 app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

# Play Store
convert $SOURCE -resize 512x512 app/src/main/res/mipmap-xxxhdpi/ic_launcher_playstore.png

echo "✅ Legacy icons generated!"
echo "⚠️  Generate adaptive icons (foreground/background) separately"
```

### Using Online Tools
- https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html
- https://appicon.co/#app-icon
- https://easyappicon.com/

## Play Store Assets

Beyond app icons, you also need:

### Feature Graphic
- Size: 1024 x 500 px
- Format: PNG or JPEG
- Max file size: 1 MB
- Used in Play Store listing header

### Screenshots (Required)
- Minimum 2 screenshots
- Maximum 8 screenshots
- Format: PNG or JPEG
- Dimensions:
  - Phone: 16:9 or 9:16 ratio
  - Minimum: 320px
  - Maximum: 3840px

### Promo Video (Optional)
- YouTube URL
- Shows in Play Store listing

## Validation Checklist

Before submission:

- ✅ All density icons present
- ✅ 512x512 Play Store icon
- ✅ Adaptive icon XML configured
- ✅ Icons are PNG format
- ✅ No transparency in background layer
- ✅ Consistent branding across all sizes
- ✅ Safe zone respected for adaptive icons
- ✅ Feature graphic created (1024x500)
- ✅ Minimum 2 screenshots

## Testing

1. **Build and Install**:
   ```bash
   flutter build apk --release
   flutter install
   ```

2. **Check Different Launchers**:
   - Test on Pixel Launcher (Google)
   - Test on Samsung One UI
   - Test on OnePlus Launcher

3. **Check Icon Shapes**:
   - Settings → Display → Icon shape
   - Test Circle, Square, Rounded Square, Squircle

4. **Check Adaptive Behavior**:
   - Long press icon → App info
   - Check notification icon
   - Check recent apps screen

## Resources

- [Android Icon Design Guidelines](https://developer.android.com/guide/practices/ui_guidelines/icon_design_launcher)
- [Adaptive Icons](https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive)
- [Material Design Icons](https://material.io/design/iconography)
- [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/)
