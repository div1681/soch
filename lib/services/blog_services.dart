import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soch/services/user_services.dart';
import '../models/blog_model.dart';

class BlogService {
  final _col = FirebaseFirestore.instance.collection('blogs');

  Future<String?> createBlog({
    required String title,
    required String content,
    String category = '',
  }) async {
    final user = await UserService().getCurrentUser();
    if (user == null) return null; // not signed in

    final now = DateTime.now();
    final ref = await _col.add({
      'authorId': user.uid,
      'authorName': user.username,
      'authorPicUrl': user.profilePicUrl,
      'title': title,
      'content': content,
      'category': category,
      'timestamp': Timestamp.fromDate(now),
      'likes': <String>[],
      'comments': <String>[],
    });

    await ref.update({'blogId': ref.id});
    return ref.id;
  }

  Future<List<BlogModel>> fetchAllBlogs() async {
    final snap = await _col.orderBy('timestamp', descending: true).get();
    return snap.docs.map(BlogModel.fromDoc).toList();
  }

  Stream<List<BlogModel>> streamAllBlogs() {
    return _col
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((q) => q.docs.map(BlogModel.fromDoc).toList());
  }

  Future<List<BlogModel>> fetchBlogsByAuthor(String uid) async {
    final snap = await _col
        .where('authorId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .get();
    return snap.docs.map(BlogModel.fromDoc).toList();
  }

  Future<void> updateBlog({
    required String blogId,
    String? title,
    String? content,
    String? category,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (content != null) data['content'] = content;
    if (category != null) data['category'] = category;
    if (data.isNotEmpty) {
      await _col.doc(blogId).update(data);
    }
  }

  Future<void> deleteBlog(String blogId) => _col.doc(blogId).delete();

  Future<void> toggleLike({
    required String blogId,
    required String uid,
    required bool alreadyLiked,
  }) {
    return _col.doc(blogId).update({
      'likes': alreadyLiked
          ? FieldValue.arrayRemove([uid])
          : FieldValue.arrayUnion([uid]),
    });
  }
}
