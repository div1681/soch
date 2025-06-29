import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final _col = FirebaseFirestore.instance.collection('users');

  Future<void> ensureUserDoc() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = _col.doc(user.uid);
    if (!(await ref.get()).exists) {
      await ref.set({
        'uid': user.uid,
        'username': '',
        'email': user.email ?? '',
        'profilepicurl': '',
        'followers': [],
        'following': [],
      });
    }
  }

  Future<UserModel?> getCurrentUser() async {
    await ensureUserDoc();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return getUserById(uid);
  }

  Future<UserModel?> getUserById(String uid) async {
    final snap = await _col.doc(uid).get();
    if (!snap.exists) return null;

    final data = snap.data()!;
    return UserModel(
      uid: data['uid'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      profilepicurl: data['profilepicurl'] ?? '',
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
    );
  }

  Future<void> updateProfile({
    required String username,
    required String imageUrl,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _col.doc(uid).update({
      'username': username,
      'profilepicurl': imageUrl,
    });
  }

  Future<bool> isFollowing(String otherUid) async {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null) return false;
    final snap = await _col.doc(me.uid).get();
    final following = List<String>.from(snap.get('following') ?? []);
    return following.contains(otherUid);
  }

  Future<void> toggleFollow(String otherUid) async {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null || me.uid == otherUid) return;

    final myRef = _col.doc(me.uid);
    final otherRef = _col.doc(otherUid);

    final mySnap = await myRef.get();
    final following = List<String>.from(mySnap.get('following') ?? []);

    final alreadyFollowing = following.contains(otherUid);

    final batch = FirebaseFirestore.instance.batch();

    batch.update(myRef, {
      'following': alreadyFollowing
          ? FieldValue.arrayRemove([otherUid])
          : FieldValue.arrayUnion([otherUid]),
    });

    batch.update(otherRef, {
      'followers': alreadyFollowing
          ? FieldValue.arrayRemove([me.uid])
          : FieldValue.arrayUnion([me.uid]),
    });

    await batch.commit();
  }
}
