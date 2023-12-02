//
//  AppDelegate.swift
//  Notes
//
//  Created by JoyDev on 14.11.2023.
//

import UIKit
import SnapKit

@main

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let viewModel = ViewModel()
        let viewController = ViewController(viewModel: viewModel)
        let navController = UINavigationController()
        navController.setViewControllers([viewController], animated: true)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        
        return true
    }
    
}

