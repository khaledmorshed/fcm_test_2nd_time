
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
String channelName = "notification";

class LocalNotificationService {

  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
  //static final onNotificationStream = BehaviorSubject<dynamic>();

  Future<void> initNotification() async {
    //listenNotification();
    //android/app/src/main/res/mipmap-hdpi(mipmap/ic_launcher.png)
    AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('mipmap/ic_launcher');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (int id, String? title, String? body, dynamic payload) async {});

    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {

      },
    );
  }

  notificationDetails() {
    return  const NotificationDetails(
      android: AndroidNotificationDetails('channel id', 'channel name', importance: Importance.max),
      iOS: DarwinNotificationDetails(),
    );
  }

  //this function is called from push notification function
  Future showNotification(
      {int id = 0, String? title, required String? body, var payLoad}) async {
    return notificationsPlugin.show(
        id, title, body, await notificationDetails(), payload: payLoad);
  }

  void onClickedNotification(dynamic payload){
  }


}