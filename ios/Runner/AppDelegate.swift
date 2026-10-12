import UIKit
import Flutter
import GoogleMaps
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    UNUserNotificationCenter.current().delegate = self

    GMSServices.provideAPIKey("AIzaSyArxx0GjaHpFfFADRN-Xv0Kwwz4OxUuSLA")
    GeneratedPluginRegistrant.register(with: self)

    // Launch aagum bodhu badge clear
    application.applicationIconBadgeNumber = 0

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // App foreground-ku varum bodhu badge clear
  override func applicationDidBecomeActive(_ application: UIApplication) {
    application.applicationIconBadgeNumber = 0
  }
}