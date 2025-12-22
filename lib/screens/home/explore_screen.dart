import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soch/models/blog_model.dart';
import 'package:soch/screens/home/search_screen.dart';
import 'package:soch/services/blog_services.dart';
import 'package:soch/utils/app_theme.dart';
import 'package:soch/widgets/blog_tile.dart';
import 'package:soch/widgets/skeleton_loader.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _blogSvc = BlogService();
  late final String? _uid;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Use CustomScrollView to allow the search bar to scroll away or stay pinned if we wanted.
      // For now, keeping it simple with a standard body structure but with a custom header area.
      appBar: AppBar(
        title: Text(
          'SOCH.',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: AppTheme.accent,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: theme.iconTheme.color),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          backgroundColor: AppTheme.accent,
          onPressed: () => Navigator.pushNamed(context, '/createBlog'),
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.edit, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // SEARCH INPUT ENTRY POINT
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (_, __, ___) => const SearchScreen(),
                    transitionsBuilder: (_, animation, __, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
              child: Hero(
                tag: 'search_bar',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.search, color: Colors.grey, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Search blogs, authors...',
                          style: GoogleFonts.outfit(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: StreamBuilder<List<BlogModel>>(
              stream: _blogSvc.streamAllBlogs(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return ListView.separated(
                    itemCount: 5,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, __) => _buildSkeletonItem(),
                  );
                }
                final blogs = snap.data ?? [];
                if (blogs.isEmpty) {
                  return const Center(child: Text('No blogs yet.'));
                }
                
                // Clean "Editorial" List with Fade Effect
                return ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.purple, Colors.transparent, Colors.transparent, Colors.purple],
                      stops: [0.0, 0.02, 0.95, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstOut,
                  child: CupertinoScrollbar(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
                      itemCount: blogs.length,
                      itemBuilder: (context, i) {
                        final blog = blogs[i];
                        final currentUid = _uid!;
                        final isLiked = blog.likes.contains(currentUid);
                        
                        return BlogTile(
                          blog: blog,
                          isLiked: isLiked,
                          onLike: () => BlogService().toggleLike(
                            blogId: blog.blogid,
                            uid: currentUid,
                            alreadyLiked: isLiked,
                          ),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/blogDetail',
                            arguments: blog.blogid,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Skeleton.circle(size: 20),
            SizedBox(width: 8),
            Skeleton(width: 80, height: 10),
          ]),
          SizedBox(height: 12),
          Skeleton(width: double.infinity, height: 20), // Title
          SizedBox(height: 8),
          Skeleton(width: double.infinity, height: 20), // Title line 2
          SizedBox(height: 12),
          Skeleton(width: 200, height: 14), // Body
          SizedBox(height: 8),
          Skeleton(width: 150, height: 14),
          SizedBox(height: 20),
          Divider(height: 1),
        ],
      ),
    );
  }
}
