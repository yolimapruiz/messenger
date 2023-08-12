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
    
  //  Settings.shared.appID

//    ApplicationDelegate.shared.application(
//        application,
//        didFinishLaunchingWithOptions: launchOptions
//    )

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
}
}

