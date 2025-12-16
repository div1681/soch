import 'package:cloud_firestore/cloud_firestore.dart';

class BlogModel {
  final String blogid;
  final String authorid;
  final String authorname;
  final String authorpicurl;
  final String title;
  final String content;
  final DateTime timestamp;
  final List<String> likes;
  final int commentCount;
  final String category;

  const BlogModel({
    required this.blogid,
    required this.authorid,
    required this.authorname,
    required this.authorpicurl,
    required this.title,
    required this.content,
    required this.timestamp,
    this.likes = const [],
    this.commentCount = 0,
    this.category = '',
  });

  factory BlogModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;

    int countFromLegacy = (d['comments'] is List)
        ? (d['comments'] as List).length
        : 0;

    return BlogModel(
      blogid: d['blogId'] ?? doc.id,
      authorid: d['authorId'] ?? '',
      authorname: d['authorName'] ?? '',
      authorpicurl: d['authorPicUrl'] ?? '',
      title: d['title'] ?? '',
      content: d['content'] ?? '',
      timestamp: (d['timestamp'] as Timestamp).toDate(),
      likes: List<String>.from(d['likes'] ?? []),
      commentCount: (d['commentCount'] is int)
          ? d['commentCount']
          : countFromLegacy,
      category: d['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'blogId': blogid,
    'authorId': authorid,
    'authorName': authorname,
    'authorPicUrl': authorpicurl,
    'title': title,
    'content': content,
    'timestamp': Timestamp.fromDate(timestamp),
    'likes': likes,
    'commentCount': commentCount,
    'category': category,
  };

  BlogModel copyWith({
    String? blogid,
    String? authorid,
    String? authorname,
    String? authorpicurl,
    String? title,
    String? content,
    DateTime? timestamp,
    List<String>? likes,
    int? commentCount,
  }) {
    return BlogModel(
      blogid: blogid ?? this.blogid,
      authorid: authorid ?? this.authorid,
      authorname: authorname ?? this.authorname,
      authorpicurl: authorpicurl ?? this.authorpicurl,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  int get likeCount => likes.length;
}
