import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:master_code/screens/common/detail_work_plan.dart';
import 'package:master_code/screens/common/home_page.dart';
import 'package:master_code/screens/customer/visit_report/visits_report.dart';
import 'package:master_code/screens/expense/view_expense.dart';
import 'package:master_code/screens/leave_management/leave_dashboard.dart';
import 'package:master_code/screens/leave_management/leave_report.dart';
import 'package:master_code/screens/task/task_chat.dart';
import 'package:master_code/screens/task/view_task.dart';
import 'package:master_code/screens/track/background_task.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:master_code/view_model/expasy_provider.dart';
import 'package:master_code/view_model/expense_provider.dart';
import 'package:master_code/view_model/leave_provider.dart';
import 'package:master_code/view_model/payroll_provider.dart';
import 'package:master_code/view_model/project_provider.dart';
import 'package:master_code/view_model/setting_provider.dart';
import 'package:master_code/view_model/task_provider.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:camera/camera.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:master_code/screens/common/camera.dart';
import 'package:master_code/screens/common/dashboard.dart';
import 'package:master_code/screens/log_in.dart';
import 'package:master_code/source/constant/assets_constant.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/constant/default_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:master_code/source/constant/local_data.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/attendance_provider.dart';
import 'package:master_code/view_model/customer_provider.dart';
import 'package:master_code/view_model/employee_provider.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:master_code/view_model/location_provider.dart';
import 'package:provider/provider.dart';
import 'package:master_code/view_model/report_provider.dart';
import 'package:master_code/view_model/track_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'component/custom_text.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

const AndroidInitializationSettings initializationSettingsAndroid =
AndroidInitializationSettings('@mipmap/ic_launcher');

const DarwinInitializationSettings initializationSettingsIOS =
DarwinInitializationSettings();

const InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
  iOS: initializationSettingsIOS,
);

/// ==========================================================
/// SAFE-CALL HELPER
/// Wraps ANY async call so poor network/location/GPS never
/// crashes the app — it just logs and moves on.
/// ==========================================================
Future<T?> safeCall<T>(
    String tag,
    Future<T> Function() action, {
      Duration timeout = const Duration(seconds: 8),
    }) async {
  try {
    return await action().timeout(timeout);
  } on TimeoutException {
    log("⏱️ [$tag] TIMED OUT — continuing without it");
    return null;
  } catch (e, st) {
    log("⚠️ [$tag] FAILED: $e");
    log("StackTrace: $st");
    return null;
  }
}

/// ******************************
///  BACKGROUND FIREBASE HANDLER
/// ******************************
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await safeCall('BG:Firebase.initializeApp', () => Firebase.initializeApp());

  try {
    // FIX: "message.notification" nu paakama, "message.data" edukkurom.
    // Backend ippo "data" payload mattum anuppுrathala (notification key
    // illa), so system automatic-a tray notification kaattadhu.
    // Idhே function than ONE notification manual-a build pannanum.
    final data = message.data;

    final String title = data['title'] ?? '';
    final String body  = data['body'] ?? '';

    if (title.isEmpty && body.isEmpty) {
      return; // enna kaatta vendiyadhu illa
    }

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'JPS',
      'JPS',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      // notification.hashCode illama, data/purpose_id vechu unique id
      // pannunga -> notification.hashCode ippo kidaikathu (data-only).
      (data['purpose_id'] ?? DateTime.now().millisecondsSinceEpoch.toString())
          .hashCode,
      title,
      body,
      platformDetails,
      payload: jsonEncode(message.data),
    );
  } catch (e) {
    log("⚠️ Background notification show failed: $e");
  }
}

void handleNotificationNavigation(Map<String, dynamic> data) {
  try {
    final page = (data['title'] ?? '').toString().toLowerCase();
    String role = localData.storage.read("role") ?? "";

    log("========= NOTIFICATION CLICKED =========");
    log("PAGE VALUE: $page");

    final nav = navigatorKey.currentState;
    if (nav == null) {
      log("NAVIGATOR NULL");
      return;
    }

    if (page.contains("expenses added to task")) {
      nav.push(MaterialPageRoute(
        builder: (_) => DashBoard(
          child: ViewExpense(
            tab: false,
            date1: today(),
            date2: today(),
            type: "Today",
          ),
        ),
      ));
    } else if (page.contains("task")) {
      nav.push(MaterialPageRoute(
        builder: (_) => DashBoard(
          child: ViewTask(date1: today(), date2: today(), type: "Today"),
        ),
      ));
    } else if (page.contains('leave')) {
      nav.push(MaterialPageRoute(
        builder: (_) => DashBoard(
          child: role == "1"
              ? LeaveManagementDashboard()
              : ViewMyLeaves(date1: today(), date2: today(), isDirect: true),
        ),
      ));
    } else if (page.contains('visit report added') ||
        page.contains('comments added to visit report')) {
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
    } else {
      log("NO MATCH FOUND FOR PAGE: $page");
    }
  } catch (e) {
    log("⚠️ handleNotificationNavigation failed: $e");
  }
}

String today() {
  final now = DateTime.now();
  return "${now.day.toString().padLeft(2, '0')}-"
      "${now.month.toString().padLeft(2, '0')}-"
      "${now.year}";
}

Future<void> setupLocalNotifications() async {
  await safeCall('setupLocalNotifications', () async {
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == null) return;
        try {
          final data = jsonDecode(response.payload!);
          handleNotificationNavigation(data);
        } catch (e) {
          log("Error decoding payload: $e");
        }
      },
    );
  });
}

/// ******************************
///            MAIN
/// ******************************
/// ******************************
///            MAIN
/// ******************************
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Storage — local, should not fail, but guard anyway
  await safeCall('GetStorage.init', () => GetStorage.init());

  bool homeScreen = false;
  await safeCall('SharedPreferences', () async {
    final prefs = await SharedPreferences.getInstance();
    homeScreen = prefs.getBool("homescreen") ?? false;
  });

  // Firebase core init — needs network the first time on some devices.
  //
  // IMPORTANT FIX: safeCall() swallows timeouts/errors and returns null
  // silently. Before this fix, if Firebase.initializeApp() timed out on
  // a slow first-launch network, main() just continued as if it worked.
  // Every later screen that touches Firestore/Messaging
  // (e.g. FirebaseFirestore.instance.collection(...).snapshots() in
  // HomePage) then crashed with [core/no-app] No Firebase App '[DEFAULT]'
  // has been created.
  //
  // Fix: try once, retry once on failure, and if it still fails, DO NOT
  // fall through into runApp(MyApp()) — show a blocking retry screen
  // instead so the user can retry once network is back.
  await safeCall(
    'Firebase.initializeApp',
        () => Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    timeout: const Duration(seconds: 12),
  );

  if (Firebase.apps.isEmpty) {
    // one retry — covers slow-network first-launch case
    await safeCall(
      'Firebase.initializeApp.retry',
          () => Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      timeout: const Duration(seconds: 15),
    );
  }

  if (Firebase.apps.isEmpty) {
    // Still failed — don't proceed into HomePage/Firestore calls that
    // will crash. Show a minimal retry UI instead of a blank crash.
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Couldn't connect. Please check your internet and try again.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => main(),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return; // stop here — don't fall through to the rest of main()
  }

  if (!kIsWeb) {
    await safeCall('setupLocalNotifications', () => setupLocalNotifications());

    // Camera list — can fail on some devices/emulators
    await safeCall('availableCameras', () async {
      cameras = await availableCameras();
    });

    // Foreground task setup — should not crash even if OS denies it
    await safeCall('ForegroundTask.init', () async {
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
          autoRunOnBoot: true,
          allowWakeLock: true,
          allowWifiLock: true,
          eventAction: ForegroundTaskEventAction.repeat(5000),
        ),
      );
      FlutterForegroundTask.setTaskHandler(MyTaskHandler());
    });

    /// ******************************
    ///     FOREGROUND MESSAGE
    /// ******************************
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      try {
        log("FOREGROUND Message: ${message.data}");

        final context = navigatorKey.currentContext;

        if (context != null) {
          await safeCall(
            'HomeProvider.loadDashboard',
                () => Provider.of<HomeProvider>(context, listen: false)
                .loadDashboard(context),
            timeout: const Duration(seconds: 10),
          );

          await safeCall(
            'EmployeeProvider.getNotifications',
                () => Provider.of<EmployeeProvider>(context, listen: false)
                .getNotifications(),
            timeout: const Duration(seconds: 10),
          );
        }

        // NOTE: backend now sends "data" payload only (no "notification"
        // key) — so message.notification will be null and this falls
        // through to message.data automatically. Left as-is intentionally
        // so nothing breaks if backend ever adds "notification" back.
        final title = message.notification?.title ??
            message.data['title'] ??
            'Notification';
        final body = message.notification?.body ?? message.data['body'] ?? '';
        final name = message.data['name'] ?? '';

        String messageText = body;
        String taskDate = DateFormat("dd-MM-yyyy").format(DateTime.now());

        if (body.contains("||")) {
          final parts = body.split("||");
          messageText = parts[0].trim();
          if (parts.length > 1) taskDate = parts[1].trim();
        }

        final taskId = message.data['task_id'] ?? message.data['purpose_id'] ?? "";

        if (context != null && taskId.toString().isNotEmpty) {
          await safeCall('CustomerProvider.getTaskMainComments', () async {
            final customerProvider =
            Provider.of<CustomerProvider>(context, listen: false);
            final taskProvider = Provider.of<TaskProvider>(context, listen: false);

            await Future.delayed(const Duration(milliseconds: 500));
            await customerProvider.getTaskMainComments(taskId);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                taskProvider.scrollToBottom();
              } catch (_) {}
            });
          }, timeout: const Duration(seconds: 10));
        }

        /// 🔔 LOCAL NOTIFICATION — always attempt, never crash
        await safeCall('show local notification', () async {
          const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'JPS',
            'JPS',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
          );

          const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

          if (title.toString().contains("A new task has been assigned")) {
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
        log("⚠️ onMessage handler failed entirely: $e");
        log("StackTrace: $st");
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      try {
        final taskDate = message.data['task_date'] ??
            DateFormat('dd-MM-yyyy').format(DateTime.now());

        // NOTE: same as above — falls back to message.data if you want
        // to fully remove dependency on message.notification, switch
        // these two lines to read from message.data['title'] /
        // message.data['body'] directly instead.
        final title = message.notification?.title?.toLowerCase() ?? '';
        final body = message.notification?.body?.toLowerCase() ?? '';

        if (title.contains("task")) {
          navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (_) => ViewTask(
              date1: taskDate,
              date2: taskDate,
              type: taskDate == "" ? "today" : "",
            ),
          ));
        }
        if (body.contains("daily work plan")) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => DailyReportStatusPage()),
          );
        }
        if (body.contains("requested")) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => ViewMyLeaves()),
          );
        }
        if (title.contains("visit report")) {
          navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (_) => VisitReport(
              date1: DateFormat("dd-MM-yyyy").format(DateTime.now()),
              date2: DateFormat("dd-MM-yyyy").format(DateTime.now()),
              month: "",
              type: "Today",
            ),
          ));
        }
        if (title.contains("feedback")) {
          navigatorKey.currentState?.push(MaterialPageRoute(
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
      } catch (e) {
        log("⚠️ onMessageOpenedApp handler failed: $e");
      }
    });

    /// BACKGROUND HANDLER
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
      ],
      child: MyApp(homeScreen: homeScreen),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool homeScreen;
  const MyApp({super.key, required this.homeScreen});

  @override
  Widget build(BuildContext context) {
    return ConnectivityAppWrapper(
      app: MaterialApp(
        navigatorKey: navigatorKey,
        builder: (context, child) {
          return ConnectivityWidgetWrapper(
            color: colorsConst.primary,
            message: "Check Your Internet Connection",
            disableInteraction: true,
            child: MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
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
            thumbColor:
            WidgetStateProperty.all(colorsConst.primary.withOpacity(0.5)),
            radius: const Radius.circular(10),
            minThumbLength: 10,
          ),
          fontFamily: 'Lato',
        ),
        home: SplashScreen(homeScreen: homeScreen),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final bool homeScreen;
  const SplashScreen({super.key, required this.homeScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  dynamic storedVersion;
  dynamic currentVersion;
  bool _navigated = false; // prevent double navigation

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      if (!mounted) return;

      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final locationProvider =
      Provider.of<LocationProvider>(context, listen: false);
      final attendanceProvider =
      Provider.of<AttendanceProvider>(context, listen: false);

      // ✅ Every network/location call below is wrapped —
      // if network is weak or GPS is denied/slow, it just times
      // out silently after a few seconds and the app keeps going.

      await safeCall(
        'homeProvider.checkVersion',
            () => homeProvider.checkVersion(),
        timeout: const Duration(seconds: 10),
      );

      // ✅ Navigation decision happens regardless of what happened above
      await checkForUpdates(context);

      // Fire-and-forget background refreshes — do NOT block navigation
      // or crash the splash screen if location/network is poor.
      unawaited(safeCall(
        'locationProvider.requestPermissions',
            () async => locationProvider.requestPermissions(),
        timeout: const Duration(seconds: 10),
      ));

      unawaited(safeCall(
        'homeProvider.initValue',
            () async => homeProvider.initValue(),
        timeout: const Duration(seconds: 10),
      ));

      unawaited(safeCall(
        'homeProvider.checkThisMonth',
            () async => homeProvider.checkThisMonth(),
        timeout: const Duration(seconds: 10),
      ));

      unawaited(safeCall(
        'homeProvider.loadFullDashboard',
            () => homeProvider.loadFullDashboard(context),
        timeout: const Duration(seconds: 12),
      ));

      unawaited(safeCall(
        'attendanceProvider.getMainAttendance',
            () => attendanceProvider.getMainAttendance(),
        timeout: const Duration(seconds: 10),
      ));
    });
  }

  Future<void> checkForUpdates(BuildContext context) async {
    if (_navigated || !mounted) return;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      storedVersion = prefs.getString('appVersion') ?? "0";
      currentVersion = localData.versionNumber;
    } catch (e) {
      log("⚠️ checkForUpdates prefs read failed: $e — defaulting to login flow");
      storedVersion = "0";
      currentVersion = "0"; // forces same path safely
    }

    if (!mounted || _navigated) return;
    _navigated = true;

    try {
      if (storedVersion != currentVersion) {
        log("Navigating: version mismatch → Login");
        utils.navigatePage(context, () => const LoginPage());
      } else if (widget.homeScreen) {
        log("Navigating: homeScreen=true → Dashboard");
        utils.navigatePage(context, () => DashBoard(child: HomePage()));
      } else {
        log("Navigating: default → Login");
        utils.navigatePage(context, () => const LoginPage());
      }
    } catch (e) {
      // Absolute last resort — never leave the user stuck on splash
      log("⚠️ Navigation failed, forcing LoginPage: $e");
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 300,
      splashIconSize: 800,
      splashTransition: SplashTransition.fadeTransition,
      splash: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            100.height,
            Image.asset(
              assets.logo,
              width: 100,
              height: 100,
            ),
            20.height,
            CustomText(
              text: "${constValue.comName}\n",
              size: 15,
              colors: colorsConst.primary,
            ),
          ],
        ),
      ),
      // nextScreen is only a fallback for AnimatedSplashScreen's own timer;
      // actual navigation is driven by checkForUpdates() above so it can
      // react correctly even if version check is slow/fails.
      nextScreen: storedVersion != currentVersion
          ? const LoginPage()
          : widget.homeScreen
          ? DashBoard(child: HomePage())
          : const LoginPage(),
    );
  }
}