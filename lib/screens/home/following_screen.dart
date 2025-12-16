import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soch/widgets/blog_tile.dart';
import 'package:soch/widgets/skeleton_loader.dart';
import '../../models/blog_model.dart';
import '../../services/user_services.dart';
import '../../services/blog_services.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({Key? key}) : super(key: key);

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  final _userSvc = UserService();
  final _blogSvc = BlogService();
  String? _uid;
  List<String> _following = [];

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    _loadFollowing();
  }

  Future<void> _loadFollowing() async {
    final me = await _userSvc.getCurrentUser();
    if (me == null) return;
    setState(() => _following = List<String>.from(me.following));
  }

  Stream<List<BlogModel>> _combinedFollowingStream() {
    if (_following.isEmpty) return Stream.value([]);

    final chunks = <List<String>>[];
    for (var i = 0; i < _following.length; i += 10) {
      chunks.add(
        _following.sublist(
          i,
          i + 10 > _following.length ? _following.length : i + 10,
        ),
      );
    }

    final streams = chunks.map((ids) {
      return FirebaseFirestore.instance
          .collection('blogs')
          .where('authorId', whereIn: ids)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((q) => q.docs.map(BlogModel.fromDoc).toList());
    }).toList();

    return Stream<List<BlogModel>>.multi((controller) {
      final combined = <BlogModel>[];
      for (final s in streams) {
        s.listen((data) {
          combined.removeWhere((b) => data.any((d) => d.blogid == b.blogid));
          combined.addAll(data);
          combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          controller.add(List<BlogModel>.from(combined));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Following',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: theme.textTheme.titleLarge?.color, 
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
      body: StreamBuilder<List<BlogModel>>(
        stream: _combinedFollowingStream(),
        builder: (context, snap) {
           if (snap.connectionState == ConnectionState.waiting || !snap.hasData) {
            return ListView.separated(
              itemCount: 5,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) => _buildSkeletonItem(),
            );
          }
          final blogs = snap.data!;
          if (blogs.isEmpty) {
             return const Center(child: Text('Follow someone to see their posts here.', style: TextStyle(color: Colors.grey)));
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
                        onLike: () => _blogSvc.toggleLike(
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
