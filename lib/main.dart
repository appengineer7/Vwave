import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart' as fb;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:vwave/presentation/club/models/club.dart';
import 'package:vwave/presentation/events/models/club_event.dart';
import 'package:vwave/presentation/livestream/models/livestream.dart';
import 'package:vwave/presentation/messaging/models/conversation.dart';
import 'package:vwave/presentation/splash/pages/splash_page.dart';
import 'package:vwave/router.dart';
import 'package:vwave/size_config.dart';
import 'package:vwave/utils/general.dart';
import 'package:vwave/utils/storage.dart';
import 'constants.dart';
import 'firebase_options.dart';
import 'package:vwave/widgets/styles/app_colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

int id = 0;

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

// NotificationAppLaunchDetails notificationAppLaunchDetails; @dart=2.9

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse == null) {
    return;
  }
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input!.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  try {
    await Firebase.initializeApp();
    print('Handling a background message ${message.messageId}');
    print("RemoteMessage received");
    if (message.data.isNotEmpty) {
      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
        categoryIdentifier: darwinNotificationCategoryPlain,
      );
      flutterLocalNotificationsPlugin.show(
          message.data.hashCode,
          message.data["title"],
          message.data["body"],
          NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: "app_icon",
                //      one that already exists in example app.
                // icon: message.notification.android?.smallIcon,
              ),
              iOS: iosNotificationDetails),
          payload: jsonEncode(message.data));
      if (message.data["title"] == "New Livestream Alert") {
        GeneralUtils().saveNotification(message.data["title"], message.data);
      }
    }
  } catch (e) {}
}

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'vwave_fcm_notification_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.high,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // await Hive.initFlutter();
    // await Hive.openBox<List<Map<dynamic, dynamic>>>(HIVE_BOX_NAME);
     await Firebase.initializeApp(); // ✅ Initialize Firebase


    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
    );

    await dotenv.load(fileName: ".env");

    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        !kIsWeb && Platform.isLinux
            ? null
            : (await flutterLocalNotificationsPlugin
                .getNotificationAppLaunchDetails())!;
    // String initialRoute = HomePage.routeName;
    if (notificationAppLaunchDetails!.didNotificationLaunchApp ?? false) {
      selectedNotificationPayload = (notificationAppLaunchDetails == null)
          ? ""
          : notificationAppLaunchDetails.notificationResponse!.payload;
      // initialRoute = SecondPage.routeName;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final List<DarwinNotificationCategory> darwinNotificationCategories =
        <DarwinNotificationCategory>[
      const DarwinNotificationCategory(
        darwinNotificationCategoryText,
      ),
      const DarwinNotificationCategory(
        darwinNotificationCategoryPlain,
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      )
    ];

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification:
      //     (int id, String? title, String? body, String? payload) async {
      //   // didReceiveLocalNotificationStream.add(
      //   //   ReceivedNotification(
      //   //     id: id,
      //   //     title: title,
      //   //     body: body,
      //   //     payload: payload,
      //   //   ),
      //   // );
    //   },
    //   notificationCategories: darwinNotificationCategories,
     );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationStream.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == navigationActionId) {
              selectNotificationStream.add(notificationResponse.payload);
            }
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final GoogleMapsFlutterPlatform mapsImplementation =
        GoogleMapsFlutterPlatform.instance;
    // AndroidMapRenderer mapRenderer = AndroidMapRenderer.platformDefault;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      // WidgetsFlutterBinding.ensureInitialized();
      mapsImplementation.useAndroidViewSurface = false;
      try {
        // Related issue: https://github.com/flutter/flutter/issues/105965
        await mapsImplementation.initializeWithRenderer(
          AndroidMapRenderer.latest,
        );
      } on PlatformException catch (exception) {
        if (exception.code == 'Renderer already initialized') {
          // Happens during hot reload
          return;
        }
        rethrow;
      } catch (e, s) {}
    }
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    runApp(const ProviderScope(child: MyApp()));
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  StorageSystem ss = StorageSystem();
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  final appCheck = FirebaseAppCheck.instance;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> getToken() async {
    try {
      if (GeneralUtils().userUid == null || GeneralUtils().userUid == "") {
        return;
      }
      String? token = await FirebaseMessaging.instance.getToken();
      if (token == "" || token == null) return;
      String? getUser = await ss.getItem("user");
      if (getUser == null) return;
      dynamic user = jsonDecode(getUser);
      List<dynamic> msgIds = user["msgId"] ?? [];
      String? currentToken = await ss.getItem("userNotificationToken");
      if (currentToken == token) return;
      if (currentToken == null) {
        await ss.setPrefItem("userNotificationToken", token);
        await fb.FirebaseFirestore.instance
            .collection("users")
            .doc(GeneralUtils().userUid)
            .update({
          "msgId": (msgIds.length >= 3)
              ? [token]
              : fb.FieldValue.arrayUnion([token]),
        });
        msgIds.add(token);
        msgIds = (msgIds.length >= 3) ? [token] : msgIds;
        user["msgId"] = msgIds;
        await ss.setPrefItem("user", jsonEncode(user));
      }
    } catch (e, s) {}
  }

  Future<void> initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      if (GeneralUtils().userUid == null) {
        return;
      }
      // print(dynamicLinkData.asMap());
      String? linkType = dynamicLinkData.link.queryParameters["type"];
      String? linkID = dynamicLinkData.link.queryParameters["id"];
      String? linkData = dynamicLinkData.link.queryParameters["data"];
      if (linkType == "club" && linkID != null && linkData != null) {
        String data = GeneralUtils().decodeValue(linkData);
        Map<String, dynamic> getData = jsonDecode(data);
        final Club club = Club.fromJson(getData);
        Future.delayed(const Duration(milliseconds: 200), () {
          navigatorKey.currentState
              ?.pushNamed("/club_details", arguments: club);
        });
      }
      if (linkType == "livestream" && linkID != null && linkData != null) {
        String data = GeneralUtils().decodeValue(linkData);
        Map<String, dynamic> getData = jsonDecode(data);
        final Livestream livestream = Livestream.fromJson(getData);
        Future.delayed(const Duration(milliseconds: 200), () {
          navigatorKey.currentState
              ?.pushNamed("/livestream_view", arguments: livestream);
        });
      }
      // if (linkType == "product" && linkID != null && linkData != null) {
      //   String data = GeneralUtils().decodeValue(linkData);
      //   Map<String, dynamic> getData = jsonDecode(data);
      //   final Product product = Product.fromJson(getData);
      //   if (product.sold) {
      //     return;
      //   }
      //   Future.delayed(const Duration(milliseconds: 200), () {
      //     navigatorKey.currentState?.pushNamed("/product_details", arguments: product);
      //   });
      // }
      if (linkType == "user" && linkID != null && linkData != null) {
        String data = GeneralUtils().decodeValue(linkData);
        Map<String, dynamic> user = jsonDecode(data);
        // final User user = User.fromJson(getData);
        Future.delayed(const Duration(milliseconds: 200), () {
          navigatorKey.currentState
              ?.pushNamed("/user_profile", arguments: user);
        });
      }
      if (linkType == "event" && linkID != null && linkData != null) {
        String data = GeneralUtils().decodeValue(linkData);
        Map<String, dynamic> getData = jsonDecode(data);
        final ClubEvent clubEvent = ClubEvent.fromJson(getData);
        Future.delayed(const Duration(milliseconds: 200), () {
          navigatorKey.currentState
              ?.pushNamed("/event_details", arguments: clubEvent);
        });
      }
      // if (linkType == "community_post" && linkID != null && linkData != null) {
      //   String data = GeneralUtils().decodeValue(linkData);
      //   Map<String, dynamic> getData = jsonDecode(data);
      //   final CommunityPost communityPost = CommunityPost.fromSnapshot(getData);
      //   Future.delayed(const Duration(milliseconds: 200), ()
      //   {
      //     navigatorKey.currentState?.push(
      //       MaterialPageRoute(
      //           builder: (context) => CommunitySinglePostView(
      //               communityPost, communityPost.id, false, "")),
      //     );
      //   });
      // }
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }

  Future<void> initLocalNotification() async {
    try {
      _isAndroidPermissionGranted();
      _requestPermissions();
      _configureDidReceiveLocalNotificationSubject();
      _configureSelectNotificationSubject();

      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null) {
          onSelectNotificationEvent(message.data);
          // Navigator.pushNamed(context, '/message',
          //     arguments: MessageArguments(message, true));
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print("RemoteMessage received = message");
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && Platform.isIOS) {
          const DarwinNotificationDetails iosNotificationDetails =
              DarwinNotificationDetails(
            categoryIdentifier: "plainCategory",
          );
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              const NotificationDetails(
                iOS: iosNotificationDetails,
              ),
              payload: jsonEncode(message.data));
        }
        if (notification != null && android != null) {
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
                  icon: message.notification!.android?.smallIcon,
                ),
              ),
              payload: jsonEncode(message.data));
        }
        if (message.data["title"] == "New Livestream Alert") {
          GeneralUtils().saveNotification(message.data["title"], message.data);
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        onSelectNotificationEvent(message.data);
        print('A new onMessageOpenedApp event was published!');
        // Navigator.pushNamed(context, '/message',
        //     arguments: MessageArguments(message, true));
      });
    } catch (e, s) {
      // Sentry.captureException(e, stackTrace: s);
    }
  }

  Future<void> initAppCheck() async {
    await appCheck.setTokenAutoRefreshEnabled(true);
    appCheck.onTokenChange.listen(setEventToken);
  }

  @override
  void initState() {
    super.initState();
    ss.deletePref("clubProfileSettingsData");
    ss.deletePref("userProfileSettingsData");
    initAppCheck();
    initLocalNotification();
    initDynamicLinks();
    getToken();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    return MaterialApp(
      // useInheritedMediaQuery: true,
      // locale: DevicePreview.locale(context),
      // builder: DevicePreview.appBuilder,
      title: 'VWave App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBase,
          background: Colors.white,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.dmSansTextTheme(Theme.of(context).textTheme),
        tabBarTheme: const TabBarTheme(
          labelColor: Colors.black,
          labelStyle: TextStyle(color: Colors.red), // color for text
          indicator: UnderlineTabIndicator(
              // color for indicator (underline)

              ),
        ),
        appBarTheme: const AppBarTheme(color: Colors.white),
        primaryColor: Colors.red, // outdated and has no effect to Tabbar
      ),

      // home: const AuthIntroPage(),
      home: const SplashPage(),
      onGenerateRoute: Routes.generateRoutes,
      navigatorKey: navigatorKey,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }

  void setEventToken(String? token) {
    if (token == null) return;
    ss.setPrefItem("app_token", token);
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted =
          await androidImplementation?.requestNotificationsPermission();
    }
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
        ),
      );
      if (receivedNotification.title == null ||
          receivedNotification.body == null) {
        return;
      }
      // await GeneralUtils().saveNotification(receivedNotification.title, receivedNotification.body);
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      print("onselected notification is payload");
      if (payload == null) {
        return;
      }
      onSelectNotificationEvent(jsonDecode(payload));
      // await Navigator.of(context).push(MaterialPageRoute<void>(
      //   builder: (BuildContext context) => SecondPage(payload),
      // ));
    });
  }

  Future<void> onSelectNotificationEvent(Map<String, dynamic> data) async {
    if (GeneralUtils().userUid == null) {
      return;
    }

    if (data["notification_type"] == null) {
      return;
    }

    if (data["document"] == null) {
      return;
    }

    String notificationType = data["notification_type"];
    Map<String, dynamic> getData = jsonDecode(data["document"]);

    // if(notificationType == "product") {
    //   final Product product = Product.fromJson(getData);
    //   if(product.sold) {
    //     return;
    //   }
    //   Future.delayed(const Duration(milliseconds: 200), () {
    //     navigatorKey.currentState?.pushNamed("/product_details", arguments: product);
    //   });
    //   return;
    // }
    //
    // if(notificationType == "community") {
    //   final CommunityPost communityPost = CommunityPost.fromSnapshot(getData);
    //   Future.delayed(const Duration(milliseconds: 200), ()
    //   {
    //     navigatorKey.currentState?.push(
    //       MaterialPageRoute(
    //           builder: (context) =>
    //               CommunitySinglePostView(
    //                   communityPost, communityPost.id, false, "")),
    //     );
    //   });
    //   return;
    // }
    //
    // if(notificationType == "offers") {
    //   final NotificationModel notificationModel = NotificationModel.fromSnapshot(getData);
    //   Future.delayed(const Duration(milliseconds: 200), () {
    //     navigatorKey.currentState?.pushNamed("/offer_details", arguments: notificationModel);
    //   });
    //   return;
    // }
    //
    // if(notificationType == "activity") {
    //   if(data["payload_type"] == "item_sold" || data["payload_type"] == "item_purchased") {
    //     final NotificationModel notificationModel = NotificationModel.fromSnapshot(getData);
    //     Future.delayed(const Duration(milliseconds: 200), () {
    //       navigatorKey.currentState?.pushNamed("/items_activity", arguments: notificationModel);
    //     });
    //   }
    //   return;
    // }
    //
    // if(notificationType == "orders") {
    //   final Order order = Order.fromJson(getData);
    //   Future.delayed(const Duration(milliseconds: 200), () {
    //     navigatorKey.currentState?.pushNamed("/order_details", arguments: order);
    //   });
    //   return;
    // }
    //
    if (notificationType == "chat") {
      final Conversation conversation = Conversation.fromJson(getData);
      Future.delayed(const Duration(milliseconds: 200), () {
        navigatorKey.currentState?.pushNamed("/chat", arguments: conversation);
      });
      return;
    }
    if (notificationType == "livestream") {
      final Livestream livestream = Livestream.fromJson(getData);
      Future.delayed(const Duration(milliseconds: 200), () {
        navigatorKey.currentState
            ?.pushNamed("/livestream_view", arguments: livestream);
      });
      return;
    }
    if (notificationType == "follow") {
      Future.delayed(const Duration(milliseconds: 200), () {
        navigatorKey.currentState
            ?.pushNamed("/user_profile", arguments: getData);
      });
      return;
    }
    if (notificationType == "event") {
      final ClubEvent clubEvent = ClubEvent.fromJson(getData);
      Future.delayed(const Duration(milliseconds: 200), () {
        navigatorKey.currentState
            ?.pushNamed("/event_details", arguments: clubEvent);
      });
      return;
    }
  }
}
