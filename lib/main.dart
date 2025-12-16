import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:soch/firebase_options.dart';
import 'package:soch/screens/auth/login_screen.dart';
import 'package:soch/screens/blog/blog_detail.dart';
import 'package:soch/screens/blog/create_blog.dart';
import 'package:soch/screens/home/explore_screen.dart';
import 'package:soch/screens/home/profile_setup_screen.dart';
import 'package:soch/main_wrapper.dart';
import 'package:soch/screens/settings/settings_screen.dart';
import 'package:soch/screens/settings/about_screen.dart';
import 'package:soch/services/theme_service.dart';
import 'package:soch/utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().themeMode,
      builder: (context, mode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Soch.',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const SplashScreen(), // Start with Splash
          routes: {
            '/login': (_) => const LoginScreen(),
            '/home': (_) => MainWrapper(),
            '/explore': (_) => const ExploreScreen(),
            '/createBlog': (_) => const CreateBlogScreen(),
            '/blogDetail': (context) {
              final blogId = ModalRoute.of(context)!.settings.arguments as String;
              return BlogDetailScreen(blogId: blogId);
            },
            '/profile': (_) => EditProfileScreen(),
            '/settings': (_) => const SettingsScreen(),
            '/about': (_) => const AboutScreen(),
          },
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    _controller.forward().then((_) {
      // Navigate after animation
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainWrapper()));
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Text(
            'SOCH.',
            style: GoogleFonts.bodoniModa(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: AppTheme.accent,
              letterSpacing: 4.0,
            ),
          ),
        ),
      ),
    );
  }
}
