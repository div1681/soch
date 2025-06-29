import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_services.dart';
import '../services/auth_services.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static const Color _bgColor = Color(0xFFFDFDFD);
  static const Color _textColor = Color(0xFF202124);
  static const Color _accentColor = Color(0xFFB22222);
  static const Color _dividerColor = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Drawer(
      backgroundColor: _bgColor,
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
                        style: TextStyle(
                          color: _accentColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: _accentColor.withOpacity(0.1),
                        backgroundImage:
                            (user?.profilepicurl.isNotEmpty ?? false)
                            ? NetworkImage(user!.profilepicurl)
                            : null,
                        child: (user?.profilepicurl.isEmpty ?? true)
                            ? Icon(Icons.person, size: 42, color: _textColor)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.username ?? 'User',
                        style: const TextStyle(
                          color: _textColor,
                          fontSize: 18,
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
                      _buildDivider(),
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
                    ],
                  ),
                ),

                _buildDivider(),

                _DrawerTile(
                  icon: Icons.logout,
                  label: 'Logout',
                  iconColor: _accentColor,
                  onTap: () async {
                    Navigator.pop(context);
                    await AuthService().signOut();
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Made by Divyansh',
                  style: TextStyle(color: _accentColor.withOpacity(0.9)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDivider() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Divider(color: _dividerColor, thickness: 1),
  );
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
        leading: Icon(icon, color: iconColor ?? AppDrawer._textColor),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: const TextStyle(
              color: AppDrawer._textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: onTap,
        dense: true,
        horizontalTitleGap: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        hoverColor: AppDrawer._accentColor.withOpacity(0.08),
        splashColor: AppDrawer._accentColor.withOpacity(0.1),
      ),
    );
  }
}
