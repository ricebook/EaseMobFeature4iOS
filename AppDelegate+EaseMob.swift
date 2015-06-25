//
//  AppDelegate+EaseMob.swift
//  EaseMobDemo
//
//  Created by wanglei on 15/6/17.
//  Copyright (c) 2015年 Ray. All rights reserved.
//

import Foundation

extension AppDelegate {
    
    func easemobApplication(application: UIApplication, didFinishLaunchingWithOptions launchOptions:[NSObject: AnyObject]?) {
        
        EaseMob.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        #if DEBUG
            EaseMob.sharedInstance().registerSDKWithAppKey(EMIMHelper.defaultHelper().appkey, apnsCertName: "ENJOY-Develop-APNS")
        #else
            EaseMob.sharedInstance().registerSDKWithAppKey(EMIMHelper.defaultHelper().appkey, apnsCertName: "ENJOY-Distribute-APNS")
        #endif
     
        EaseMob.sharedInstance().chatManager.removeDelegate(self)
        EaseMob.sharedInstance().chatManager.addDelegate(self, delegateQueue: nil)
        
        
        setUpNotifiers()
    }
    
    
    // MARK: - Private
    private func setUpNotifiers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidEnterBackgroundNotif:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWillEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidFinishLaunching:", name: UIApplicationDidFinishLaunchingNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidBecomeActiveNotif:", name: UIApplicationDidBecomeActiveNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWillResignActiveNotif:", name: UIApplicationWillResignActiveNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidReceiveMemoryWarning:", name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWillTerminateNotif:", name: UIApplicationWillTerminateNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appProtectedDataWillBecomeUnavailableNotif:", name: UIApplicationProtectedDataWillBecomeUnavailable, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appProtectedDataDidBecomeAvailableNotif:", name: UIApplicationProtectedDataDidBecomeAvailable, object: nil)
        
    }
    
    func appDidEnterBackgroundNotif(notification: NSNotification) {
        if let application = notification.object as? UIApplication {
            EaseMob.sharedInstance().applicationDidEnterBackground(application)
        }
        
    }
    func appWillEnterForeground(notification: NSNotification) {
        if let application = notification.object as? UIApplication {
            EaseMob.sharedInstance().applicationWillEnterForeground(application)
        }
    }

    func appDidFinishLaunching(notification: NSNotification) {
        if let application = notification.object as? UIApplication {
            EaseMob.sharedInstance().applicationDidFinishLaunching(application)
        }
    }

    func appDidBecomeActiveNotif(notification: NSNotification) {
        if let application = notification.object as? UIApplication {
            EaseMob.sharedInstance().applicationDidBecomeActive(application)
        }
    }

    func appWillResignActiveNotif(notification: NSNotification) {
        if let application = notification.object as? UIApplication {
            EaseMob.sharedInstance().applicationWillResignActive(application)
        }
    }

    func appDidReceiveMemoryWarning(notification: NSNotification) {
        if let application = notification.object as? UIApplication {
            EaseMob.sharedInstance().applicationDidReceiveMemoryWarning(application)
        }
    }

    func appWillTerminateNotif(notification: NSNotification) {
        if let application = notification.object as? UIApplication {
            EaseMob.sharedInstance().applicationWillTerminate(application)
        }
    }

    func appProtectedDataWillBecomeUnavailableNotif(notification: NSNotification) {
        if let application = notification.object as? UIApplication {
            EaseMob.sharedInstance().applicationProtectedDataWillBecomeUnavailable(application)
        }
    }

    func appProtectedDataDidBecomeAvailableNotif(notification: NSNotification) {
        if let application = notification.object as? UIApplication {
            EaseMob.sharedInstance().applicationProtectedDataDidBecomeAvailable(application)
        }
    }

    func didReceiveMessage(message: EMMessage!) {
        if UIApplication.sharedApplication().applicationState == .Active {
            // TODO: App在活动中(运行中)如何给提示？ play sound? or other?
            
        }else {
            // Local Notification
            self.p_showLocalNotificationWithMessage(message)
        }
       
    }
    
    private func p_showLocalNotificationWithMessage(message: EMMessage) {
        let options = EaseMob.sharedInstance().chatManager.pushNotificationOptions
        let localNotification = UILocalNotification()
        localNotification.fireDate = NSDate()
        
        var messageStr: String = ""
        
        if options.displayStyle == .ePushNotificationDisplayStyle_messageSummary {
            if let messageBody = message.messageBodies.first as? IEMMessageBody {
                switch messageBody.messageBodyType {
                case .eMessageBodyType_Text:
                    if let textMessageBody = messageBody as? EMTextMessageBody {
                        messageStr = textMessageBody.text
                    }
                case .eMessageBodyType_Image:
                    messageStr = "图片"
                default:
                    break
                }
            }
            localNotification.alertBody = "ENJOY在线客服:\(messageStr)"
        }else {
            localNotification.alertBody = "ENJOY客服回复了您一条新消息"
        }
        
        localNotification.alertAction = "打开"

        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        //发送通知
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
}