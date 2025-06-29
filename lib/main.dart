import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:soch/firebase_options.dart';
import 'package:soch/screens/auth/login_screen.dart';
import 'package:soch/screens/blog/blog_detail.dart';
import 'package:soch/screens/blog/create_blog.dart';
import 'package:soch/screens/home/explore_screen.dart';
import 'package:soch/screens/home/profile_setup_screen.dart';
import 'package:soch/utils/validators.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Soch.',
      theme: ThemeData(useMaterial3: true),

      home: MainWrapper(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/explore': (_) => const ExploreScreen(),
        '/createBlog': (_) => const CreateBlogScreen(),
        '/blogDetail': (context) {
          final blogId = ModalRoute.of(context)!.settings.arguments as String;
          return BlogDetailScreen(blogId: blogId);
        },
        '/profile': (_) => EditProfileScreen(),
      },
    );
  }
}
