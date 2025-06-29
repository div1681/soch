import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String authorId;
  final String authorName;
  final String authorPicUrl;
  final String content;
  final DateTime timestamp;

  CommentModel({
    required this.commentId,
    required this.authorId,
    required this.authorName,
    required this.authorPicUrl,
    required this.content,
    required this.timestamp,
  });

  factory CommentModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return CommentModel(
      commentId: d['commentId'] ?? doc.id,
      authorId: d['authorId'],
      authorName: d['authorName'],
      authorPicUrl: d['authorPicUrl'] ?? '',
      content: d['content'],
      timestamp: (d['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'commentId': commentId,
    'authorId': authorId,
    'authorName': authorName,
    'authorPicUrl': authorPicUrl,
    'content': content,
    'timestamp': Timestamp.fromDate(timestamp),
  };
}
