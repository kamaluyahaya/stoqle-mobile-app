// main.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stoqle/index/splash.dart';
import 'package:toast/toast.dart';
import 'config/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/provider/auth_provider.dart';
import 'firebase_options.dart';
import 'dart:io' show Platform;

/// ---------------------------------------------------------------------------
/// NOTE (Android):
/// Add this to android/app/src/main/AndroidManifest.xml:
/// <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
/// This is required for Android 13+; also request runtime permission.
/// ---------------------------------------------------------------------------

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background isolate: initialize Firebase & local-notification channel,
  // then show a local notification for data-only messages.
  await Firebase.initializeApp();
  await _initializeLocalNotifications(); // re-create channel in isolate
  await showLocalNotification(message);
  // debug log to verify background handler was invoked
  debugPrint(
    '📩 Background message handled: ${message.messageId}, data: ${message.data}',
  );
}

final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();

/// Local notifications plugin (global)
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const String highImportanceChannelId = 'high_importance_channel';
const String highImportanceChannelName = 'Important Notifications';
const String highImportanceChannelDescription =
    'Channel for important notifications (heads-up).';

final Dio _dio = Dio()
  ..options.connectTimeout = const Duration(seconds: 8)
  ..options.receiveTimeout = const Duration(seconds: 10);

/// Downloader using Dio (simple bytes) - good for small images
Future<String?> downloadAndSaveFileWithDio(String url, String fileName) async {
  try {
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/$fileName';

    final response = await _dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) return null;

    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return filePath;
  } catch (e) {
    debugPrint('Dio download error: $e');
    return null;
  }
}

/// Initialize local notifications and create Android channel with custom sound
Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings iosInit = DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  final InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint('local notification tapped: ${response.payload}');
      // Optionally handle navigation here using payload
    },
  );

  // Create Android channel with custom raw sound 'beep' (beep.mp3 in res/raw)
  final androidChannel = AndroidNotificationChannel(
    highImportanceChannelId,
    highImportanceChannelName,
    description: highImportanceChannelDescription,
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('beep'),
    enableVibration: true,
    showBadge: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(androidChannel);
}

/// Show a local notification — supports big picture when image exists
Future<void> showLocalNotification(RemoteMessage message) async {
  final notification = message.notification;
  final data = message.data;

  final title = notification?.title ?? data['title'] ?? '';
  final body = notification?.body ?? data['body'] ?? '';
  final imageUrl = (data['image'] ?? notification?.android?.imageUrl)
      ?.toString();

  AndroidNotificationDetails androidDetails;
  if (imageUrl != null && imageUrl.isNotEmpty) {
    final bigPicturePath = await downloadAndSaveFileWithDio(
      imageUrl,
      'notif_image_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    if (bigPicturePath != null) {
      final bigPictureStyle = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        largeIcon: FilePathAndroidBitmap(bigPicturePath),
        contentTitle: title,
        summaryText: body,
      );

      androidDetails = AndroidNotificationDetails(
        highImportanceChannelId,
        highImportanceChannelName,
        channelDescription: highImportanceChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('beep'),
        styleInformation: bigPictureStyle,
      );
    } else {
      androidDetails = AndroidNotificationDetails(
        highImportanceChannelId,
        highImportanceChannelName,
        channelDescription: highImportanceChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('beep'),
      );
    }
  } else {
    androidDetails = AndroidNotificationDetails(
      highImportanceChannelId,
      highImportanceChannelName,
      channelDescription: highImportanceChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('beep'),
    );
  }

  DarwinNotificationDetails iosDetails;
  if (imageUrl != null && imageUrl.isNotEmpty) {
    final attachmentPath = await downloadAndSaveFileWithDio(
      imageUrl,
      'notif_attachment_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    if (attachmentPath != null) {
      final attachment = DarwinNotificationAttachment(attachmentPath);
      iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'beep.aiff',
        attachments: [attachment],
      );
    } else {
      iosDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'beep.aiff',
      );
    }
  } else {
    iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'beep.aiff',
    );
  }

  final platformDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch.remainder(100000),
    title,
    body,
    platformDetails,
    payload: data.isNotEmpty ? data.toString() : null,
  );
}

Future<bool> requestNotificationPermissionWithDebug(BuildContext ctx) async {
  final ask = await showDialog<bool>(
    context: ctx,
    barrierDismissible: false,
    builder: (c) => AlertDialog(
      title: const Text('Enable notifications'),
      content: const Text(
        'Stoqle uses notifications to alert you about messages, comments and orders. Allow notifications?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: const Text('No'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(c, true),
          child: const Text('Allow'),
        ),
      ],
    ),
  );

  if (ask != true) return false;

  if (Platform.isAndroid) {
    final before = await Permission.notification.status;
    debugPrint('Permission.notification BEFORE request: $before');

    final result = await Permission.notification.request();
    debugPrint('Permission.notification RESULT: $result');

    if (result.isGranted) return true;

    if (result.isPermanentlyDenied) {
      debugPrint('Notifications permanently denied — opening settings.');
      final open = await showDialog<bool>(
        context: ctx,
        builder: (_) => AlertDialog(
          title: const Text('Notifications disabled'),
          content: const Text(
            'Please enable notifications in system settings. Open settings now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Open'),
            ),
          ],
        ),
      );
      if (open == true) openAppSettings();
      return false;
    }

    return false; // denied or restricted
  }

  if (Platform.isIOS) {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('iOS notification settings: $settings');
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  return true;
}

/// In-app explainer & runtime request for notification permission
Future<bool> requestNotificationPermission(BuildContext context) async {
  // Optional: show an in-app explainer dialog before the system dialog
  final ask = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Enable notifications'),
      content: const Text(
        'Stoqle uses notifications to alert you about messages, comments and orders. Allow notifications?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('No'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Allow'),
        ),
      ],
    ),
  );

  if (ask != true) return false;

  if (Platform.isAndroid) {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      return result.isGranted;
    }
    return true;
  } else if (Platform.isIOS) {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  } else {
    return true;
  }
}

/// Ask user to open system settings if they denied notification permission permanently
Future<void> openNotificationSettingsIfDenied(BuildContext ctx) async {
  final status = await Permission.notification.status;
  if (status.isDenied || status.isPermanentlyDenied) {
    final open = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Notifications disabled'),
        content: const Text(
          'You disabled notifications. Open settings to enable them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Open'),
          ),
        ],
      ),
    );
    if (open == true) {
      openAppSettings();
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize local notifications (creates channel) BEFORE runApp so background isolate
  // can reuse same channel and sound metadata.
  await _initializeLocalNotifications();

  // Register background handler ONCE (before runApp)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    // init FCM and permissions after widget binding so we have a BuildContext
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFCM());
    ToastContext().init(context);
  }

  Future<void> _initFCM() async {
    // Ask for permission with a friendly in-app explainer
    final granted = await requestNotificationPermission(context);
    debugPrint('Notification permission granted: $granted');

    // For iOS foreground presentation (also safe on Android)
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Get & print token
    _fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint("FCM Token: $_fcmToken");

    // Foreground messages - show local notification (so it pops up + plays custom sound)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        "Message received in foreground: ${message.notification?.title}",
      );
      showLocalNotification(message);
    });

    // When user taps on notification (background -> opened)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("User tapped on notification: ${message.notification?.title}");
      // optional: handle navigation using message.data
    });

    // If app was launched by a notification when terminated
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        "App opened from terminated state by a notification: ${initialMessage.data}",
      );
      // handle navigation if needed
    }

    // If permission was denied, optionally prompt to open settings
    if (!granted) {
      await openNotificationSettingsIfDenied(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return MaterialApp(
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      title: 'Stoqle',
      theme: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: const AuthGate(),
      routes: routes,
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);

    debugPrint(
      'AuthGate - isLoading: ${auth.isLoading}, isLoggedIn: ${auth.isLoggedIn}, token: ${auth.token}',
    );

    if (auth.isLoading) {
      return SplashScreen();
    }

    if (auth.isLoggedIn) {
      final dashboardBuilder = routes['/dashboard'];
      if (dashboardBuilder != null) {
        return dashboardBuilder(context);
      }
      return const Scaffold(body: Center(child: Text('Dashboard not found')));
    }

    final introBuilder = routes['/intro'];
    if (introBuilder != null) {
      return introBuilder(context);
    }

    return const Scaffold(
      body: Center(child: Text('App route configuration error')),
    );
  }
}
