import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_services.dart';
import '../services/auth_services.dart';
import 'package:soch/utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return const Drawer(child: Center(child: Text("Not logged in")));

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: FutureBuilder<UserModel?>(
        future: UserService().getUserById(uid),
        builder: (context, snap) {
          final user = snap.data;

          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Text(
                        'SOCH.',
                        style: GoogleFonts.outfit(
                          color: AppTheme.accent,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: AppTheme.accent.withOpacity(0.1),
                        backgroundImage:
                            (user?.profilePicUrl.isNotEmpty ?? false)
                            ? NetworkImage(user!.profilePicUrl)
                            : null,
                        child: (user?.profilePicUrl.isEmpty ?? true)
                            ? Icon(Icons.person, size: 42, color: theme.iconTheme.color)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.username ?? 'User',
                        style: GoogleFonts.outfit(
                          color: theme.textTheme.titleLarge?.color,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Divider(color: theme.dividerColor, thickness: 1),
                      ),
                      _DrawerTile(
                        icon: Icons.explore,
                        label: 'Explore',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/explore');
                        },
                      ),
                      _DrawerTile(
                        icon: Icons.edit,
                        label: 'Edit Profile',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                      // Removed Saved Stories & Drafts
                      _DrawerTile(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Divider(color: theme.dividerColor, thickness: 1),
                ),

                _DrawerTile(
                  icon: Icons.logout,
                  label: 'Logout',
                  iconColor: AppTheme.accent,
                  onTap: () async {
                    Navigator.pop(context);
                    await AuthService().signOut();
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Made by Divyansh',
                  style: GoogleFonts.outfit(color: AppTheme.accent.withOpacity(0.9)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Theme.of(context).iconTheme.color),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: onTap,
        dense: true,
        horizontalTitleGap: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        hoverColor: AppTheme.accent.withOpacity(0.08),
        splashColor: AppTheme.accent.withOpacity(0.1),
      ),
    );
  }
}
