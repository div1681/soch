import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Colors
  static const Color primary = Color(0xFF000000); // Pitch Black
  static const Color accent = Color(0xFF2563EB); // Electric Blue
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFAFAFA); // Slightly off-white surface
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    cardColor: Colors.white, // Explicitly white for cards
    
    // Premium Typography
    textTheme: TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: -1.0,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16, height: 1.5, color: textPrimary, fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14, height: 1.4, color: textSecondary,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5,
      ),
    ),

    colorScheme: const ColorScheme.light(
      primary: accent,
      surface: surface,
      onSurface: textPrimary,
      secondary: accent,
      error: Color(0xFFEF4444),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: textPrimary),
      titleTextStyle: GoogleFonts.outfit(
        color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      modalBackgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent, 
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      hintStyle: const TextStyle(color: textSecondary),
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0C0C0C), // Deep Matte Black (Not pure OLED black for agency feel)
    primaryColor: primary,
    cardColor: const Color(0xFF161618),
    canvasColor: const Color(0xFF161618),
    
    // Premium Typography (Dark Mode)
    textTheme: TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFFF3F4F6), letterSpacing: -1.0,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFFF3F4F6), letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFFE5E7EB),
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFFE5E7EB),
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16, height: 1.5, color: const Color(0xFFD1D5DB), fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14, height: 1.4, color: const Color(0xFF9CA3AF),
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: Colors.white,
      ),
    ),

    colorScheme: const ColorScheme.dark(
      primary: accent,
      surface: Color(0xFF161618), // Carbon Grey
      onSurface: Color(0xFFE5E7EB),
      primaryContainer: Color(0xFF1F2937),
      secondary: accent,
      error: Color(0xFFCF6679),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0C0C0C),
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.outfit(
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,
      ),
    ),

    iconTheme: const IconThemeData(color: Color(0xFFD1D5DB)),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF161618),
      modalBackgroundColor: Color(0xFF161618),
      surfaceTintColor: Colors.transparent, 
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1F1F22),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
