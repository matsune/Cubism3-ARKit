//
//  AppDelegate.swift
//  Cubism3-ARKit
//
//  Created by Yuma Matsune on 2018/08/18.
//  Copyright © 2018 matsune. All rights reserved.
//

import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var mainVC: MainViewController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? MainViewController else {
            fatalError()
        }
    
        mainVC = vc
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        Cubism3Allocator.startUp()
        vc.setupCubism() // call after startUp cubism
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        mainVC?.isOpenGLRun = false
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        mainVC?.isOpenGLRun = true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        mainVC?.isOpenGLRun = false
        Cubism3Allocator.dispose()
    }
}
