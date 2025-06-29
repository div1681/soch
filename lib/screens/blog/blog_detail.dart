import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/blog_model.dart';
import '../../services/blog_services.dart';
import '../../services/user_services.dart';
import '../../services/comment_services.dart';
import '../home/profile_screen.dart';
import 'edit_blog.dart';

class BlogDetailScreen extends StatefulWidget {
  final String blogId;
  const BlogDetailScreen({super.key, required this.blogId});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final _blogSvc = BlogService();
  final _userSvc = UserService();
  final _cmtSvc = CommentService();

  late final Stream<BlogModel> _blog$;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _blog$ = FirebaseFirestore.instance
        .collection('blogs')
        .doc(widget.blogId)
        .snapshots()
        .map(BlogModel.fromDoc);
    _uid = FirebaseAuth.instance.currentUser?.uid;
  }

  Widget _followBtn(String authorId) {
    if (_uid == null || _uid == authorId) return const SizedBox.shrink();
    return FutureBuilder<bool>(
      future: _userSvc.isFollowing(authorId),
      builder: (c, s) {
        final followed = s.data ?? false;
        return TextButton(
          onPressed: () async {
            await _userSvc.toggleFollow(authorId);
            setState(() {});
          },
          child: Text(
            followed ? 'Unfollow' : 'Follow',
            style: TextStyle(color: followed ? Colors.grey : Colors.blue),
          ),
        );
      },
    );
  }

  void _showAddCommentDialog(String blogId) {
    final txt = TextEditingController();
    bool posting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add a comment'),
          content: TextField(
            controller: txt,
            autofocus: true,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Write something…',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          actions: [
            TextButton(
              onPressed: posting ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: posting || txt.text.trim().isEmpty
                  ? null
                  : () async {
                      setState(() => posting = true);
                      try {
                        await _cmtSvc.addComment(blogId, txt.text.trim());
                        if (mounted) Navigator.of(ctx).pop();
                      } catch (e) {
                        setState(() => posting = false);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: posting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(dynamic ts) =>
      ts is Timestamp ? DateFormat('dd MMM yyyy').format(ts.toDate()) : '';
  static const Color _bgColor = Color(0xFFFDFDFD);
  static const Color _textColor = Color(0xFF202124);
  static const Color _accentColor = Color(0xFFB22222);
  static const Color _dividerColor = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BlogModel>(
      stream: _blog$,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final blog = snap.data!;
        final liked = _uid != null && blog.likes.contains(_uid);

        return Scaffold(
          backgroundColor: _bgColor,

          // -------- AppBar ----------
          appBar: AppBar(
            backgroundColor: _bgColor,
            elevation: 0,
            iconTheme: const IconThemeData(color: _textColor),
            title: const SizedBox.shrink(), // no title
            actions: _uid == blog.authorid
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit, color: _textColor),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditBlogScreen(blog: blog),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: _accentColor),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete blog?'),
                            content: const Text('This action is irreversible.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: _accentColor),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await _blogSvc.deleteBlog(blog.blogid);
                          if (mounted) Navigator.pop(context);
                        }
                      },
                    ),
                  ]
                : null,
          ),

          floatingActionButton: _uid != null
              ? FloatingActionButton.extended(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_comment),
                  label: const Text('Comment'),
                  onPressed: () => _showAddCommentDialog(blog.blogid),
                )
              : null,

          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(uid: blog.authorid),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: blog.authorpicurl.isNotEmpty
                            ? CachedNetworkImageProvider(blog.authorpicurl)
                            : null,
                        child: blog.authorpicurl.isEmpty
                            ? const Icon(Icons.person, color: _textColor)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blog.authorname,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _textColor,
                            ),
                          ),
                          Text(
                            DateFormat('dd MMM yyyy').format(blog.timestamp),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _followBtn(blog.authorid),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  blog.title,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),

                const SizedBox(height: 16),
                Container(height: 1, color: _dividerColor),
                const SizedBox(height: 16),

                Text(
                  blog.content,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    height: 1.6,
                    color: _textColor,
                  ),
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    GestureDetector(
                      onTap: _uid != null
                          ? () => _blogSvc.toggleLike(
                              blogId: blog.blogid,
                              uid: _uid!,
                              alreadyLiked: liked,
                            )
                          : null,
                      child: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: _accentColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${blog.likeCount} likes'),
                  ],
                ),

                const SizedBox(height: 32),
                Container(height: 1, color: _dividerColor),

                const Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 16),
                  child: Text(
                    'COMMENTS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('blogs')
                      .doc(blog.blogid)
                      .collection('comments')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (_, cSnap) {
                    if (!cSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = cSnap.data!.docs;
                    if (docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No comments yet.'),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const Divider(height: 20),
                      itemBuilder: (_, i) {
                        final d = docs[i].data() as Map<String, dynamic>;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundImage:
                                (d['authorPicUrl'] ?? '').toString().isNotEmpty
                                ? NetworkImage(d['authorPicUrl'])
                                : null,
                            child: (d['authorPicUrl'] ?? '').toString().isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(
                            d['authorName'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            d['content'] ?? '',
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                          trailing: Text(
                            _fmt(d['timestamp']),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          onLongPress: () async {
                            final canDel =
                                _uid == d['authorId'] || _uid == blog.authorid;
                            if (!canDel) return;
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                content: const Text('Delete this comment?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) {
                              await _cmtSvc.deleteComment(
                                blog.blogid,
                                d['commentId'],
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
