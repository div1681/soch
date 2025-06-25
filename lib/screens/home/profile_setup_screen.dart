import 'package:flutter/material.dart';
import 'package:soch/services/user_services.dart';
import 'package:soch/utils/validators.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final _name = TextEditingController();
  final _image = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final user = await UserService().getCurrentUser();
    if (user != null) {
      _name.text = user.username;
      _image.text = user.profilepicurl;
      print('🟢 Loaded user data: ${user.username}, ${user.profilepicurl}');
    }
  }

  Future<void> _save() async {
    if (_saving) return;

    setState(() => _saving = true);

    final username = _name.text.trim();
    final imageUrl = _image.text.trim();

    print('💾 Saving → name="$username", image="$imageUrl"');

    await UserService().updateProfile(username: username, imageUrl: imageUrl);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MainWrapper()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Up Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _image,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: _saving
                  ? const CircularProgressIndicator()
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
