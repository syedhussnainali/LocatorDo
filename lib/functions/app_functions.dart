import 'dart:developer' as developer;
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translator/translator.dart';

import '../main.dart';

class AppFunctions{

  double calculateDistance( double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    developer.log("Successfully calculated distance");
    return 12742 * asin(sqrt(a));
  }

  void snackbar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      elevation: 1000,
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: '',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }




  void showNotification(String notificationName, String notificationDescription) async {
    developer.log(" A new message on local notification");
    // String? token = await FirebaseMessaging.instance.getToken();
    // developer.log(token!);
    flutterLocalNotificationsPlugin.show(
      1,
      notificationName,
      notificationDescription,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          color: Colors.blue,
          playSound: true,
          icon: "logo",
        ),
      ),
    );
    developer.log(" message sent on local notification");
  }


}