//
//  AppDelegate.swift
//  GridRace
//
//  Created by Christian on 2/26/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let formatter = DateFormatter()
    let timerView = TimerView()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //set up date formatter
        formatter.dateFormat = "HH:mm:ss"
        
        //create date if first time launching
        if !UserDefaults.standard.bool(forKey: "HasLaunchedOnce") {
            UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
            //add date object to user defaults
            UserDefaults.standard.set(Date(), forKey: "FirstLaunchDate")
        }
        
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
            let interval = Date().timeIntervalSince(AppResources.firstLaunchDate)
            
            let ti = NSInteger(interval)
            
            let seconds = ti % 60
            let minutes = (ti / 60) % 60
            let hours = ti / 3600
            
            AppResources.timeToDisplay = NSString(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds) as String
            self.timerView.timeLabel.text = AppResources.timeToDisplay
            print(AppResources.timeToDisplay)
        })
        
        //firebase setup
        FirebaseApp.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        
        
        let mainTabController = UITabBarController()
        
        mainTabController.tabBar.barTintColor = AppColors.backgroundColor
        mainTabController.tabBar.tintColor = AppColors.textPrimaryColor

        mainTabController.viewControllers = [UINavigationController(rootViewController: ObjectiveTableViewController(title: "Places", tabBarImage: #imageLiteral(resourceName: "directional_arrow"), dataCategory: ObjectiveCategory(rawValue: "places"))), UINavigationController(rootViewController: ObjectiveTableViewController(title: "Bonus", tabBarImage: #imageLiteral(resourceName: "clock_outline"), dataCategory: ObjectiveCategory(rawValue: "bonus")))]
        
        window?.rootViewController = mainTabController
        
        
        //global styling
        UINavigationBar.appearance().barTintColor = AppColors.backgroundColor
        UINavigationBar.appearance().tintColor = AppColors.textPrimaryColor
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : AppColors.greenHighlightColor]
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : AppColors.greenHighlightColor]
        UITabBar.appearance().tintColor = AppColors.greenHighlightColor
        
        window?.makeKeyAndVisible()
        
        addTimerToWindow(heightFromBottom: mainTabController.tabBar.bounds.height)
    
       
        
        return true
    }



    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func addTimerToWindow(heightFromBottom height: CGFloat) {
        window?.addSubview(timerView)
        
        timerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timerView.leadingAnchor.constraint(equalTo: (window?.leadingAnchor)!),
            timerView.trailingAnchor.constraint(equalTo: (window?.trailingAnchor)!),
            timerView.bottomAnchor.constraint(equalTo: (window?.bottomAnchor)!, constant: -height),
            timerView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}


enum ObjectiveCategory: String {
    case places
    case bonus
    
    init(rawValue: String) {
        switch rawValue {
        case "places":
            self = .places
        case "bonus":
            self = .bonus
        default:
            self = .places
        }
    }
}

