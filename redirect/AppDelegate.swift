//
//  AppDelegate.swift
//  redirect
//
//  Created by Kyle Johnson on 1/2/17.
//  Copyright © 2017 Kyle Johnson. All rights reserved.
//

import UIKit
import FirebaseCore
import AVFoundation
import GoogleMobileAds
import AppTrackingTransparency

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    static var muteSounds = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
//        Chartboost.start(withAppId: "58d04c6d43150f43cb57adbc", appSignature: "0c1e786901976cd7612f61b78f7e65eff20c6252", delegate: self)
//        Chartboost.setDelegate(self)

        return true
    }
    
    // Called after a rewarded video has been viewed completely and user is eligible for reward.
    func didCompleteRewardedVideo(_ location: String!, withReward reward: Int32) {
        
        GameScene.isContinued = true
        ContinueScene.watchingVideo = false
        ContinueScene.rewardGiven = true
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
        
        if AVAudioSession.sharedInstance().isOtherAudioPlaying {
            GameViewController.MusicHelper.sharedHelper.audioPlayer?.volume = 0.0
            AppDelegate.muteSounds = true
        } else {
            GameViewController.MusicHelper.sharedHelper.audioPlayer?.volume = 1.0
            AppDelegate.muteSounds = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { (status) in
                    GADMobileAds.sharedInstance().start()
                }
            } else {
                GADMobileAds.sharedInstance().start()
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
