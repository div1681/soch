import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:soch/utils/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;
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

class _BlogDetailScreenState extends State<BlogDetailScreen> with SingleTickerProviderStateMixin {
  final _blogSvc = BlogService();
  final _userSvc = UserService();
  final _cmtSvc = CommentService();

  late final Stream<BlogModel> _blog$;
  String? _uid;
  bool? _isFollowing;
  AnimationController? _followAnimCtrl;
  Animation<double>? _followScale;

  @override
  void initState() {
    super.initState();
    _blog$ = FirebaseFirestore.instance
        .collection('blogs')
        .doc(widget.blogId)
        .snapshots()
        .map(BlogModel.fromDoc);
    _uid = FirebaseAuth.instance.currentUser?.uid;
    _checkFollowStatus(); 
    
    _followAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150), lowerBound: 0.8, upperBound: 1.0);
    _followScale = CurvedAnimation(parent: _followAnimCtrl!, curve: Curves.easeOut);
    _followAnimCtrl!.value = 1.0;
  }

  @override
  void dispose() {
    _followAnimCtrl?.dispose();
    super.dispose();
  }

  void _checkFollowStatus() async {
    // Only fetch if we have an authorId, which we get from the stream later.
    // The stream builder handles the initial set.
  }
  
  void _onFollowTap(String authorId) async {
    // 1. Optimistic Update (Immediate)
    final newVal = !(_isFollowing ?? false);
    setState(() => _isFollowing = newVal);
    
    _followAnimCtrl!.reverse().then((_) => _followAnimCtrl!.forward()); 

    // 2. Haptics (Safeguarded)
    // 2. Haptics (Safeguarded)
    if (await Vibration.hasVibrator() ?? false) {
       Vibration.vibrate(duration: 50); // Short, sharp click
    }

    // 3. API Sync
    await _userSvc.toggleFollow(authorId);
  }


  void _showAddCommentSheet(String blogId) {
     final txt = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, 
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(ctx).bottomSheetTheme.backgroundColor ?? Theme.of(ctx).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black12)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Share your thoughts', style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  )
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: txt,
                autofocus: true,
                maxLines: 4,
                minLines: 2,
                style: GoogleFonts.plusJakartaSans(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'What are you thinking?',
                  hintStyle: GoogleFonts.plusJakartaSans(color: Theme.of(ctx).hintColor),
                  filled: true,
                  fillColor: Theme.of(ctx).inputDecorationTheme.fillColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: StatefulBuilder(
                  builder: (context, setStateBtn) {
                    bool posting = false;
                    return ElevatedButton(
                      onPressed: posting ? null : () async {
                        if (txt.text.trim().isEmpty) return;
                        setStateBtn(() => posting = true);
                        try {
                          await _cmtSvc.addComment(blogId, txt.text.trim());
                         
                          if (mounted && Navigator.canPop(ctx)) {
                            Navigator.pop(ctx); 
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Comment added successfully!'), behavior: SnackBarBehavior.floating),
                            );
                          }
                        } catch (e) {
                          setStateBtn(() => posting = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: posting 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Post Comment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    );
                  }
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BlogModel>(
      stream: _blog$,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final blog = snap.data!;
        final liked = _uid != null && blog.likes.contains(_uid);

         if (_isFollowing == null && _uid != blog.authorid) {
            _userSvc.isFollowing(blog.authorid).then((val) {
                if (mounted && _isFollowing == null) setState(() => _isFollowing = val);
            });
        }

        final theme = Theme.of(context);
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddCommentSheet(blog.blogid),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text("Discuss"),
          ),
          body: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutQuart,
            builder: (context, opacity, child) => Opacity(opacity: opacity, child: child),
            child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced margin to 16
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80), // Space for Back Button
                    
                    if (blog.category.isNotEmpty) 
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          blog.category.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
              
                    Text(
                      blog.title,
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: theme.textTheme.displayLarge?.color,
                        letterSpacing: -0.5,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
              
                    // Author Row
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(uid: blog.authorid))),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: blog.authorpicurl.isNotEmpty ? CachedNetworkImageProvider(blog.authorpicurl) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(blog.authorname, 
                                    style: Theme.of(context).textTheme.labelLarge,
                                    overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  timeago.format(blog.timestamp), // Time ago
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          
                           if (_uid != blog.authorid) ...[
                              const SizedBox(width: 8),
                              ScaleTransition(
                                scale: _followScale!,
                                child: InkWell(
                                  onTap: () => _onFollowTap(blog.authorid),
                                  borderRadius: BorderRadius.circular(20),
                                  child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                          color: (_isFollowing ?? false) ? theme.scaffoldBackgroundColor : theme.colorScheme.primary,
                                          border: Border.all(color: theme.colorScheme.primary),
                                          borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                          (_isFollowing ?? false) ? "Following" : "Follow",
                                          style: TextStyle(
                                              color: (_isFollowing ?? false) ? theme.colorScheme.primary : Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12
                                          ),
                                      ),
                                  ),
                                ),
                              ),
                          ],
              
                          const SizedBox(width: 12),
                          _buildLikeButton(blog, liked),
                        ],
                      ),
                    ),
              
                    const SizedBox(height: 32),
              
                    SelectableText(
                      blog.content,
                      style: GoogleFonts.literata( 
                        fontSize: 18,
                        height: 1.5, 
                        color: theme.textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
              
                    const SizedBox(height: 48),
                    const Divider(),
                    const SizedBox(height: 24),
                    
                    Text("Comments", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 24),
                    _buildCommentsList(blog.blogid),
                    const SizedBox(height: 80), 
                  ],
                ),
              ),
              
              // Content Fade Gradient (Top)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 120,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.scaffoldBackgroundColor.withOpacity(1.0),
                          theme.scaffoldBackgroundColor.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Custom Floating Back Button
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                       onPressed: () => Navigator.pop(context),
                         icon: Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: Theme.of(context).cardColor.withOpacity(0.8),
                             shape: BoxShape.circle,
                             boxShadow: [
                               BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                             ]
                           ),
                           child: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                         ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }

  Widget _buildLikeButton(BlogModel blog, bool liked) {
    return InkWell(
      onTap: () async {
        if (!liked) {
          SystemSound.play(SystemSoundType.click); 
        }
        _blogSvc.toggleLike(blogId: blog.blogid, uid: _uid!, alreadyLiked: liked);
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: liked ? Colors.red.withOpacity(0.1) : Theme.of(context).dividerColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
             TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 1.0, end: liked ? 1.2 : 1.0),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: liked ? scale : 1.0,
                    child: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.red : Theme.of(context).iconTheme.color, size: 20),
                  );
                },
             ),
            const SizedBox(width: 6),
            Text('${blog.likeCount}', style: TextStyle(fontWeight: FontWeight.bold, color: liked ? Colors.red : Theme.of(context).textTheme.bodyMedium?.color)),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList(String blogId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('blogs').doc(blogId).collection('comments').orderBy('timestamp', descending: true).snapshots(),
      builder: (ctx, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        if (docs.isEmpty) return const Text("No comments yet. Start the conversation!", style: TextStyle(color: Colors.grey));
        
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 24),
          itemBuilder: (context, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: d['authorPicUrl'] != null ? NetworkImage(d['authorPicUrl']) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(d['authorName'] ?? 'Anon', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(width: 8),
                          Text(
                            d['timestamp'] != null ? DateFormat('MMM dd').format((d['timestamp'] as Timestamp).toDate()) : '',
                            style: const TextStyle(color: Colors.grey, fontSize: 12)
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(d['content'] ?? '', style: const TextStyle(fontSize: 15, height: 1.4)),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
