import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soch/services/theme_service.dart';
import 'package:soch/services/auth_services.dart';
import 'package:soch/utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // Current theme usage for background
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.bodoniModa(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // 1. Dark Mode
            _buildSettingTile(
              title: 'Dark Mode',
              icon: isDark ? CupertinoIcons.moon_fill : CupertinoIcons.moon,
              trailing: CupertinoSwitch(
                value: isDark,
                activeColor: AppTheme.accent,
                trackColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                onChanged: (val) => ThemeService().toggleTheme(val),
              ),
            ),
            
            const SizedBox(height: 24),

            // 2. Edit Profile
            _buildSettingTile(
              title: 'Edit Profile',
              icon: CupertinoIcons.person,
              trailing: Icon(CupertinoIcons.chevron_forward, size: 20, color: Colors.grey.shade500),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),

            const SizedBox(height: 24),

            // 3. About
            _buildSettingTile(
              title: 'About',
              icon: CupertinoIcons.info,
              trailing: Icon(CupertinoIcons.chevron_forward, size: 20, color: Colors.grey.shade500),
              onTap: () => Navigator.pushNamed(context, '/about'),
            ),

             const SizedBox(height: 40),
             
             // Divider for logic separation (optional, but keeps it clean)
             Divider(color: Colors.grey.withOpacity(0.1)),
             const SizedBox(height: 40),

            // 3. Log Out
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                   Navigator.pop(context); 
                   await AuthService().signOut();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.accent.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Log Out', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ),
            
            const Spacer(),
            Text(
              "SOCH.", 
              style: GoogleFonts.bodoniModa(
                fontSize: 24, 
                color: Colors.grey.withOpacity(0.3),
                fontWeight: FontWeight.w900
              )
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required IconData icon,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.05))),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.iconTheme.color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
