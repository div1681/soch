import 'package:firebase_messaging/firebase_messaging.dart';

Future<String?> generate_FcmToken() async {
  final FirebaseMessaging message_service = FirebaseMessaging.instance;
  final fcmToken = await message_service.getToken();
  if(fcmToken == null){
    print("FCM TOKEN IS NULL");
    return null;
  }
  print("👌👌👌👌👌FCM TOKEN: $fcmToken");
  return fcmToken;
} 