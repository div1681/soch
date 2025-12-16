import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soch/models/user_model.dart';
import 'package:soch/screens/auth/login_screen.dart';
import 'package:soch/screens/home/navigator_screen.dart';
import 'package:soch/services/auth_services.dart';
import 'package:soch/services/user_services.dart';
import 'package:soch/widgets/splash_skeleton.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const SizedBox(); // Just wait, don't show skeleton again
        }
        if (!authSnap.hasData) return const LoginScreen();

        return FutureBuilder<UserModel?>(
          future: UserService().getCurrentUser(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const SizedBox(); 
            }
            if (!userSnap.hasData) {
              return const Scaffold(
                body: Center(child: Text('User doc missing')),
              );
            }
            return const HomeScreen();
          },
        );
      },
    );
  }
}
