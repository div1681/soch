// import 'package:flutter/material.dart';
// import 'package:soch/models/user_model.dart';
// import 'package:soch/screens/home/profile_screen.dart';

// import 'package:soch/services/user_services.dart';

// class TestScreen extends StatelessWidget {
//   const TestScreen({super.key});

//   void _uploadAndGoToProfile(BuildContext context) async {
//     final dummyUser = UserModel(
//       uid: 'NE175sqBFHbFbqIYHRbraC0Cr0b2',
//       username: 'SANJAY',
//       email: 'sanjay@gmail.com',
//       profilepicurl: 'https://i.pravatar.cc/300',
//       followers: ['P', 'Q', 'R'],
//       following: ['L'],
//     );

//     try {
//       await UserService().createUser(dummyUser);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Dummy user uploaded successfully!')),
//       );

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) =>
//               const ProfileScreen(uid: 'NE175sqBFHbFbqIYHRbraC0Cr0b2'),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Test Upload User')),
//       body: Center(
//         child: ElevatedButton.icon(
//           onPressed: () => _uploadAndGoToProfile(context),
//           icon: const Icon(Icons.cloud_upload),
//           label: const Text("Upload Dummy User & View Profile"),
//         ),
//       ),
//     );
//   }
// }
