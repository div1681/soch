import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soch/models/blog_model.dart';
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

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.dividerColor.withOpacity(0.1), height: 1.0),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          backgroundColor: theme.colorScheme.primary,
          onPressed: () => Navigator.pushNamed(context, '/createBlog'),
          elevation: 4,
          shape: const CircleBorder(), 
          child: const Icon(Icons.edit, color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<BlogModel>>(
        stream: _blogSvc.streamAllBlogs(),
        builder: (context, snap) {
           if (snap.connectionState == ConnectionState.waiting) {
            return ListView.separated(
              itemCount: 5,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) => _buildSkeletonItem(),
            );
          }
          final blogs = snap.data ?? [];
          if (blogs.isEmpty) {
             return const Center(child: Text('No blogs yet.'));
          }
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
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 100), 
                itemCount: blogs.length,
                itemBuilder: (context, i) {
                  final blog = blogs[i];
                  final currentUid = _uid!;
                  final isLiked = blog.likes.contains(currentUid);
                  
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 500 + (i * 100).clamp(0, 500)),
                    curve: Curves.easeOut,
                    builder: (context, opacity, child) => Opacity(opacity: opacity, child: child),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BlogTile(
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
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonItem() {
     final theme = Theme.of(context);
     return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        ),
        child: const Column(
          children: [
             Row(children: [Skeleton.circle(size: 40), SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Skeleton(width: 100, height: 14), SizedBox(height: 4), Skeleton(width: 60, height: 10)])]),
            SizedBox(height: 16),
            Skeleton(width: double.infinity, height: 16),
            SizedBox(height: 8),
            Skeleton(width: 200, height: 16),
          ],
        ),
     );
  }
}
