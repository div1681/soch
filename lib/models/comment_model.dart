import 'package:flutter/material.dart';
import 'package:soch/models/blog_model.dart';

class CommentModel {
  final String commentid;
  final String commenterid;
  final String content;
  final DateTime timestamp;

  const CommentModel({
    required this.commentid,
    required this.commenterid,
    required this.content,
    required this.timestamp,
  });
}
