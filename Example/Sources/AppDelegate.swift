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
        
        ASAPTY.shared.attribution(withASAPTYToken: "641704c65")
        self.window?.rootViewController = ViewController()
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

