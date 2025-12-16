import 'package:flutter/material.dart';
import 'package:soch/models/blog_model.dart';
import 'package:soch/services/blog_services.dart';
import 'package:google_fonts/google_fonts.dart';

class EditBlogScreen extends StatefulWidget {
  final BlogModel blog;
  const EditBlogScreen({super.key, required this.blog});

  @override
  State<EditBlogScreen> createState() => _EditBlogScreenState();
}

class _EditBlogScreenState extends State<EditBlogScreen> {
  late final TextEditingController _titleCtrl = TextEditingController(
    text: widget.blog.title,
  );
  late final TextEditingController _categoryCtrl = TextEditingController(
    text: widget.blog.category,
  );
  late final TextEditingController _contentCtrl = TextEditingController(
    text: widget.blog.content,
  );

  final _blogSvc = BlogService();
  bool _saving = false;

  static const Color _bgColor = Color(0xFFFDFDFD);
  static const Color _accentColor = Color(0xFFB22222);
  static const Color _textColor = Color(0xFF202124);

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final category = _categoryCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title & content are required')),
      );
      return;
    }
    setState(() => _saving = true);
    await _blogSvc.updateBlog(
      blogId: widget.blog.blogid,
      title: title,
      category: category,
      content: content,
    );
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
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _saving 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Update', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
        ),
      ),
      floatingActionButton: null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'Category (e.g. Technology)',
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
              minLines: 10,
            ),
             const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
