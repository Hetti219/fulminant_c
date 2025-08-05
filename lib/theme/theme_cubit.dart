import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ThemeType { light, dark, system }

class ThemeState {
  final ThemeType themeType;
  final ThemeData themeData;
  final Brightness brightness;

  const ThemeState({
    required this.themeType,
    required this.themeData,
    required this.brightness,
  });

  ThemeState copyWith({
    ThemeType? themeType,
    ThemeData? themeData,
    Brightness? brightness,
  }) {
    return ThemeState(
      themeType: themeType ?? this.themeType,
      themeData: themeData ?? this.themeData,
      brightness: brightness ?? this.brightness,
    );
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(
    themeType: ThemeType.system,
    themeData: _getThemeData(ThemeType.system),
    brightness: _getBrightness(ThemeType.system),
  )) {
    _initializeTheme();
  }

  void _initializeTheme() {
    // Get system brightness and set initial theme
    final systemBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _updateTheme(ThemeType.system, systemBrightness);
  }

  void setTheme(ThemeType themeType) {
    final systemBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _updateTheme(themeType, systemBrightness);
  }

  void _updateTheme(ThemeType themeType, Brightness systemBrightness) {
    final themeData = _getThemeData(themeType, systemBrightness);
    final brightness = _getBrightness(themeType, systemBrightness);
    
    emit(ThemeState(
      themeType: themeType,
      themeData: themeData,
      brightness: brightness,
    ));

    // Update system UI overlay style
    _updateSystemUIOverlay(brightness);
  }

  void _updateSystemUIOverlay(Brightness brightness) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness == Brightness.light 
            ? Brightness.dark 
            : Brightness.light,
        statusBarBrightness: brightness,
        systemNavigationBarColor: brightness == Brightness.light
            ? const Color(0xFFFFFBFE)
            : const Color(0xFF131316),
        systemNavigationBarIconBrightness: brightness == Brightness.light 
            ? Brightness.dark 
            : Brightness.light,
      ),
    );
  }

  static ThemeData _getThemeData(ThemeType themeType, [Brightness? systemBrightness]) {
    switch (themeType) {
      case ThemeType.light:
        return _lightTheme;
      case ThemeType.dark:
        return _darkTheme;
      case ThemeType.system:
        final brightness = systemBrightness ?? 
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.light ? _lightTheme : _darkTheme;
    }
  }

  static Brightness _getBrightness(ThemeType themeType, [Brightness? systemBrightness]) {
    switch (themeType) {
      case ThemeType.light:
        return Brightness.light;
      case ThemeType.dark:
        return Brightness.dark;
      case ThemeType.system:
        return systemBrightness ?? 
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
  }

  // Theme data definitions
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color scheme
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6366F1), // Indigo
      primaryContainer: Color(0xFFE0E7FF),
      secondary: Color(0xFF10B981), // Emerald
      secondaryContainer: Color(0xFFD1FAE5),
      tertiary: Color(0xFFF59E0B), // Amber
      tertiaryContainer: Color(0xFFFEF3C7),
      surface: Color(0xFFFFFBFE),
      surfaceContainerHighest: Color(0xFFF4F4F5),
      error: Color(0xFFEF4444),
      errorContainer: Color(0xFFFEE2E2),
      onPrimary: Color(0xFFFFFFFF),
      onPrimaryContainer: Color(0xFF1E1B4B),
      onSecondary: Color(0xFFFFFFFF),
      onSecondaryContainer: Color(0xFF064E3B),
      onSurface: Color(0xFF1C1B1F),
      onSurfaceVariant: Color(0xFF49454F),
      onError: Color(0xFFFFFFFF),
      onErrorContainer: Color(0xFF7F1D1D),
      outline: Color(0xFF79747E),
      outlineVariant: Color(0xFFCAC4D0),
    ),
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFBFE),
      foregroundColor: Color(0xFF1C1B1F),
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Color(0xFF6366F1),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        color: Color(0xFF1C1B1F),
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFFFBFE),
      selectedItemColor: Color(0xFF6366F1),
      unselectedItemColor: Color(0xFF49454F),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedIconTheme: IconThemeData(size: 28),
      unselectedIconTheme: IconThemeData(size: 24),
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF6366F1),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      color: Color(0xFFFFFBFE),
      surfaceTintColor: Color(0xFF6366F1),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.all(8),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF4F4F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Color(0xFF79747E),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Color(0xFFCAC4D0),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Color(0xFF6366F1),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Color(0xFFEF4444),
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(
        color: Color(0xFF49454F),
        fontSize: 16,
      ),
      hintStyle: TextStyle(
        color: Color(0xFF49454F),
        fontSize: 16,
      ),
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color scheme
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFA5B4FC), // Light indigo
      primaryContainer: Color(0xFF3730A3),
      secondary: Color(0xFF6EE7B7), // Light emerald
      secondaryContainer: Color(0xFF047857),
      tertiary: Color(0xFFFBBF24), // Light amber
      tertiaryContainer: Color(0xFFD97706),
      surface: Color(0xFF131316),
      surfaceContainerHighest: Color(0xFF1F1F23),
      error: Color(0xFFF87171),
      errorContainer: Color(0xFF93281A),
      onPrimary: Color(0xFF1E1B4B),
      onPrimaryContainer: Color(0xFFE0E7FF),
      onSecondary: Color(0xFF064E3B),
      onSecondaryContainer: Color(0xFFD1FAE5),
      onSurface: Color(0xFFE6E1E5),
      onSurfaceVariant: Color(0xFFCAC4D0),
      onError: Color(0xFF690E04),
      onErrorContainer: Color(0xFFFFDAD6),
      outline: Color(0xFF938F99),
      outlineVariant: Color(0xFF49454F),
    ),
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF131316),
      foregroundColor: Color(0xFFE6E1E5),
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Color(0xFFA5B4FC),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: Color(0xFFE6E1E5),
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF131316),
      selectedItemColor: Color(0xFFA5B4FC),
      unselectedItemColor: Color(0xFFCAC4D0),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedIconTheme: IconThemeData(size: 28),
      unselectedIconTheme: IconThemeData(size: 24),
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFA5B4FC),
        foregroundColor: Color(0xFF1E1B4B),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      color: Color(0xFF131316),
      surfaceTintColor: Color(0xFFA5B4FC),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.all(8),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF1F1F23),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Color(0xFF938F99),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Color(0xFF49454F),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Color(0xFFA5B4FC),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Color(0xFFF87171),
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(
        color: Color(0xFFCAC4D0),
        fontSize: 16,
      ),
      hintStyle: TextStyle(
        color: Color(0xFFCAC4D0),
        fontSize: 16,
      ),
    ),
  );
}