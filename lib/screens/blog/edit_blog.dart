import 'package:flutter/material.dart';
import 'package:soch/models/blog_model.dart';
import 'package:soch/services/blog_services.dart';

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
      content: content,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: _textColor),
        title: const SizedBox.shrink(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _accentColor,
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text('Save', style: TextStyle(color: Colors.white)),
        onPressed: _saving ? null : _save,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: _textColor),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: _textColor),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _accentColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentCtrl,
                style: const TextStyle(color: _textColor),
                decoration: const InputDecoration(
                  labelText: 'Content',
                  alignLabelWithHint: true,
                  labelStyle: TextStyle(color: _textColor),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _accentColor),
                  ),
                ),
                minLines: 12,
                maxLines: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
