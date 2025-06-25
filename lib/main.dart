import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:soch/firebase_options.dart';
import 'package:soch/screens/auth/login_screen.dart';
import 'package:soch/screens/home/explore_screen.dart';
import 'package:soch/screens/home/profile_screen.dart';
import 'package:soch/utils/validators.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
  //just for dev period
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();
  //
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainWrapper());
  }
}
