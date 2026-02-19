// import 'dart:developer';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:master_code/screens/common/home_page.dart';
// import 'package:master_code/source/utilities/utils.dart';
// import 'package:master_code/view_model/expense_provider.dart';
// import 'package:master_code/view_model/leave_provider.dart';
// import 'package:master_code/view_model/payroll_provider.dart';
// import 'package:master_code/view_model/project_provider.dart';
// import 'package:master_code/view_model/task_provider.dart';
// import 'package:animated_splash_screen/animated_splash_screen.dart';
// import 'package:camera/camera.dart';
// import 'package:connectivity_wrapper/connectivity_wrapper.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:master_code/screens/common/camera.dart';
// import 'package:master_code/screens/common/dashboard.dart';
// import 'package:master_code/screens/log_in.dart';
// import 'package:master_code/source/constant/assets_constant.dart';
// import 'package:master_code/source/constant/colors_constant.dart';
// import 'package:master_code/source/constant/default_constant.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:master_code/source/constant/local_data.dart';
// import 'package:master_code/source/extentions/extensions.dart';
// import 'package:master_code/view_model/attendance_provider.dart';
// import 'package:master_code/view_model/customer_provider.dart';
// import 'package:master_code/view_model/employee_provider.dart';
// import 'package:master_code/view_model/home_provider.dart';
// import 'package:master_code/view_model/location_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:master_code/view_model/report_provider.dart';
// import 'package:master_code/view_model/track_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'component/custom_text.dart';
// import 'firebase_options.dart';
// // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// // FlutterLocalNotificationsPlugin();
// //
// // @pragma('vm:entry-point')
// // Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// //   if (Firebase.apps.isNotEmpty) {
// //     log("FIREBASE INITIALIZED Error***********");
// //   }else{
// //     log("FIREBASE INITIALIZED***********");
// //     await Firebase.initializeApp();
// //   }
// //   log("Handling a background message: ${message.messageId}");
// //   log('Got a message whilst in the foreground!');
// //   log('Message data:Message data: ${message.data}');
// //   if (message.notification != null) {
// //     // testController.notificationCount.value++;
// //       const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
// //       const DarwinInitializationSettings iosInitializationSetting =
// //       DarwinInitializationSettings (
// //         requestSoundPermission: true,
// //         requestBadgePermission: true,
// //         requestAlertPermission: true,
// //       );
// //
// //       DarwinNotificationDetails iosNotificationDetails = const DarwinNotificationDetails();
// //       const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid,iOS: iosInitializationSetting);
// //       await flutterLocalNotificationsPlugin.initialize(initializationSettings);
// //       const AndroidNotificationDetails androidPlatformChannelSpecifics =
// //       AndroidNotificationDetails(
// //         'JPS',
// //         'JPS',
// //         importance: Importance.max,
// //         priority: Priority.high,
// //         playSound: true,
// //         showProgress: true,
// //         showWhen: false,
// //         enableVibration: true,
// //         icon: '@mipmap/ic_launcher',
// //         enableLights: true,
// //         // sound: RawResourceAndroidNotificationSound('new_level.mp3'), // specify your sound here
// //         largeIcon: DrawableResourceAndroidBitmap("@mipmap/ic_launcher"),
// //         styleInformation: MediaStyleInformation(
// //           htmlFormatContent: true,
// //           htmlFormatTitle: true,
// //         ),
// //       );
// //       NotificationDetails platformChannelSpecifics =
// //       NotificationDetails(android: androidPlatformChannelSpecifics,iOS: iosNotificationDetails);
// //       await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
// //         alert: true,
// //         badge: true,
// //         sound: true,
// //       );
// //       RemoteNotification? notification = message.notification;
// //       AndroidNotification? android = message.notification?.android;
// //       if (notification != null && android != null) {
// //         flutterLocalNotificationsPlugin.show(
// //             notification.hashCode,
// //             notification.title,
// //             notification.body,
// //             platformChannelSpecifics,
// //         );
// //       }
// //   }
// // }
// //
// // Future<void> main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await GetStorage.init();
// //   final prefs =await SharedPreferences.getInstance();
// //   final homeScreen= prefs.getBool("homescreen")??false;
// //   if(!kIsWeb){
// //     await Firebase.initializeApp(
// //         options: DefaultFirebaseOptions.currentPlatform
// //     );
// //     // ✅ Now it’s safe to use Firebase Analytics
// //     try {
// //       final analytics = FirebaseAnalytics.instance;
// //       await analytics.logAppOpen();
// //       print("Firebase Analytics initialized successfully");
// //     } catch (e) {
// //       print("Firebase Analytics init error: $e");
// //     }
// //     cameras = await availableCameras();
// //     FlutterForegroundTask.initCommunicationPort();
// //     FlutterForegroundTask.init(
// //       androidNotificationOptions: AndroidNotificationOptions(
// //         channelId: constValue.appName,
// //         channelName: constValue.appName,
// //         channelDescription: 'Tracking is on',
// //         channelImportance: NotificationChannelImportance.DEFAULT,
// //         priority: NotificationPriority.DEFAULT,
// //       ),
// //       iosNotificationOptions: const IOSNotificationOptions(),
// //       foregroundTaskOptions: ForegroundTaskOptions(
// //         autoRunOnBoot: true,
// //         allowWakeLock: true,
// //         allowWifiLock: true,
// //         eventAction: ForegroundTaskEventAction.repeat(5000),
// //       ),
// //     );
// //     FlutterForegroundTask.setTaskHandler(MyTaskHandler());
// //
// //     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
// //       log('Got a message whilst in the foreground!');
// //       log('Message data: ${message.data}');
// //
// //       final title = message.notification?.title ?? message.data['title'] ?? 'Notification';
// //       final body = message.notification?.body ?? message.data['body'] ?? '';
// //
// //       if (title.isNotEmpty || body.isNotEmpty) {
// //         const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
// //           'JPS',
// //           'JPS',
// //           importance: Importance.max,
// //           priority: Priority.high,
// //           playSound: true,
// //           enableVibration: true,
// //           icon: '@mipmap/ic_launcher',
// //         );
// //
// //         const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
// //
// //         await flutterLocalNotificationsPlugin.show(
// //           message.hashCode,
// //           title,
// //           body,
// //           platformDetails,
// //         );
// //       }
// //     });
// //
// //
// //     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
// //   }
// //   runApp(MultiProvider(providers: [
// //     ChangeNotifierProvider(create: (_) => HomeProvider()),
// //     ChangeNotifierProvider(create: (_) => EmployeeProvider()),
// //     ChangeNotifierProvider(create: (_) => CustomerProvider()),
// //     ChangeNotifierProvider(create: (_) => AttendanceProvider()),
// //     ChangeNotifierProvider(create: (_) => LocationProvider()),
// //     ChangeNotifierProvider(create: (_) => TrackProvider()),
// //     ChangeNotifierProvider(create: (_) => ReportProvider()),
// //     ChangeNotifierProvider(create: (_) => ExpenseProvider()),
// //     ChangeNotifierProvider(create: (_) => TaskProvider()),
// //     ChangeNotifierProvider(create: (_) => LeaveProvider()),
// //     ChangeNotifierProvider(create: (_) => PayrollProvider()),
// //     ChangeNotifierProvider(create: (_) => ProjectProvider()),
// //   ], child: MyApp(homeScreen: homeScreen,)));
// // }
//
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();
//
// /// ******************************
// ///  BACKGROUND FIREBASE HANDLER
// /// ******************************
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//
//   print("Background Message: ${message.messageId}");
//   print("Background Message Data: ${message.data}");
//
//   RemoteNotification? notification = message.notification;
//   AndroidNotification? android = notification?.android;
//
//   // 👉 Background handler should show notification ONLY when app is in background.
//   if (notification != null && android != null) {
//     const AndroidNotificationDetails androidDetails =
//     AndroidNotificationDetails(
//       'JPS',
//       'JPS',
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//       enableVibration: true,
//       icon: '@mipmap/ic_launcher',
//     );
//
//     const NotificationDetails platformDetails =
//     NotificationDetails(android: androidDetails);
//
//     await flutterLocalNotificationsPlugin.show(
//       notification.hashCode,
//       notification.title,
//       notification.body,
//       platformDetails,
//     );
//   }
// }
//
// /// ******************************
// ///            MAIN
// /// ******************************
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await GetStorage.init();
//   final prefs = await SharedPreferences.getInstance();
//   final homeScreen = prefs.getBool("homescreen") ?? false;
//
//   if (!kIsWeb) {
//     await Firebase.initializeApp(
//         options: DefaultFirebaseOptions.currentPlatform);
//
//     cameras = await availableCameras();
//
//     /// Foreground Task Setup
//     FlutterForegroundTask.initCommunicationPort();
//     FlutterForegroundTask.init(
//       androidNotificationOptions: AndroidNotificationOptions(
//         channelId: 'JPS',
//         channelName: 'JPS',
//         channelDescription: 'Tracking is on',
//         channelImportance: NotificationChannelImportance.DEFAULT,
//         priority: NotificationPriority.DEFAULT,
//       ),
//       iosNotificationOptions: IOSNotificationOptions(),
//       foregroundTaskOptions: ForegroundTaskOptions(
//         autoRunOnBoot: true,
//         allowWakeLock: true,
//         allowWifiLock: true,
//         eventAction: ForegroundTaskEventAction.repeat(5000),
//       ),
//     );
//     FlutterForegroundTask.setTaskHandler(MyTaskHandler());
//
//     /// *********** NOTIFICATION INITIALIZATION ***********
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const DarwinInitializationSettings iosInitializationSettings =
//     DarwinInitializationSettings();
//
//     const InitializationSettings initializationSettings =
//     InitializationSettings(
//         android: initializationSettingsAndroid,
//         iOS: iosInitializationSettings);
//
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//
//     /// ******************************
//     ///     FOREGROUND MESSAGE
//     /// ******************************
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       print("FOREGROUND Message: ${message.data}");
//
//       final title =
//           message.notification?.title ?? message.data['title'] ?? 'Notification';
//       final body = message.notification?.body ?? message.data['body'] ?? '';
//
//       const AndroidNotificationDetails androidDetails =
//       AndroidNotificationDetails(
//         'JPS',
//         'JPS',
//         importance: Importance.max,
//         priority: Priority.high,
//         playSound: true,
//         enableVibration: true,
//         icon: '@mipmap/ic_launcher',
//       );
//
//       const NotificationDetails platformDetails =
//       NotificationDetails(android: androidDetails);
//
//       await flutterLocalNotificationsPlugin.show(
//         message.hashCode,
//         title,
//         body,
//         platformDetails,
//       );
//     });
//
//     /// BACKGROUND HANDLER
//     FirebaseMessaging.onBackgroundMessage(
//         _firebaseMessagingBackgroundHandler);
//   }
//
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => HomeProvider()),
//         ChangeNotifierProvider(create: (_) => EmployeeProvider()),
//         ChangeNotifierProvider(create: (_) => CustomerProvider()),
//         ChangeNotifierProvider(create: (_) => AttendanceProvider()),
//         ChangeNotifierProvider(create: (_) => LocationProvider()),
//         ChangeNotifierProvider(create: (_) => TrackProvider()),
//         ChangeNotifierProvider(create: (_) => ReportProvider()),
//         ChangeNotifierProvider(create: (_) => ExpenseProvider()),
//         ChangeNotifierProvider(create: (_) => TaskProvider()),
//         ChangeNotifierProvider(create: (_) => LeaveProvider()),
//         ChangeNotifierProvider(create: (_) => PayrollProvider()),
//         ChangeNotifierProvider(create: (_) => ProjectProvider()),
//       ],
//       child: MyApp(homeScreen: homeScreen),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   final bool homeScreen;
//   const MyApp({super.key,required this.homeScreen});
//   @override
//   Widget build(BuildContext context){
//     return ConnectivityAppWrapper(
//       app: MaterialApp(
//           builder: (context, child){
//             return ConnectivityWidgetWrapper(
//                 color: colorsConst.primary,
//                 message: "Check Your Internet Connection",
//                 disableInteraction: true,
//                 child:  MediaQuery(
//                   data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
//                   child: child!,
//                 )
//             );
//           },
//           useInheritedMediaQuery: true,
//           locale: const Locale('en','US'),
//           supportedLocales: const [
//             Locale('en', 'GB'), // இங்கிலாந்து locale-ஐ ஆதரிக்கிறது
//             Locale('en', 'US'),
//             // ... மற்ற மொழிகள்
//           ],
//           debugShowCheckedModeBanner: false,
//           theme: ThemeData(
//             useMaterial3: false,
//             colorScheme: ColorScheme.fromSeed(seedColor: colorsConst.primary),
//             primaryColor: colorsConst.primary,
//             scrollbarTheme: ScrollbarThemeData(
//               thumbVisibility: WidgetStateProperty.all(true),
//               thickness: WidgetStateProperty.all(5),
//               thumbColor: WidgetStateProperty.all(colorsConst.primary.withOpacity(0.5)),
//               radius: const Radius.circular(10),
//               minThumbLength: 10,
//             ),
//             fontFamily: 'Lato',
//           ),
//           home:SplashScreen(homeScreen: homeScreen,)
//       ),
//     );
//   }
// }
// class SplashScreen extends StatefulWidget {
//   final bool homeScreen;
//   const SplashScreen({super.key, required this.homeScreen});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   dynamic storedVersion;
//   dynamic currentVersion;
//   // @override
//   // void initState() {
//     // checkForUpdates(context);
//     // Future.delayed(Duration.zero, () {
//     //   Provider.of<HomeProvider>(context, listen: false).checkVersion();
//     //   Provider.of<LocationProvider>(context, listen: false).requestPermissions();
//     //   Provider.of<HomeProvider>(context, listen: false).initValue();
//     //   Provider.of<HomeProvider>(context, listen: false).roleEmployees();
//     //   Provider.of<AttendanceProvider>(context, listen: false).getMainAttendance();
//     // });
//
//   //   super.initState();
//   // }
//   @override
//   void initState() {
//     super.initState();
//     checkForUpdates(context); // runs immediately
//
//     Future.delayed(Duration.zero, () {
//       if (!mounted) return;
//
//       final homeProvider = Provider.of<HomeProvider>(context, listen: false);
//       final locationProvider = Provider.of<LocationProvider>(context, listen: false);
//       final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
//
//       homeProvider.checkVersion();
//       locationProvider.requestPermissions();
//       homeProvider.initValue();
//       // homeProvider.roleEmployees();
//       attendanceProvider.getMainAttendance();
//       homeProvider.getMainReport(true);
//       homeProvider.getDashboardReport(true);
//     });
//   }
//
//   checkForUpdates(context) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     storedVersion = prefs.getString('appVersion') ?? "0";
//     currentVersion = localData.versionNumber;
//     if (storedVersion != currentVersion) {
//       print("1 ${storedVersion != currentVersion}");
//       utils.navigatePage(context, ()=>const LoginPage());
//     } else if(widget.homeScreen){
//       print("2 ${storedVersion != currentVersion}");
//       utils.navigatePage(context, ()=>const DashBoard(child: HomePage(),));
//     }else {
//       print("3 ${storedVersion != currentVersion}");
//       utils.navigatePage(context, ()=>const LoginPage());
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedSplashScreen(
//       duration: 300,
//       splashIconSize: 800,
//       splashTransition: SplashTransition.fadeTransition,
//       splash:Container(
//         color: Colors.white,
//         width: double.infinity,
//         height: double.infinity,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             100.height,
//             Image.asset(
//               assets.logo,
//               width: 100,
//               height: 100,
//             ),
//             20.height,
//             CustomText(text: constValue.appName,colors: colorsConst.primary,size: 20,isBold: true,),
//             CustomText(text:"${constValue.comName}\n",size: 15,colors: colorsConst.primary,),
//           ],
//         ),
//       ),
//       nextScreen: storedVersion != currentVersion?const LoginPage():widget.homeScreen?const DashBoard(child: HomePage()):const LoginPage(),
//       // nextScreen: const DashBoard(),
//     );
//   }
// }
//
//

import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:master_code/screens/common/home_page.dart';
import 'package:master_code/screens/common/home_page_copy.dart';
import 'package:master_code/screens/customer/visit_report/visits_report.dart';
import 'package:master_code/screens/expense/view_expense.dart';
import 'package:master_code/screens/leave_management/leave_dashboard.dart';
import 'package:master_code/screens/leave_management/leave_report.dart';
import 'package:master_code/screens/task/view_task.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:master_code/view_model/expense_provider.dart';
import 'package:master_code/view_model/leave_provider.dart';
import 'package:master_code/view_model/payroll_provider.dart';
import 'package:master_code/view_model/project_provider.dart';
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
/// ******************************
///  BACKGROUND FIREBASE HANDLER
/// ******************************

@pragma('vm:entry-point')

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  RemoteNotification? notification = message.notification;
  AndroidNotification? android = notification?.android;

  if (notification != null && android != null) {
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
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
      payload: jsonEncode(message.data),
    );
  }
}

void handleNotificationNavigation(Map<String, dynamic> data) {
  final page = data['title'].toString().toLowerCase();
  String role = localData.storage.read("role");

  print("========= NOTIFICATION CLICKED =========");
  print("PAGE VALUE: $page");

  final nav = navigatorKey.currentState;
  if (nav == null) {
    print("NAVIGATOR NULL");
    return;
  }

  // ➤ Expenses Added
  if (page.toString().contains("Expenses added to task")) {
    print("MATCHED: Expenses added to task");

    nav.push(
      MaterialPageRoute(
        builder: (_) => DashBoard(
          child: ViewExpense(
            tab: false,
            date1: today(),
            date2: today(),
            type: "Today",
          ),
        ),
      ),
    );
  }

  // ➤ New Task
  else if (page.toString().contains("task")||page.toString().contains("new task")) {
    print("MATCHED: New Task");

    nav.push(
      MaterialPageRoute(
        builder: (_) => DashBoard(
          child: ViewTask(
            date1: today(),
            date2: today(),
            type: "Today",
          ),
        ),
      ),
    );
  }

  // ➤ Leave
  else if (page.toString().contains('Leave')) {
    print("MATCHED: Leave");

    nav.push(
      MaterialPageRoute(
        builder: (_) => DashBoard(
          child: role == "1"
              ? LeaveManagementDashboard()
              : ViewMyLeaves(
            date1: today(),
            date2: today(), isDirect: true,
          ),
        ),
      ),
    );
  }

  // ➤ Visit Report Added
  else if (page.toString().contains('Visit report added')) {
    print("MATCHED: Visit report added");

    nav.push(
      MaterialPageRoute(
        builder: (_) => DashBoard(
          child: VisitReport(
            date1: today(),
            date2: today(),
            month: DateFormat("MMM yyyy").format(DateTime.now()),
            type: "Today",
          ),
        ),
      ),
    );
  }

  // ➤ Comments Added to Visit Report
  else if (page.toString().contains('Comments added to visit report')) {
    print("MATCHED: Comments added to visit report");

    nav.push(
      MaterialPageRoute(
        builder: (_) => DashBoard(
          child: VisitReport(
            date1: today(),
            date2: today(),
            month: DateFormat("MMM yyyy").format(DateTime.now()),
            type: "Today",
          ),
        ),
      ),
    );
  }

  // ➤ No Match
  else {
    print("NO MATCH FOUND FOR PAGE: $page");
  }
}

String today() {
  final now = DateTime.now();
  return "${now.day.toString().padLeft(2, '0')}-"
      "${now.month.toString().padLeft(2, '0')}-"
      "${now.year}";
}
// main-க்கு வெளியே சேர்க்கவும்
Future<void> setupLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosInitializationSettings =
  DarwinInitializationSettings();

  const InitializationSettings initializationSettings =
  InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: iosInitializationSettings);

  // ✅ ஒருமுறை மட்டுமே initialize செய்யவும், கிளிக் ஈவென்ட்டை இங்கே கையாளவும்.
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload == null) return;

      // நோட்டிஃபிகேஷன் கிளிக் செய்யப்பட்டால் மட்டுமே இந்த print வரும்
      print("NOTIFICATION CLICKED CALLBACK FIRED");

      try {
        final data = jsonDecode(response.payload!);
        // நோட்டிஃபிகேஷன் கிளிக் செய்யப்பட்டால் மட்டுமே Navigation தொடங்கும்
        handleNotificationNavigation(data);
      } catch (e) {
        print("Error decoding payload: $e");
      }
    },
  );
}
/// ******************************
///            MAIN (CORRECTED)
/// ******************************
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  final prefs = await SharedPreferences.getInstance();
  final homeScreen = prefs.getBool("homescreen") ?? false;

  if (!kIsWeb) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    // --- ✅ 1. நோட்டிஃபிகேஷன் INITIALIZE-ஐ இங்கு ஒருமுறை மட்டும் அழைக்கவும் ---
    await setupLocalNotifications();

    cameras = await availableCameras();

    // ... (Foreground Task Setup - இதில் எந்த மாற்றமும் இல்லை) ...
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

    // ❌ கீழே இருந்த duplicate initialize அமைப்புகள் நீக்கப்பட்டுவிட்டன.
    /*
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    // ... (மற்ற initialize அமைப்புகள்) ...
    await flutterLocalNotificationsPlugin.initialize(initializationSettings); // இந்த வரி நீக்கப்பட்டுவிட்டது
    */

    /// ******************************
    ///     FOREGROUND MESSAGE
    /// ******************************
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print("FOREGROUND Message: ${message.data}");

        // 🔔 நோட்டிஃபிகேஷன் வரும்போதே print ஆகும்
        print("--- Notification RECEIVED (NOT CLICKED) ---");

        final title =
            message.notification?.title ?? message.data['title'] ?? 'Notification';
        final body = message.notification?.body ?? message.data['body'] ?? '';
        final name = message.data['name'] ?? '';

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

        const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

        // நோட்டிஃபிகேஷன் காண்பிக்கப்படுகிறது
        await flutterLocalNotificationsPlugin.show(
          message.hashCode,
          body,
         // title,
          "Created by $name .Task",
          platformDetails,
          payload: jsonEncode(message.data), // payload சேர்க்கப்பட்டுள்ளது
        );
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification?.title
          ?.contains("task") ??
          false) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => ViewTask(date1: "${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}", date2: "${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}", type: "Today")),
        );
      }
    });
    /// BACKGROUND HANDLER
    FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler);
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
      ],
      child: MyApp(homeScreen: homeScreen),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool homeScreen;
  const MyApp({super.key,required this.homeScreen});
  @override
  Widget build(BuildContext context){
    return ConnectivityAppWrapper(
      app: MaterialApp(
          navigatorKey: navigatorKey,
          builder: (context, child){
            return ConnectivityWidgetWrapper(
                color: colorsConst.primary,
                message: "Check Your Internet Connection",
                disableInteraction: true,
                child:  MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: child!,
                )
            );
          },
          useInheritedMediaQuery: true,
          locale: const Locale('en','US'),
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
          home:SplashScreen(homeScreen: homeScreen,)
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
  // @override
  // void initState() {
  // checkForUpdates(context);
  // Future.delayed(Duration.zero, () {
  //   Provider.of<HomeProvider>(context, listen: false).checkVersion();
  //   Provider.of<LocationProvider>(context, listen: false).requestPermissions();
  //   Provider.of<HomeProvider>(context, listen: false).initValue();
  //   Provider.of<HomeProvider>(context, listen: false).roleEmployees();
  //   Provider.of<AttendanceProvider>(context, listen: false).getMainAttendance();
  //   Provider.of<HomeProvider>(context, listen: false).getMainReport(true);
  //   Provider.of<HomeProvider>(context, listen: false).getDashboardReport(true);
  // });

  //   super.initState();
  // }
  @override
  void initState() {
    super.initState();
    checkForUpdates(context); // runs immediately
    Future.delayed(Duration.zero, () {
      if (!mounted) return;

      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
      homeProvider.checkVersion();
      locationProvider.requestPermissions();
      homeProvider.initValue();
      // homeProvider.roleEmployees();
      attendanceProvider.getMainAttendance();
      homeProvider.checkThisMonth();
      homeProvider.getMainReport(true);
      homeProvider.getDashboardReport(true);
    });
  }

  checkForUpdates(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    storedVersion = prefs.getString('appVersion') ?? "0";
    currentVersion = localData.versionNumber;
    if (storedVersion != currentVersion) {
      print("1 ${storedVersion != currentVersion}");
      utils.navigatePage(context, ()=>const LoginPage());
    } else if(widget.homeScreen){
      print("2 ${storedVersion != currentVersion}");
      utils.navigatePage(context, ()=> DashBoard(child: HomePage(),));
    }else {
      print("3 ${storedVersion != currentVersion}");
      utils.navigatePage(context, ()=>const LoginPage());
    }
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 300,
      splashIconSize: 800,
      splashTransition: SplashTransition.fadeTransition,
      splash:Container(
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
            // CustomText(text: Provider.of<HomeProvider>(context, listen: false).appComponent[0]["app_name"],colors: colorsConst.primary,size: 20,isBold: true,),
            CustomText(text:"${constValue.comName}\n",size: 15,colors: colorsConst.primary,),
          ],
        ),
      ),
      nextScreen: storedVersion != currentVersion?const LoginPage():widget.homeScreen?const DashBoard(child: HomePage()):const LoginPage(),
      // nextScreen: const DashBoard(),
    );
  }
}
