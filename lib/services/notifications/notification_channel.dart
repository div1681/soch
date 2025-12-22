import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationChannelService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> setupHighImportanceChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // ID (IMPORTANT)
      'High Importance Notifications', // Name
      description: 'Used for important notifications',
      importance: Importance.high,
      playSound: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    print('🔔 High importance notification channel created');
  }
}
