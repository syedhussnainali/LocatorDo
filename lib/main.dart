// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_locator/auth/authentication_wrapper.dart';
import 'package:flutter_locator/provider/app_locale.dart';


import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'google_maps_page.dart';
import 'package:intl/intl_standalone.dart';




AndroidNotificationChannel channel = AndroidNotificationChannel(
    "High importance", "High important notifications ",
    //"This channel is used for important notifications",
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _firebaseNotificationHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log(message.messageId.toString());

  // Display notification when app is killed
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;



  if (notification != null && android != null) {
    String notificationbody = notification.body!;
    if(notification.body!.contains(HydratedBloc.storage.read("firstname") ?? "notApplicable")){
      notificationbody = "You are out of the location radius set";
    }
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notificationbody,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          color: Colors.blue,
          icon: "logo",
        ),
      ),
    );
  }
}

void main() async{

   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
//initialize hydrated bloc
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseNotificationHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
  // String? token = await FirebaseMessaging.instance.getToken();

  if(HydratedBloc.storage.read("id") !=null){
    FirebaseMessaging.instance.subscribeToTopic(HydratedBloc.storage.read("id"));
  }

  // log( "token is     ${token!}");
  
  runApp(MyApp() );
}

class MyApp extends StatefulWidget {
   MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {

    super.initState();
    HydratedBloc.storage.write("notificationsent", false);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log(" A new message on message");
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        String notificationbody = notification.body!;
        if(notification.body!.contains(HydratedBloc.storage.read("firstname") ?? "notApplicable")){
          notificationbody = "You are out of the location radius set";
        }
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notificationbody,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              color: Colors.blue,
              icon: "logo",
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log(" A new message onmessageopennedapp");
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        String notificationbody = notification.body!;
        if(notification.body!.contains(HydratedBloc.storage.read("firstname") ?? "notApplicable")){
          notificationbody = "You are out of the location radius set";
        }
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(notification.title.toString()),
                content: Text(notificationbody),
              );
            });
      }
    });
  }



  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (context) => AppLocale(),
      child: Consumer<AppLocale>(builder: (context, locale, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter translation',
          localizationsDelegates:  AppLocalizations.localizationsDelegates, // important
          supportedLocales: AppLocalizations.supportedLocales, //
          locale: locale.locale,
          theme: ThemeData(
            primarySwatch: Colors.red,
          ),
       
          home:  AuthenticationWrapper()
          //LanguageBasedOnUserSelection(),
        );
      }),
    );



  }
}
