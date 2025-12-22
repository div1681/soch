import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soch/services/notifications/generate_fcm.dart';
import 'package:soch/services/notifications/save_fcm.dart';

Future<void> uploadFcmToken() async {
  final  user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('❌ No logged-in user, skipping FCM upload');
    return;
  }
  final String? token = await generate_FcmToken();
  if (token == null) {
    print('❌ FCM token generation failed');
    return;
  }
  await savefcm(user_id: user.uid, fcm_token: token);
  print("✅ FCM token uploaded for user:    ${user.email}");
}