import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';
import 'user_services.dart';

class CommentService {
  Stream<List<CommentModel>> streamComments(String blogId) {
    return FirebaseFirestore.instance
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((q) => q.docs.map(CommentModel.fromDoc).toList());
  }

  Future<void> addComment(String blogId, String text) async {
    final user = await UserService().getCurrentUser();
    if (user == null) return;

    final ref = await FirebaseFirestore.instance
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .add({
          'authorId': user.uid,
          'authorName': user.username,
          'authorPicUrl': user.profilepicurl,
          'content': text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });

    await ref.update({'commentId': ref.id});

    await FirebaseFirestore.instance.collection('blogs').doc(blogId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  Future<void> deleteComment(String blogId, String commentId) async {
    await FirebaseFirestore.instance
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .doc(commentId)
        .delete();

    await FirebaseFirestore.instance.collection('blogs').doc(blogId).update({
      'commentCount': FieldValue.increment(-1),
    });
  }
}
