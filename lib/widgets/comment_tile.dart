// lib/widgets/comment_tile.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/comment_model.dart';

class CommentTile extends StatelessWidget {
  final CommentModel comment;
  final bool canDelete;
  final VoidCallback? onDelete;

  const CommentTile({
    super.key,
    required this.comment,
    required this.canDelete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundImage: comment.authorPicUrl.isNotEmpty
            ? CachedNetworkImageProvider(comment.authorPicUrl)
            : null,
        child: comment.authorPicUrl.isEmpty ? const Icon(Icons.person) : null,
      ),
      title: Text(
        comment.authorName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment.content),
          Text(
            timeago.format((comment.timestamp as Timestamp).toDate()),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      trailing: canDelete
          ? IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
              onPressed: onDelete,
            )
          : null,
    );
  }
}
