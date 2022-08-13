//
//  AppDelegate.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import UIKit
//import Bagel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
//    Bagel.start()
    
    let window = UIWindow(frame: UIScreen.main.bounds)
    
    let appCoordinator = AppCoordinator(window: window)
    appCoordinator.start()
    
    self.window = window
    window.makeKeyAndVisible()
    
    return true
  }
}

