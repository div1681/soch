import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soch/screens/home/explore_screen.dart';
import 'package:soch/screens/home/following_screen.dart';
import 'package:soch/screens/home/profile_screen.dart';
import 'package:soch/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final String _uid;

  static const _bgColor = Color(0xFFFDFDFD);
  static const _textColor = Color(0xFF202124);
  static const _accentColor = Color(0xFFB22222);

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const ExploreScreen(),
      const FollowingScreen(),
      ProfileScreen(uid: _uid),
    ];

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        title: const Text(
          'SOCH.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: _accentColor,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: _textColor),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Color(0xFFE0E0E0), height: 1),
        ),
      ),
      drawer: const AppDrawer(),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: _bgColor,
        currentIndex: _selectedIndex,
        selectedItemColor: _accentColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Following'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
