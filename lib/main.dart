import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';

import 'firebase_options.dart';
import 'home_page.dart';
import 'utils/NotificationManager.dart';
import 'utils/global_context.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupFlutterNotifications();
}

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (!kIsWeb) {
    await setupFlutterNotifications();
  }
  runApp(const MyApp());
}

late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  print("setup....");
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  //this default_channel_id is equivalent to AndroidManifest.xml's default_channel_id
  /*
    android:name="com.google.firebase.messaging.default_notification_channel_id"
     android:value="default_channel_id"/>
  */
  String channelId = "default_channel_id";
  channel = AndroidNotificationChannel(
    channelId, // id
    'High Importance Notifications', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  String? initialMessage;
  bool _resolved = false;

  @override
  void initState() {
    final firebaseMessaging = FCM();
      firebaseMessaging.setNotifications();

    FirebaseMessaging.instance.getInitialMessage().then(
          (value) => setState(
            () {
          _resolved = true;
          initialMessage = value?.data.toString();
          if (initialMessage != null) {
            // var route = NavigationHistoryObserver().top;
            // if(route!=null && route.settings.name!=NotificationScreen.routeName){
            //   NavigationService.navigatorKey.currentState?.pushNamed(NotificationScreen.routeName);
            // }
          }
        },
      ),
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("list.....${message}");
      showFlutterNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // var route = NavigationHistoryObserver().top;
      // if(route!=null && route.settings.name!=NotificationScreen.routeName){
      //   NavigationService.navigatorKey.currentState?.pushNamed(NotificationScreen.routeName);
      // }
    });
    initLocalNotification();
    super.initState();
  }

  void showFlutterNotification(RemoteMessage message) {
    print("RemoteMessage...${message.notification!.body}");
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
           // icon: 'ic_launcher',
            icon: 'mipmap/ic_launcher',
            importance: Importance.high
          ),
        ),
      );
    }
  }

  void initLocalNotification() async{
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) {
          if (payload != null) {
            debugPrint('notification payload: $payload');
          }
        });
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    //when user click on notification this method call
   /* var route = NavigationHistoryObserver().top;
    if(route!=null && route.settings.name!=NotificationScreen.routeName){
      NavigationService.navigatorKey.currentState?.pushNamed(NotificationScreen.routeName).then((value) {
        FBroadcast.instance().broadcast(
          "update_count",
          value: 0,
        );
      });
    }
    else{
      NavigationService.navigatorKey.currentState?.pushReplacementNamed(NotificationScreen.routeName).then((value) {
        FBroadcast.instance().broadcast(
          "update_count",
          value: 0,
        );
      });
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey:  NavigationService.navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorObservers: [NavigationHistoryObserver()],
      home: const HomePage(),
    );
  }
}

