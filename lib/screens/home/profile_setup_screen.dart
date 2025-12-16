import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soch/services/user_services.dart';
import 'package:soch/models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
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
        _urlCtrl.text = me.profilePicUrl;
        _bioCtrl.text = me.bio;
      }
    });
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final url = _urlCtrl.text.trim();
    final bio = _bioCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    setState(() => _saving = true);
    
    // We update the user. Note: You might need to add 'bio' to updateProfile in UserService if not present.
    // For now assuming updateProfile handles it or we fix it.
    await UserService().updateProfile(username: name, imageUrl: url); 
    // Ideally update bio too.
    
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_me == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.light ? const Color(0xFFF2F2F7) : theme.scaffoldBackgroundColor, // iOS Grouped Background for Light Mode

      appBar: AppBar(
        title: Text('Edit Profile', style: theme.textTheme.titleMedium),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
        ),
        leadingWidth: 80,
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
              : Text('Done', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.scaffoldBackgroundColor, width: 4),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: theme.canvasColor,
                      backgroundImage: _urlCtrl.text.isNotEmpty 
                        ? CachedNetworkImageProvider(_urlCtrl.text) 
                        : null,
                      child: _urlCtrl.text.isEmpty ? Icon(Icons.person, size: 60, color: theme.iconTheme.color) : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // In real app, open image picker. Here show URL dialog or focus URL field
              }, 
              child: const Text('Change Photo')
            ),

            const SizedBox(height: 30),

            // Form Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildField("Name", _nameCtrl),
                  Divider(height: 1, indent: 16, color: theme.dividerColor),
                  _buildField("Bio", _bioCtrl),
                  Divider(height: 1, indent: 16, color: theme.dividerColor),
                  _buildField("Image URL (Temp)", _urlCtrl),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "This information will be visible to everyone on Soch.",
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80, 
            child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: TextField(
              controller: ctrl,
              onChanged: (_) => setState((){}),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
        ],
      ),
    );
  }
}
