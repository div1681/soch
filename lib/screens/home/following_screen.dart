import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soch/widgets/blog_tile.dart';
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

  static const _bgColor = Color(0xFFFDFDFD);
  static const _textColor = Color(0xFF202124);
  static const _accentColor = Color(0xFFB22222);

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
    return Scaffold(
      backgroundColor: _bgColor,
      body: StreamBuilder<List<BlogModel>>(
        stream: _combinedFollowingStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _accentColor),
            );
          }
          final blogs = snap.data ?? [];
          if (blogs.isEmpty) {
            return const Center(
              child: Text(
                'Follow someone to see their posts here.',
                style: TextStyle(color: _textColor),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemCount: blogs.length,
            itemBuilder: (context, i) {
              final blog = blogs[i];
              final currentUid = _uid!;
              final isLiked = blog.likes.contains(currentUid);

              return BlogTile(
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
              );
            },
          );
        },
      ),
    );
  }
}
