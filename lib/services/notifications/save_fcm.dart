import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> savefcm ({required String user_id , required String fcm_token}) async {
await FirebaseFirestore.instance.collection('users').doc(user_id).update({'fcm_token':fcm_token});

print("FCM TOKEN SAVED FOR ${user_id}");
}