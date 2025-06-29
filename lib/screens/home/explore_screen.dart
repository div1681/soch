import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soch/models/blog_model.dart';
import 'package:soch/services/blog_services.dart';
import 'package:soch/widgets/blog_tile.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _blogSvc = BlogService();
  late final String? _uid;

  static const Color _bgColor = Color(0xFFFDFDFD);
  static const Color _textColor = Color(0xFF202124);
  static const Color _accentColor = Color(0xFFB22222);

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _accentColor,
        onPressed: () => Navigator.pushNamed(context, '/createBlog'),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Post', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<List<BlogModel>>(
        stream: _blogSvc.streamAllBlogs(),
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
                'No blogs yet – be the first!',
                style: TextStyle(color: _textColor),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            separatorBuilder: (_, __) => const SizedBox(height: 4),
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
          );
        },
      ),
    );
  }
}
