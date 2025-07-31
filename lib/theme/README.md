# Theme System Overview

## Files Structure

```
lib/
├── theme/
│   ├── app_colors.dart          # Color definitions for light/dark themes
│   ├── app_theme.dart           # Complete theme configurations
│   ├── theme_cubit.dart         # Theme state management
│   └── theme_test_page.dart     # Test page for theme validation
├── widgets/
│   └── theme_toggle_button.dart # Theme switching UI components
└── screens/
    └── settings/
        └── settings_screen.dart # Main settings screen with theme controls
```

## How Theme System Works

1. **Theme Management**: `ThemeCubit` manages theme state with three modes:
   - Light theme
   - Dark theme 
   - System theme (follows device setting)

2. **Theme Controls**: Theme can only be changed through:
   - Settings screen accessible via Profile → Settings
   - Theme toggle chip in the Appearance section

3. **Color System**: Uses Material 3 color scheme with:
   - Primary: Indigo (#6366F1 light, #A5B4FC dark)
   - Secondary: Emerald (#10B981 light, #6EE7B7 dark)
   - Tertiary: Amber (#F59E0B light, #FBBF24 dark)

4. **Default Behavior**: App starts with system theme (matches device)

## Usage

### In Components
```dart
// Use theme colors instead of hardcoded colors
color: Theme.of(context).colorScheme.primary
backgroundColor: Theme.of(context).colorScheme.surface
```

### Changing Theme
Users can change theme via:
1. Profile Screen → Settings Button
2. Settings Screen → Appearance Section → Theme Toggle