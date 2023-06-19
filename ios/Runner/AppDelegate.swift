import UIKit
// import Flutter
import GoogleMaps
import Firebase
@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
  override 
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if(FirebaseApp.app() == nil){
      FirebaseApp.configure()
    }
    GMSServices.provideAPIKey("Enter_Your_Map_Key")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}


