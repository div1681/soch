import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soch/widgets/blog_tile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soch/widgets/skeleton_loader.dart';
import 'package:soch/screens/blog/edit_blog.dart';
import '../../models/user_model.dart';
import '../../models/blog_model.dart';
import '../../services/user_services.dart';
import '../../services/blog_services.dart';
import '../../services/auth_services.dart';
import '../../services/data_seeder.dart';
import '../../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.uid});
  final String uid;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final bool _isMe = widget.uid == FirebaseAuth.instance.currentUser?.uid;

  final _usernameCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  bool _saving = false;

  static const Color _accentColor = Color(0xFFB22222);

  // Remove static _textColor to use theme instead

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: UserService().getUserById(widget.uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: Text('Failed to load profile')),
          );
        }

        final user = snap.data!;
        final needsSetup = _isMe && user.username.isEmpty;
        return needsSetup ? _buildSetupView(user) : _buildProfileView(user);
      },
    );
  }

  Scaffold _buildSetupView(UserModel user) {
    _usernameCtrl.text = user.username;
    _imageUrlCtrl.text = user.profilePicUrl;

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: _imageUrlCtrl.text,
              width: 100,
              height: 100,
              imageBuilder: (_, p) =>
                  CircleAvatar(radius: 50, backgroundImage: p),
              placeholder: (_, __) => const CircleAvatar(
                radius: 50,
                child: CircularProgressIndicator(),
              ),
              errorWidget: (_, __, ___) => const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, color: _accentColor),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _imageUrlCtrl,
              decoration: const InputDecoration(labelText: 'Profile-pic URL'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : () => _saveProfile(user),
                style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile(UserModel user) async {
    final name = _usernameCtrl.text.trim();
    final img = _imageUrlCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Username is required')));
      return;
    }
    setState(() => _saving = true);

    await UserService().updateProfile(username: name, imageUrl: img);
    if (mounted) setState(() => _saving = false);
  }

  Scaffold _buildProfileView(UserModel user) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: theme.iconTheme.color),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [
          if (_isMe && false) // Hidden as per request
            TextButton(
               onPressed: () => Navigator.pushNamed(context, '/profile'),
               child: Text("Edit Profile", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary))
            ),
          const SizedBox(width: 24),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _profileImage(user.profilePicUrl),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.username,
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                 _stat('Followers', user.followers.length),
                                 _stat('Following', user.following.length),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  if (user.bio.isNotEmpty) ...[
                     const SizedBox(height: 12),
                     Text(
                      user.bio,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],

                  const SizedBox(height: 20),
                  
                  // Edit Profile Button
                  if (_isMe) 
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pushNamed(context, '/profile'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: BorderSide(color: theme.dividerColor),
                        ),
                        child: Text("Edit Profile", style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w600)),
                      ),
                    ),

                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 16),
                  if (_isMe) ...[
                    Text(
                      'Your Blogs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),

            FutureBuilder<List<BlogModel>>(
              future: BlogService().fetchBlogsByAuthor(user.uid),
              builder: (context, blogSnap) {
                if (blogSnap.connectionState == ConnectionState.waiting) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24), // Added padding for skeleton to match
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (_, __) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Skeleton(height: 200, width: double.infinity, cornerRadius: 12),
                        SizedBox(height: 12),
                        Skeleton(height: 20, width: 200),
                        SizedBox(height: 8),
                        Skeleton(height: 14, width: 150),
                      ],
                    ),
                  );
                }
                final blogs = blogSnap.data ?? [];
                if (blogs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      height: 120,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'You haven’t posted anything yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: blogs.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero, // Important: No padding here
                  itemBuilder: (_, i) {
                    final blog = blogs[i];
                    final currentUid = FirebaseAuth.instance.currentUser!.uid;
                    final alreadyLike = blog.likes.contains(currentUid);
                    final isMyBlog = currentUid == blog.authorid; 

                    return BlogTile(
                      blog: blog,
                      isLiked: alreadyLike,
                      isMine: isMyBlog,
                      onEdit: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => EditBlogScreen(blog: blog)));
                          setState(() {}); 
                      },
                      onDelete: () {
                         showDialog(
                           context: context, 
                           builder: (ctx) => Dialog(
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                             child: Padding(
                               padding: const EdgeInsets.all(24),
                               child: Column(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 48),
                                   const SizedBox(height: 16),
                                   const Text('Delete Blog?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                   const SizedBox(height: 8),
                                   const Text('This action cannot be undone.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                                   const SizedBox(height: 24),
                                   Row(
                                     children: [
                                       Expanded(
                                         child: TextButton(
                                           onPressed: () => Navigator.pop(ctx),
                                           style: TextButton.styleFrom(
                                             padding: const EdgeInsets.symmetric(vertical: 12),
                                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                           ), 
                                           child: Text('Cancel', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
                                         ),
                                       ),
                                       const SizedBox(width: 12),
                                       Expanded(
                                         child: ElevatedButton(
                                           onPressed: () async {
                                             Navigator.pop(ctx);
                                             await BlogService().deleteBlog(blog.blogid);
                                             setState(() {}); 
                                           },
                                           style: ElevatedButton.styleFrom(
                                             backgroundColor: Colors.red,
                                             padding: const EdgeInsets.symmetric(vertical: 12),
                                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                             elevation: 0,
                                           ),
                                           child: Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                         ),
                                       ),
                                     ],
                                   )
                                 ],
                               ),
                             ),
                           ),
                         );
                      },
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/blogDetail',
                        arguments: blog.blogid,
                      ),
                      onLike: () => BlogService().toggleLike(
                        blogId: blog.blogid,
                        uid: currentUid,
                        alreadyLiked: alreadyLike,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileImage(String url) {
    if (url.isEmpty) {
      return const CircleAvatar(
        radius: 50,
        child: Icon(Icons.person, size: 50, color: _accentColor),
      );
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        placeholder: (_, __) => const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(),
        ),
        errorWidget: (_, __, ___) => const CircleAvatar(
          radius: 50,
          child: Icon(Icons.person, color: _accentColor),
        ),
      ),
    );
  }

  Widget _stat(String label, int count) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$count',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
      Text(label, style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color)),
    ],
  );
}
