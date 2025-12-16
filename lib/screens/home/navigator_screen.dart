import 'package:firebase_auth/firebase_auth.dart';
import 'package:soch/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Haptics
import 'package:soch/screens/home/explore_screen.dart';
import 'package:soch/screens/home/following_screen.dart';
import 'package:soch/screens/home/profile_screen.dart';
import 'package:soch/utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final String _uid;

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
      backgroundColor: Colors.black, 
      drawer: const AppDrawer(),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor, 
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (child, animation) {
             return FadeTransition(opacity: animation, child: child);
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_selectedIndex),
            child: pages[_selectedIndex],
          ),
        ),
      ),
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 52, // Sleek height
          margin: const EdgeInsets.fromLTRB(72, 0, 72, 16), // Thinner width, closer to bottom
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.grid_view_rounded, Icons.grid_view_outlined),
              _buildNavItem(1, Icons.people_rounded, Icons.people_outline_rounded),
              _buildNavItem(2, Icons.person_rounded, Icons.person_outline_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (_selectedIndex != index) {
          setState(() => _selectedIndex = index);
          HapticFeedback.lightImpact(); 
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        curve: Curves.easeOutBack,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent : Colors.transparent, 
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          isSelected ? activeIcon : inactiveIcon,
          color: isSelected ? Colors.white : Colors.grey.shade600,
          size: 24,
        ),
      ),
    );
  }
}
