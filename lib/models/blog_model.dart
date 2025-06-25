import 'package:cloud_firestore/cloud_firestore.dart';

class BlogModel {
  final String blogid;
  final String authorid;
  final String authorname;
  final String title;
  final String content;
  final DateTime timestamp;
  final List<String> likes; // store user-uids
  final List<String> comments; // store comment-ids (optional)

  const BlogModel({
    required this.blogid,
    required this.authorid,
    required this.authorname,
    required this.title,
    required this.content,
    required this.timestamp,
    this.likes = const [],
    this.comments = const [],
  });

  /* ---------- Firestore helpers ---------- */

  /// create from an already-fetched document
  factory BlogModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return BlogModel(
      blogid: d['blogId'] ?? doc.id,
      authorid: d['authorId'] ?? '',
      authorname: d['authorName'] ?? '',
      title: d['title'] ?? '',
      content: d['content'] ?? '',
      timestamp: (d['timestamp'] as Timestamp).toDate(),
      likes: List<String>.from(d['likes'] ?? []),
      comments: List<String>.from(d['comments'] ?? []),
    );
  }

  /// for writing / updating
  Map<String, dynamic> toMap() => {
    'blogId': blogid,
    'authorId': authorid,
    'authorName': authorname,
    'title': title,
    'content': content,
    'timestamp': Timestamp.fromDate(timestamp),
    'likes': likes,
    'comments': comments,
  };

  /* ---------- convenience ---------- */

  BlogModel copyWith({
    String? blogid,
    String? authorid,
    String? authorname,
    String? title,
    String? content,
    DateTime? timestamp,
    List<String>? likes,
    List<String>? comments,
  }) {
    return BlogModel(
      blogid: blogid ?? this.blogid,
      authorid: authorid ?? this.authorid,
      authorname: authorname ?? this.authorname,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }

  int get likeCount => likes.length;
  int get commentCount => comments.length;
}
