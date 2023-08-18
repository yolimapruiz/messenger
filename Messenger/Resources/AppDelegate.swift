//
//  AppDelegate.swift
//  Messenger
//
//  Created by Yolima Pereira Ruiz on 10/07/23.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: NSObject, UIApplicationDelegate {
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    
    FirebaseApp.configure()
    
    FBSDKCoreKit.ApplicationDelegate.shared.application(
        application,
        didFinishLaunchingWithOptions: launchOptions
    )
    
    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
        if error != nil || user == nil {
          // Show the app's signed-out state.
        } else {
          // Show the app's signed-in state.
        }
      }
    return true
}
      
func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
) -> Bool {
    ApplicationDelegate.shared.application(
        app,
        open: url,
        sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
        annotation: options[UIApplication.OpenURLOptionsKey.annotation]
    )
    var handled: Bool

    handled = GIDSignIn.sharedInstance.handle(url)
    if handled {
      return true
    }

    return false
}
    
    
    
   func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {

    }
    
}

