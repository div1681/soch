import 'package:flutter/material.dart';
import 'package:soch/utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('About', style: GoogleFonts.bodoniModa(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SOCH.',
                style: GoogleFonts.bodoniModa(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.accent,
                  letterSpacing: 4.0,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'v1.0.0 (Beta)',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'A premium blogging platform designed for storytellers. Experience content like never before with our immersive, minimalist interface.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  height: 1.6,
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 48),
              Divider(color: Colors.grey.withOpacity(0.2)),
              const SizedBox(height: 24),
              _buildLink('Terms of Service'),
              const SizedBox(height: 16),
              _buildLink('Privacy Policy'),
              const SizedBox(height: 16),
              _buildLink('Licenses'),
              const Spacer(),
              Text(
                'Designed & Built by Divyansh',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLink(String text) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.accent,
        ),
      ),
    );
  }
}
