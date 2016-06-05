//
//  ViewController.swift
//  MyTodoList
//
//  Created by Shiozawa Tomo on 2016/05/29.
//  Copyright © 2016年 Shiozawa Tomo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //ローカル通知用のやつ
    let notification = UILocalNotification()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // ユーザのpush通知許可をもらうための設定(おまじない)
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))

        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //ローカルプッシュの設定
        // 登録済みのスケジュールをすべてリセット
        application.cancelAllLocalNotifications()
        notification.alertBody = "タスクを確認しましょう！"
        notification.fireDate = NSDate(timeIntervalSinceNow: 3)
        notification.soundName = UILocalNotificationDefaultSoundName
        //アイコンバッジに1を表示
        notification.applicationIconBadgeNumber = 1
        
        //通知をスケージューリング
        application.scheduleLocalNotification(notification)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // バッジをリセット
        application.applicationIconBadgeNumber = 0
        // 通知領域からこの通知を削除
        application.cancelLocalNotification(notification)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

