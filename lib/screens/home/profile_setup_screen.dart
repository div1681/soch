import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:soch/services/user_services.dart';
import 'package:soch/models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _bgColor = Color(0xFFFDFDFD);
  static const _textColor = Color(0xFF202124);
  static const _accentColor = Color(0xFFB22222);

  final _nameCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  bool _saving = false;
  UserModel? _me;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
    final me = await UserService().getCurrentUser();
    if (!mounted) return;
    setState(() {
      _me = me;
      if (me != null) {
        _nameCtrl.text = me.username;
        _urlCtrl.text = me.profilepicurl;
      }
    });
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final url = _urlCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Username is required')));
      return;
    }

    setState(() => _saving = true);
    await UserService().updateProfile(username: name, imageUrl: url);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _bgColor,

        appBar: AppBar(
          backgroundColor: _bgColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: _textColor),
          title: const Text(
            'Edit Profile',
            style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold),
          ),
        ),

        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.save),
          label: const Text('Save'),
        ),

        body: _me == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _urlCtrl.text.isNotEmpty
                          ? CachedNetworkImageProvider(_urlCtrl.text)
                          : null,
                      child: _urlCtrl.text.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: _accentColor,
                            )
                          : null,
                    ),
                    const SizedBox(height: 24),

                    TextField(
                      controller: _nameCtrl,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: _textColor),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: const TextStyle(color: _textColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: _accentColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _urlCtrl,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: _textColor),
                      decoration: InputDecoration(
                        labelText: 'Profile Picture URL',
                        labelStyle: const TextStyle(color: _textColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: _accentColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
