import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';



class noti_listener{
  

static void init (BuildContext context){
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final title = message.notification?.title ?? 'No Title';
    final body = message.notification?.body ?? 'No Body';

   
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:  Text('$title\n$body'),duration: Duration(seconds: 3),));

      print('Foreground Notification Received: $title - $body');
    });
}}