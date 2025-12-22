import 'package:firebase_messaging/firebase_messaging.dart';


Future<void> requestPermission() async {
    final FirebaseMessaging message_service = FirebaseMessaging.instance;
    NotificationSettings settings = await message_service.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        print ("permission not granted");
        return;
      
    }
    print("NOTIFICATION PERSMISSION GRANTED, LETS MOVE TO NEXT STAGE.");
}

