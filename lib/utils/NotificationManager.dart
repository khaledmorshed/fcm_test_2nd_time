import 'dart:async';

import 'package:fcm_second/utils/local_notification_service.dart';
import 'package:fcm_second/utils/sharepreferences_class.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.data.containsKey('data')) {
    // Handle data message
    final data = message.data['data'];
  }

  if (message.data.containsKey('notification')) {
    // Handle notification message
    final notification = message.data['notification'];
  }
  // Or do other work.
}

class FCM {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final streamCtlr = StreamController<String>.broadcast();
  final titleCtlr = StreamController<String>.broadcast();
  final bodyCtlr = StreamController<String>.broadcast();

  setNotifications() async{
    print("set...1");
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    // handle when app in active state
    forgroundNotification();

    // handle when app running in background state
    backgroundNotification();

    // handle when app completely closed by the user
    terminateNotification();
   // print("fcmValue....fcmValue");

    String? fcmValue = await SharedPreferencesClass.getValue(SharedPreferencesClass.fcmToken);
   print("fcmValue = $fcmValue...+${fcmValue == null}");
    if(fcmValue == null){
      // With this token you can test it easily on your phone
      _firebaseMessaging.getToken().then((token) async{
        print("token - ${token!}");
        await SharedPreferencesClass.setValue(SharedPreferencesClass.fcmToken, token);
        //print("t--${await SharedPreferencesClass.getValue(SharedPreferencesClass.fcmToken)}");
      });

    }

  }

  forgroundNotification() {
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        //print("message...forgr..11..${message.data['notification']}");
        print("message...forgr....${message.data}");
        if (message.data.containsKey('data')) {
          // Handle data message
          print("message...forgr....1");
          print("message...forgr....${message.data['data']}");
          streamCtlr.sink.add(message.data['data']);
        }
        if (message.data.containsKey('notification')) {
          // Handle notification message
          print("message...forgr....2");
          print("message...forgr....${message.data['notification']}");
          streamCtlr.sink.add(message.data['notification']);
        }
        // Or do other work.
        titleCtlr.sink.add(message.notification!.title!);
        bodyCtlr.sink.add(message.notification!.body!);
      },
    );
  }

  backgroundNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) async {
        print("message...baack....${message.data}");
        if (message.data.containsKey('data')) {
          // Handle data message
          streamCtlr.sink.add(message.data['data']);
        }
        if (message.data.containsKey('notification')) {
          // Handle notification message
          streamCtlr.sink.add(message.data['notification']);
        }
        // Or do other work.
        titleCtlr.sink.add(message.notification!.title!);
        bodyCtlr.sink.add(message.notification!.body!);
      },
    );
  }

  terminateNotification() async {
  //  LocalNotificationService().showNotification(body: "body", payLoad: "pa");
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    //print("initialMessage...termi....");

    if (initialMessage != null) {
      if (initialMessage.data.containsKey('data')) {
        // Handle data message
        streamCtlr.sink.add(initialMessage.data['data']);
      }
      if (initialMessage.data.containsKey('notification')) {
        // Handle notification message
        streamCtlr.sink.add(initialMessage.data['notification']);
      }
      // Or do other work.
      titleCtlr.sink.add(initialMessage.notification!.title!);
      bodyCtlr.sink.add(initialMessage.notification!.body!);
    }
  }

  dispose() {
    streamCtlr.close();
    bodyCtlr.close();
    titleCtlr.close();
  }
}