import 'package:flutter/material.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String profilepicurl;
  final List followers;
  final List following;

  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.profilepicurl,
    required this.followers,
    required this.following,
  });
}
