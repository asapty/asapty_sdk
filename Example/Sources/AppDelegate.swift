//
//  ASAPTY.swift
//  ASAPTY
//
//  Created by Pavel Kuznetsov on 14.01.2022.
//

import UIKit
import ASAPTY_SDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        ASAPTY.shared.attribution(with: "18d607433")
        ASAPTY.shared.subscribeForInAppEvents()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: ViewController())
        window?.makeKeyAndVisible()
        
        return true
    }
}

