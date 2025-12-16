import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soch/services/blog_services.dart';

class CreateBlogScreen extends StatefulWidget {
  const CreateBlogScreen({Key? key}) : super(key: key);

  @override
  State<CreateBlogScreen> createState() => _CreateBlogScreenState();
}

class _CreateBlogScreenState extends State<CreateBlogScreen> {
  final _titleCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController(); 
  final _contentCtrl = TextEditingController();
  final _blogSvc = BlogService();
  bool _saving = false;

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final title = _titleCtrl.text.trim();
    final category = _categoryCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content are required')),
      );
      return;
    }

    setState(() => _saving = true);
    await _blogSvc.createBlog(title: title, content: content, category: category);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _saving 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Publish', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              textInputAction: TextInputAction.next,
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color),
              decoration: InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: GoogleFonts.outfit(color: theme.hintColor, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _categoryCtrl,
                textInputAction: TextInputAction.next,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'Category (Optional)',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: theme.hintColor, fontSize: 14),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _contentCtrl,
              style: TextStyle(fontSize: 18, height: 1.6, color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: 'Tell your story...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: theme.hintColor, fontSize: 18),
              ),
              maxLines: null,
              minLines: 15,
            ),
             const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
