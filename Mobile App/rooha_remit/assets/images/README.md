# Assets Directory

## Logo Requirements

Place your Wegagen Bank logo as `logo.png` in this directory.

**Recommended specifications:**
- **Size**: 1024x1024 pixels (minimum 512x512)
- **Format**: PNG with transparent background
- **Quality**: High resolution for crisp display on all devices

## Current Setup

Your app is configured to use:
- **Launcher Icons**: Generated from `assets/images/logo.png`
- **Splash Screen**: Uses the same logo with white background
- **In-App Logo**: Login and register screens display the logo

## Generate Icons & Splash

After adding your logo, run these commands:

```bash
# Generate launcher icons
flutter pub run flutter_launcher_icons:main

# Generate native splash screen
flutter pub run flutter_native_splash:create
```

## App Flow

1. **Native Splash** (OS level) → Shows logo instantly when app opens
2. **Custom Splash Screen** (Flutter) → 2-second loading with logo and branding
3. **Onboarding/Login** → Logo displayed in authentication screens
4. **Main App** → Wegagen branding throughout