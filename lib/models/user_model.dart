import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String profilePicUrl;
  final String bio;
  final List<String> followers;
  final List<String> following;

  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.profilePicUrl,
    this.bio = '',
    required this.followers,
    required this.following,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'profilePicUrl': profilePicUrl,
      'bio': bio,
      'followers': followers,
      'following': following,
    };
  }

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      profilePicUrl: (data['profilePicUrl'] != null && data['profilePicUrl'].toString().isNotEmpty)
          ? data['profilePicUrl']
          : 'https://ui-avatars.com/api/?name=${(data['username'] ?? 'User').toString().replaceAll(' ', '+')}&background=random&size=200',
      bio: data['bio'] ?? '',
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
    );
  }
}
