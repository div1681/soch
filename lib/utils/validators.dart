import 'package:flutter/material.dart';
import 'package:soch/models/user_model.dart';
import 'package:soch/screens/auth/login_screen.dart';
import 'package:soch/screens/home/profile_screen.dart';
import 'package:soch/screens/home/profile_setup_screen.dart';
import 'package:soch/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soch/services/user_services.dart';

class MainWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snap.hasData) return const LoginScreen();

        return FutureBuilder<UserModel?>(
          future: UserService().getCurrentUser(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (!userSnap.hasData) {
              return const Scaffold(body: Center(child: Text('No user doc')));
            }

            final u = userSnap.data!;
            return u.username.isEmpty
                ? const SetupProfileScreen()
                : ProfileScreen(uid: u.uid);
          },
        );
      },
    );
  }
}
