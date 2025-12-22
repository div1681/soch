import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/services.dart'; // For SystemSound
import '../models/blog_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), 
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withOpacity(0.1), 
              width: 1
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: tiny author info
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: blog.authorpicurl.isNotEmpty
                      ? CachedNetworkImageProvider(blog.authorpicurl)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  blog.authorname.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 1.0,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 8),
                 Text(
                  "•",
                  style: TextStyle(color: theme.dividerColor, fontSize: 10),
                ),
                const SizedBox(width: 8),
                Text(
                  timeago.format(blog.timestamp),
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                 // Subtle Like action
                 GestureDetector(
                  onTap: () {
                     if (!isLiked) SystemSound.play(SystemSoundType.click);
                     onLike();
                  },
                  child: Row(
                    children: [
                       Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isLiked ? Colors.red : Colors.grey,
                        ),
                        if (blog.likes.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            '${blog.likes.length}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ]
                    ],
                  ),
                 ),

                 if (isMine) ...[
                    const SizedBox(width: 12),
                    GestureDetector( // Minimal edit button
                      onTap: onEdit,
                      child: Icon(Icons.more_horiz, size: 16, color: Colors.grey),
                    ),
                 ]
              ],
            ),
            
            const SizedBox(height: 12),

            // Title: Bold Serif
            Text(
              blog.title,
              style: GoogleFonts.merriweather( // or playfairDisplay
                fontSize: 22, 
                fontWeight: FontWeight.w900,
                height: 1.2,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),

            const SizedBox(height: 8),
            
            // Content Preview: Clean sans-serif
            Text(
              blog.content,
              maxLines: 3, 
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lora( // Use Lora for body text for high readability
                fontSize: 15, 
                height: 1.6,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),

            const SizedBox(height: 16),
            
            // Optional: Category pill if present, else read time estimate?
            if (blog.category.isNotEmpty) 
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(
                   color: theme.dividerColor.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(4),
                 ),
                 child: Text(
                   blog.category.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                 ),
              ),
              
          ],
        ),
      ),
    );
  }
}

