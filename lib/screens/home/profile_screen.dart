import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soch/widgets/blog_tile.dart';
import '../../models/user_model.dart';
import '../../models/blog_model.dart';
import '../../services/user_services.dart';
import '../../services/blog_services.dart';

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
  static const Color _textColor = Color(0xFF202124);

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
    _imageUrlCtrl.text = user.profilepicurl;

    return Scaffold(
      backgroundColor: Colors.white,
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _profileImage(user.profilepicurl),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _stat('Followers', user.followers.length),
                          const SizedBox(width: 16),
                          _stat('Following', user.following.length),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Your Blogs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 12),

            FutureBuilder<List<BlogModel>>(
              future: BlogService().fetchBlogsByAuthor(user.uid),
              builder: (context, blogSnap) {
                if (blogSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final blogs = blogSnap.data ?? [];
                if (blogs.isEmpty) {
                  return Container(
                    height: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'You haven’t posted anything yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: blogs.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, i) {
                    final blog = blogs[i];
                    final currentUid = FirebaseAuth.instance.currentUser!.uid;
                    final alreadyLike = blog.likes.contains(currentUid);

                    return BlogTile(
                      blog: blog,
                      isLiked: alreadyLike,
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
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _textColor,
        ),
      ),
      Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
    ],
  );
}
