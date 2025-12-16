import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/services.dart'; // For SystemSound
import '../models/blog_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BlogTile extends StatelessWidget {
  final BlogModel blog;
  final bool isLiked;
  final bool isMine; 
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onComment;

  const BlogTile({
    super.key,
    required this.blog,
    required this.isLiked,
    this.isMine = false,
    required this.onTap,
    required this.onLike,
    this.onEdit,
    this.onDelete,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), 
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Author on Left, Likes on Right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.dividerColor, width: 1.5),
                      ),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey.shade50,
                        backgroundImage: blog.authorpicurl.isNotEmpty
                            ? CachedNetworkImageProvider(blog.authorpicurl)
                            : null,
                        child: blog.authorpicurl.isEmpty
                            ? Icon(Icons.person, color: theme.iconTheme.color?.withOpacity(0.4), size: 16)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blog.authorname,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          Text(
                            timeago.format(blog.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Like Button at the Top Right
                    InkWell(
                      onTap: () async {
                          if (!isLiked) {
                            SystemSound.play(SystemSoundType.click);
                          }
                         onLike();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLiked ? Colors.red.withOpacity(0.1) : theme.cardColor,
                          border: Border.all(color: isLiked ? Colors.transparent : theme.dividerColor.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 300),
                                tween: Tween(begin: 1.0, end: isLiked ? 1.2 : 1.0),
                                curve: Curves.elasticOut,
                                builder: (context, scale, child) {
                                  return Transform.scale(
                                    scale: isLiked ? scale : 1.0, 
                                    child: Icon(
                                      isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: isLiked ? const Color(0xFFE02020) : theme.iconTheme.color?.withOpacity(0.6),
                                      size: 16, 
                                    ),
                                  );
                                },
                              ),
                            if (blog.likes.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                '${blog.likes.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isLiked ? const Color(0xFFE02020) : theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),

                    if (isMine) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.more_horiz, color: theme.iconTheme.color?.withOpacity(0.5), size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                           showModalBottomSheet(
                            context: context,
                            backgroundColor: theme.bottomSheetTheme.backgroundColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (ctx) => SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 40, height: 4,
                                      margin: const EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2)),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.edit_outlined, color: theme.iconTheme.color),
                                      title: Text('Edit Blog', style: TextStyle(fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        onEdit?.call();
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.delete_outline, color: Colors.red),
                                      title: const Text('Delete Blog', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        onDelete?.call();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ]
                  ],
                ),
                
                const SizedBox(height: 12),

                // Title
                Text(
                  blog.title,
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: theme.textTheme.titleLarge?.color,
                    letterSpacing: -0.4,
                  ),
                ),

                const SizedBox(height: 6),
                
                // Content Preview
                Text(
                  blog.content,
                  maxLines: 2, // Fewer lines for compactness
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14, 
                    height: 1.5,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

