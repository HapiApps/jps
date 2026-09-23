import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:camera/camera.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:master_code/screens/common/camera.dart';
import 'package:master_code/screens/common/dashboard.dart';
import 'package:master_code/screens/common/detail_work_plan.dart';
import 'package:master_code/screens/common/home_page.dart';
import 'package:master_code/screens/customer/visit_report/visits_report.dart';
import 'package:master_code/screens/expense/view_expense.dart';
import 'package:master_code/screens/leave_management/leave_dashboard.dart';
import 'package:master_code/screens/leave_management/leave_report.dart';
import 'package:master_code/screens/log_in.dart';
import 'package:master_code/screens/task/task_chat.dart';
import 'package:master_code/screens/task/view_task.dart';
import 'package:master_code/screens/track/background_task.dart';
import 'package:master_code/source/constant/assets_constant.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/constant/default_constant.dart';
import 'package:master_code/source/constant/local_data.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:master_code/view_model/attendance_provider.dart';
import 'package:master_code/view_model/customer_provider.dart';
import 'package:master_code/view_model/employee_provider.dart';
import 'package:master_code/view_model/expasy_provider.dart';
import 'package:master_code/view_model/expense_provider.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:master_code/view_model/leave_provider.dart';
import 'package:master_code/view_model/location_provider.dart';
import 'package:master_code/view_model/payroll_provider.dart';
import 'package:master_code/view_model/project_provider.dart';
import 'package:master_code/view_model/report_provider.dart';
import 'package:master_code/view_model/setting_provider.dart';
import 'package:master_code/view_model/task_provider.dart';
import 'package:master_code/view_model/track_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'component/custom_text.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

const AndroidInitializationSettings initializationSettingsAndroid =
AndroidInitializationSettings('@mipmap/ic_launcher');

const DarwinInitializationSettings initializationSettingsIOS =
DarwinInitializationSettings(
  requestAlertPermission: false,
  requestBadgePermission: false,
  requestSoundPermission: false,
);

const InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
  iOS: initializationSettingsIOS,
);

Future<T?> safeCall<T>(
    String tag,
    Future<T> Function() action, {
      Duration timeout = const Duration(seconds: 8),
    }) async {
  try {
    return await action().timeout(timeout);
  } on TimeoutException {
    log("⏱️ [$tag] TIMED OUT");
    return null;
  } catch (e, st) {
    log("⚠️ [$tag] FAILED: $e");
    log("⚠️ [$tag] STACK: $st");
    return null;
  }
}

/// ==========================================================
/// GUARANTEED ATTENDANCE LOAD
/// ==========================================================
Future<void> ensureAttendanceLoaded(
    AttendanceProvider attendanceProvider, {
      int maxRetries = 3,
    }) async {
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    bool succeeded = false;

    await safeCall<void>(
      'attendanceProvider.getMainAttendance (attempt $attempt)',
          () async {
        await attendanceProvider.getMainAttendance();
        succeeded = true;
      },
      timeout: const Duration(seconds: 10),
    );

    if (succeeded) {
      log("✅ [Attendance] Loaded successfully on attempt $attempt");
      return;
    }

    log("⚠️ [Attendance] Attempt $attempt/$maxRetries failed, retrying...");

    if (attempt < maxRetries) {
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  log("❌ [Attendance] Failed to load after $maxRetries attempts");
}

/// ==========================================================
/// LOCAL NOTIFICATION SETUP
/// ==========================================================

Future<void> setupLocalNotifications() async {
  await safeCall(
    'setupLocalNotifications',
        () async {
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final payload = response.payload;

          if (payload == null || payload.isEmpty) {
            return;
          }

          try {
            final decoded = jsonDecode(payload);

            if (decoded is Map) {
              final data = Map<String, dynamic>.from(decoded);
              handleNotificationNavigation(data);
            }
          } catch (e) {
            log("⚠️ Notification payload decode failed: $e");
          }
        },
      );

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'JPS',
        'JPS',
        description: 'JPS application notifications',
        importance: Importance.max,
      );

      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(channel);



      log("🔔 Local notifications initialized");
    },
  );
}

Future<String?> setupFirebaseMessaging() async {
  try {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    await safeCall(
      'FCM.setAutoInitEnabled',
          () => messaging.setAutoInitEnabled(true),
      timeout: const Duration(seconds: 10),
    );

    final NotificationSettings? settings =
    await safeCall<NotificationSettings>(
      'FCM.requestPermission',
          () => messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      ),
      timeout: const Duration(seconds: 20),
    );

    if (settings == null) {
      log("❌ Notification permission request failed");
      return null;
    }

    log("🔔 Notification authorization: ${settings.authorizationStatus}");

    final AuthorizationStatus status = settings.authorizationStatus;
    if (status == AuthorizationStatus.denied) {
      log("❌ Notification permission denied");
      return null;
    }

    if (status == AuthorizationStatus.notDetermined) {
      log("⚠️ Notification permission still not determined");
      return null;
    }

    /// ------------------------------------------------------
    /// iOS
    /// ------------------------------------------------------

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      log("🍎 iOS detected");

      String? apnsToken;

      for (int attempt = 1; attempt <= 30; attempt++) {
        try {
          apnsToken = await messaging.getAPNSToken();

          if (apnsToken != null && apnsToken.isNotEmpty) {
            log("APNS TOKEN: $apnsToken");
            break;
          }
        } catch (e) {
          log("⚠️ APNS token attempt $attempt failed: $e");
        }

        log("🍎 APNS token not ready. Attempt $attempt/30");

        await Future.delayed(const Duration(seconds: 1));
      }

      if (apnsToken == null || apnsToken.isEmpty) {
        log("❌ APNS TOKEN NOT AVAILABLE — FCM getToken() WILL NOT BE CALLED");
        return null;
      }
    }

    final String? fcmToken = await safeCall<String?>(
      'FirebaseMessaging.getToken',
          () => messaging.getToken(),
      timeout: const Duration(seconds: 20),
    );

    if (fcmToken == null || fcmToken.isEmpty) {
      log("❌ FCM TOKEN NOT AVAILABLE");
      return null;
    }

    FirebaseMessaging.instance.onTokenRefresh.listen(
          (String newToken) {
        log("🔄 FCM TOKEN REFRESHED: $newToken");
      },
      onError: (error) {
        log("⚠️ FCM token refresh error: $error");
      },
    );

    return fcmToken;
  } catch (e, st) {
    log("❌ setupFirebaseMessaging failed: $e");
    log("❌ STACK: $st");
    return null;
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    log("⚠️ Background Firebase init: $e");
  }

  try {
    final Map<String, dynamic> data = message.data;

    final String title = data['title']?.toString() ?? '';
    final String body = data['body']?.toString() ?? '';

    if (title.isEmpty && body.isEmpty) {
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'JPS',
      'JPS',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final int notificationId = (data['purpose_id'] ??
        data['task_id'] ??
        DateTime.now().millisecondsSinceEpoch.toString())
        .hashCode;

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      platformDetails,
      payload: jsonEncode(data),
    );

    log("🔔 Background notification displayed");
  } catch (e, st) {
    log("⚠️ Background notification failed: $e");
    log("⚠️ STACK: $st");
  }
}

void handleNotificationNavigation(Map<String, dynamic> data) {
  try {
    final String page = (data['title'] ?? '').toString().toLowerCase();
    final String role = localData.storage.read("role") ?? "";
    log("PAGE VALUE: $page");

    final NavigatorState? nav = navigatorKey.currentState;

    if (nav == null) {
      log("⚠️ NAVIGATOR NULL");
      return;
    }

    if (page.contains("expenses added to task")) {
      nav.push(MaterialPageRoute(
        builder: (_) => DashBoard(
          child: ViewExpense(tab: false, date1: today(), date2: today(), type: "Today"),
        ),
      ));
      return;
    }

    if (page.contains("task")) {
      nav.push(MaterialPageRoute(
        builder: (_) => DashBoard(
          child: ViewTask(date1: today(), date2: today(), type: "Today"),
        ),
      ));
      return;
    }

    if (page.contains("leave")) {
      nav.push(MaterialPageRoute(
        builder: (_) => DashBoard(
          child: role == "1"
              ? LeaveManagementDashboard()
              : ViewMyLeaves(date1: today(), date2: today(), isDirect: true),
        ),
      ));
      return;
    }

    if (page.contains("visit report added") ||
        page.contains("comments added to visit report")) {
      nav.push(MaterialPageRoute(
        builder: (_) => DashBoard(
          child: VisitReport(
            date1: today(),
            date2: today(),
            month: DateFormat("MMM yyyy").format(DateTime.now()),
            type: "Today",
          ),
        ),
      ));
      return;
    }

    log("⚠️ NO MATCH FOUND FOR PAGE: $page");
  } catch (e, st) {
    log("⚠️ handleNotificationNavigation failed: $e");
    log("⚠️ STACK: $st");
  }
}

String today() {
  final DateTime now = DateTime.now();
  return "${now.day.toString().padLeft(2, '0')}-"
      "${now.month.toString().padLeft(2, '0')}-"
      "${now.year}";
}

/// ==========================================================
/// FOREGROUND TASK
/// ==========================================================
///
/// 🔴 IMPORTANT: `FlutterForegroundTask.setTaskHandler(MyTaskHandler())`
/// must NEVER be called from the main isolate / main() startup flow.
/// It belongs ONLY inside a top-level callback function that the plugin
/// invokes when it spawns the background isolate — i.e. the function you
/// pass to `FlutterForegroundTask.startService(callback: ...)`.
///
/// Calling it here (main isolate, at app startup, before any service is
/// even started) registers nothing useful and leaves the
/// `flutter_foreground_task/background` channel with no handler when the
/// native side later calls "start" — that's exactly what produced your
/// MissingPluginException.
///
/// The correct top-level callback (`foregroundTaskCallback`) now lives in
/// `background_task.dart` next to `MyTaskHandler` — see the note below
/// this function for what needs to be added there, and where
/// `startService()` is called.

Future<void> setupForegroundTask() async {
  try {
    FlutterForegroundTask.initCommunicationPort();

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'JPS',
        channelName: 'JPS',
        channelDescription: 'Tracking is on',
        channelImportance: NotificationChannelImportance.DEFAULT,
        priority: NotificationPriority.DEFAULT,
      ),
      iosNotificationOptions: IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
        eventAction: ForegroundTaskEventAction.repeat(5000),
      ),
    );

    // ❌ REMOVED: FlutterForegroundTask.setTaskHandler(MyTaskHandler());
    // This call does NOT belong here. See note above.

    log("✅ Foreground task initialized (options set — handler registers on service start)");
  } catch (e, st) {
    log("⚠️ Foreground task initialization failed: $e");
    log("⚠️ STACK: $st");
  }
}

void setupForegroundFirebaseMessageListener() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    try {
      log("${message.data}");

      final BuildContext? context = navigatorKey.currentContext;

      if (context != null) {
        await safeCall(
          'HomeProvider.loadDashboard',
              () => Provider.of<HomeProvider>(context, listen: false).loadFullDashboard(context),
          timeout: const Duration(seconds: 10),
        );

        await safeCall(
          'EmployeeProvider.getNotifications',
              () => Provider.of<EmployeeProvider>(context, listen: false).getNotifications(),
          timeout: const Duration(seconds: 10),
        );
      }

      final String title =
          message.notification?.title ?? message.data['title'] ?? 'Notification';
      final String body = message.notification?.body ?? message.data['body'] ?? '';
      final String name = message.data['name']?.toString() ?? '';

      String messageText = body;
      String taskDate = DateFormat("dd-MM-yyyy").format(DateTime.now());

      if (body.contains("||")) {
        final List<String> parts = body.split("||");
        messageText = parts.first.trim();
        if (parts.length > 1) {
          taskDate = parts[1].trim();
        }
      }

      final dynamic taskId = message.data['task_id'] ?? message.data['purpose_id'] ?? '';

      if (context != null && taskId.toString().isNotEmpty) {
        await safeCall(
          'CustomerProvider.getTaskMainComments',
              () async {
            final CustomerProvider customerProvider =
            Provider.of<CustomerProvider>(context, listen: false);
            final TaskProvider taskProvider =
            Provider.of<TaskProvider>(context, listen: false);

            await Future.delayed(const Duration(milliseconds: 500));
            await customerProvider.getTaskMainComments(taskId);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                taskProvider.scrollToBottom();
              } catch (_) {}
            });
          },
          timeout: const Duration(seconds: 10),
        );
      }

      await safeCall('show local notification', () async {
        const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
          'JPS',
          'JPS',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        );

        const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        const NotificationDetails platformDetails = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

        if (title.contains("A new task has been assigned")) {
          await flutterLocalNotificationsPlugin.show(
            message.hashCode,
            messageText,
            "Created by $name .Task",
            platformDetails,
            payload: jsonEncode(message.data),
          );
        } else {
          await flutterLocalNotificationsPlugin.show(
            message.hashCode,
            messageText,
            title,
            platformDetails,
            payload: jsonEncode(message.data),
          );
        }
      });
    } catch (e, st) {
      log("⚠️ onMessage failed: $e");
      log("⚠️ STACK: $st");
    }
  });
}

void setupNotificationOpenedListener() {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    try {
      final String taskDate = message.data['task_date'] ??
          DateFormat('dd-MM-yyyy').format(DateTime.now());

      final String title =
      (message.notification?.title ?? message.data['title'] ?? '').toString().toLowerCase();
      final String body =
      (message.notification?.body ?? message.data['body'] ?? '').toString().toLowerCase();

      final NavigatorState? nav = navigatorKey.currentState;

      if (nav == null) {
        log("⚠️ Navigator not ready");
        return;
      }

      if (title.contains("task")) {
        nav.push(MaterialPageRoute(
          builder: (_) => ViewTask(
            date1: taskDate,
            date2: taskDate,
            type: taskDate.isEmpty ? "today" : "",
          ),
        ));
      }

      if (body.contains("daily work plan")) {
        nav.push(MaterialPageRoute(builder: (_) => DailyReportStatusPage()));
      }

      if (body.contains("requested")) {
        nav.push(MaterialPageRoute(builder: (_) => ViewMyLeaves()));
      }

      if (title.contains("visit report")) {
        nav.push(MaterialPageRoute(
          builder: (_) => VisitReport(date1: today(), date2: today(), month: "", type: "Today"),
        ));
      }

      if (title.contains("feedback")) {
        nav.push(MaterialPageRoute(
          builder: (_) => TaskChat(
            isVisit: false,
            taskId: '',
            assignedId: "",
            assignedName: "",
            name: '',
            date1: '',
            date2: '',
            type: '',
            index: -1,
          ),
        ));
      }
    } catch (e, st) {
      log("⚠️ onMessageOpenedApp failed: $e");
      log("⚠️ STACK: $st");
    }
  });
}

/// ==========================================================
/// MAIN
/// ==========================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await safeCall('GetStorage.init', () => GetStorage.init());

  bool homeScreen = false;

  await safeCall('SharedPreferences', () async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    homeScreen = prefs.getBool("homescreen") ?? false;
  });

  await safeCall(
    'Firebase.initializeApp',
        () => Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    timeout: const Duration(seconds: 12),
  );

  if (Firebase.apps.isEmpty) {
    await safeCall(
      'Firebase.initializeApp.retry',
          () => Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      timeout: const Duration(seconds: 15),
    );
  }

  if (Firebase.apps.isEmpty) {
    runApp(
      MaterialApp(
        navigatorKey: navigatorKey,
        locale: const Locale('en', 'US'),   // you already have this
        localizationsDelegates: [
          // ✅ ADD THIS — forces English country names, ignores device locale
          CountryLocalizations.getDelegate(enableLocalization: false),

        ],
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Couldn't connect to Firebase.\nPlease check your internet connection.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      main();
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return;
  }

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    await setupLocalNotifications();

    final String? fcmToken = await setupFirebaseMessaging();

    if (fcmToken != null) {
      log("🔥 FINAL FCM TOKEN: $fcmToken");
    } else {
      log("⚠️ FCM token was not available");
    }

    setupForegroundFirebaseMessageListener();
    setupNotificationOpenedListener();

    await safeCall('availableCameras', () async {
      cameras = await availableCameras();
    });

    await safeCall('ForegroundTask.init', setupForegroundTask);

    RemoteMessage? initialMessage;

    await safeCall(
      'FirebaseMessaging.getInitialMessage',
          () async {
        initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      },
      timeout: const Duration(seconds: 10),
    );

    if (initialMessage != null) {
      log("🚀 App launched from notification");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleNotificationNavigation(initialMessage!.data);
      });
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => TrackProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => PayrollProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => ExpasyProvider()),
        ChangeNotifierProvider(create: (_) => SettingProvider()),
        ChangeNotifierProvider(create: (_) => LanguageManager.instance),
      ],
      child: MyApp(homeScreen: homeScreen),
    ),
  );
}

/// ==========================================================
/// MY APP
/// ==========================================================

class MyApp extends StatelessWidget {
  final bool homeScreen;

  const MyApp({super.key, required this.homeScreen});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageManager>(   // ✅ சேர்த்தேன்
      builder: (context, langManager, _) {
        return ConnectivityAppWrapper(
          app: MaterialApp(
            navigatorKey: navigatorKey,
            builder: (context, child) {
              return ConnectivityWidgetWrapper(
                color: colorsConst.primary,
                message: "Check Your Internet Connection",
                disableInteraction: true,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  child: child!,
                ),
              );
            },
            useInheritedMediaQuery: true,
            locale: const Locale('en', 'US'),
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: false,
              colorScheme: ColorScheme.fromSeed(seedColor: colorsConst.primary),
              primaryColor: colorsConst.primary,
              scrollbarTheme: ScrollbarThemeData(
                thumbVisibility: WidgetStateProperty.all(true),
                thickness: WidgetStateProperty.all(5),
                thumbColor: WidgetStateProperty.all(colorsConst.primary.withOpacity(0.5)),
                radius: const Radius.circular(10),
                minThumbLength: 10,
              ),
              fontFamily: 'Lato',
            ),
            home: SplashScreen(homeScreen: homeScreen),
          ),
        );
      },
    );
  }
}

/// ==========================================================
/// SPLASH SCREEN
/// ==========================================================

class SplashScreen extends StatefulWidget {
  final bool homeScreen;

  const SplashScreen({
    super.key,
    required this.homeScreen,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    if (!mounted || _navigated) return;

    try {
      final HomeProvider homeProvider =
      Provider.of<HomeProvider>(context, listen: false);

      final LocationProvider locationProvider =
      Provider.of<LocationProvider>(context, listen: false);

      final AttendanceProvider attendanceProvider =
      Provider.of<AttendanceProvider>(context, listen: false);

      // --------------------------------------------------
      // Attendance
      // --------------------------------------------------

      await ensureAttendanceLoaded(attendanceProvider);

      if (!mounted) return;

      // --------------------------------------------------
      // Location
      // --------------------------------------------------

      await safeCall(
        'manageLocation',
            () => locationProvider.manageLocation(context, false),
        timeout: const Duration(seconds: 15),
      );

      if (!mounted) return;

      // --------------------------------------------------
      // Background initialization
      // --------------------------------------------------

      unawaited(
        safeCall(
          'locationProvider.requestPermissions',
              () => locationProvider.requestPermissions(),
          timeout: const Duration(seconds: 10),
        ),
      );

      unawaited(
        safeCall(
          'homeProvider.initValue',
              () async => homeProvider.initValue(),
          timeout: const Duration(seconds: 10),
        ),
      );

      unawaited(
        safeCall(
          'homeProvider.checkThisMonth',
              () async => homeProvider.checkThisMonth(),
          timeout: const Duration(seconds: 10),
        ),
      );

      // --------------------------------------------------
      // Dashboard
      // --------------------------------------------------

      unawaited(
        safeCall(
          'homeProvider.loadFullDashboard',
              () async {
            final ctx = navigatorKey.currentContext;

            if (ctx != null) {
              await homeProvider.loadFullDashboard(ctx);
            }
          },
          timeout: const Duration(seconds: 12),
        ),
      );

      // --------------------------------------------------
      // Version
      // --------------------------------------------------

      await safeCall(
        'homeProvider.checkVersion',
            () => homeProvider.checkVersion(),
        timeout: const Duration(seconds: 10),
      );

      if (!mounted) return;

      // --------------------------------------------------
      // Small delay so splash is visible
      // --------------------------------------------------

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted || _navigated) return;

      // --------------------------------------------------
      // Navigate
      // --------------------------------------------------

      await _navigate();
    } catch (e, st) {
      log("❌ Splash initialization failed: $e");
      log("❌ STACK: $st");

      if (!mounted || _navigated) return;

      _navigateToLogin();
    }
  }

  Future<void> _navigate() async {
    if (!mounted || _navigated) return;

    _navigated = true;

    try {
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      final String storedVersion =
          prefs.getString('appVersion') ?? "0";

      final String currentVersion =
      localData.versionNumber.toString();

      log("📦 Stored version: $storedVersion");
      log("📦 Current version: $currentVersion");
      log("🏠 Home screen: ${widget.homeScreen}");

      if (!mounted) return;

      if (storedVersion != currentVersion) {
        log("➡️ Version mismatch → Login");

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ),
        );

        return;
      }

      if (widget.homeScreen) {
        log("➡️ HomeScreen → Dashboard");

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => DashBoard(
              child: HomePage(),
            ),
          ),
        );

        return;
      }

      log("➡️ Default → Login");

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
      );
    } catch (e, st) {
      log("❌ Navigation error: $e");
      log("❌ STACK: $st");

      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (!mounted || _navigated) return;

    _navigated = true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assets.logo,
              width: 100,
              height: 100,
            ),

            const SizedBox(height: 20),

            CustomText(
              text: constValue.comName,
              size: 15,
              colors: colorsConst.primary,
            ),

            const SizedBox(height: 30),

            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
