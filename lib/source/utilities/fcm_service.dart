import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmService {
  static bool _listening = false;

  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    // 1) Permission (iOS la mandatory)
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint("FCM permission: ${settings.authorizationStatus}");

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint("FCM: user notification permission deny pannirukkaar");
      return;
    }

    // 2) iOS foreground la banner kaattanum na
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3) iOS: APNs token vandha aprom thaan FCM token varum
    if (Platform.isIOS) {
      String? apns;
      for (int i = 0; i < 15 && apns == null; i++) {
        apns = await messaging.getAPNSToken();
        if (apns == null) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
      debugPrint("APNs token: $apns");

      if (apns == null) {
        debugPrint("APNs token null -> Xcode capabilities / APNs key / "
            "real device check pannunga");
      }
    }

    // 4) FCM token eduthu server-ku anuppu
    final token = await messaging.getToken();
    debugPrint("FCM token: $token");
    if (token != null) {
      await _saveTokenToServer(token);
    }

    // 5) Token maarina udane server-ku anuppu (idhu thaan mukkiyam)
    if (!_listening) {
      _listening = true;
      messaging.onTokenRefresh.listen((newToken) async {
        debugPrint("FCM token refreshed: $newToken");
        await _saveTokenToServer(newToken);
      });
    }
  }

  static Future<void> clear() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint("FCM clear error: $e");
    }
  }
  static Future<void> _saveTokenToServer(String token) async {
    try {
      final platform = Platform.isIOS ? "ios" : "android";

      // TODO: unga API call inga:
      // await empRepo.updateToken({
      //   "action": updateTokenAction,
      //   "user_id": localData.storage.read("id").toString(),
      //   "token": token,
      //   "platform": platform,
      // });

      debugPrint("Token saved to server ($platform): $token");
    } catch (e) {
      debugPrint("Token save error: $e");
    }
  }
}