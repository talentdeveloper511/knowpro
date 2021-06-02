//
//  AppDelegate.swift
//  KnowPro
//
//  Created by John Gabelmann on 5/20/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit
import BuddyBuildSDK
import RealmSwift
import Firebase
import OneSignal
import Flurry_iOS_SDK
import SafariServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var selectedArticle: KPArticle?
    private var timeStartedViewing = Date()
    private var openedNotification = false

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        BuddyBuildSDK.setup()
        
        #if DEVELOPMENT
        Realm.Configuration.defaultConfiguration = Realm.Configuration(schemaVersion: 0,
                                                                       deleteRealmIfMigrationNeeded: true)
        #else
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 0,
            migrationBlock: { (_, _) in
        })
        #endif
        
        FirebaseApp.configure()
        
        #if DEVELOPMENT
        Flurry.startSession("BF3V48RSJ3F75RC9FPMJ", with: FlurrySessionBuilder
            .init()
            .withCrashReporting(false)
            .withLogLevel(FlurryLogLevelAll))
        #else
        Flurry.startSession("XKDHJSZTW55336PSQ3DB", with: FlurrySessionBuilder
            .init()
            .withCrashReporting(false)
            .withLogLevel(FlurryLogLevelAll))
        #endif
        
        KPContentfulStore.sharedStore.sync {
            // If we're doing the first sync we have no ads to display, we set our timer to start here.
            if UserDefaults.standard.object(forKey: KPConstants.Defaults.LastFullScreenAd) as? Date == nil {
                UserDefaults.standard.set(Date(), forKey: KPConstants.Defaults.LastFullScreenAd)
            }
        }
        
        configureNotifications(launchOptions)
        
        KPAppearanceProxies.configureAppearanceProxies()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        configureRootViewController()
        window?.makeKeyAndVisible()
        
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
        if let topController = UIApplication.shared.topController() as? UINavigationController,
            let firstController = topController.viewControllers.first,
            firstController is KPOnboardingViewController {
            return
        }
        
        Auth.auth().currentUser?.syncPushTags(nil)
        
        /*if let lastFullScreenAd = UserDefaults.standard.object(forKey:
            KPConstants.Defaults.LastFullScreenAd) as? Date,
            lastFullScreenAd.minutesAgo >= 5 {
            UserDefaults.standard.set(Date(), forKey: KPConstants.Defaults.LastFullScreenAd)
            if !(UIApplication.shared.topController() is KPFullScreenAdViewController)
                && !(UIApplication.shared.topController() is SFSafariViewController &&
                    !openedNotification) {
                let advertisementViewController = UIStoryboard(name: "Main", bundle: Bundle.main)
                    .instantiateViewController(withIdentifier: "KPFullScreenAdViewController")
                advertisementViewController.modalTransitionStyle = .crossDissolve
                UIApplication.shared.topController()?
                    .present(advertisementViewController, animated: true, completion: nil)
            }
        }*/
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        KPContentfulStore.sharedStore.sync {
            completionHandler(.newData)
        }
    }
    
    // MARK: - Private Methods
    
    private func configureRootViewController() {
        if Auth.auth().currentUser != nil &&
            UserDefaults.standard.bool(forKey: KPConstants.Defaults.OnboardingComplete) {
            window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main)
                .instantiateInitialViewController()
        } else if Auth.auth().currentUser == nil ||
            !UserDefaults.standard.bool(forKey: KPConstants.Defaults.OnboardingComplete) {
            try? Auth.auth().signOut()
            window?.rootViewController = UIStoryboard(name: "SignUpLogin", bundle: Bundle.main)
                .instantiateInitialViewController()
        } else {
            if let rootController = UIStoryboard(name: "SignUpLogin", bundle: Bundle.main)
                .instantiateInitialViewController() as? UINavigationController,
                let firstController = rootController.viewControllers.first,
                let onboardingController = UIStoryboard(name: "SignUpLogin", bundle: Bundle.main)
                    .instantiateViewController(withIdentifier: "KPSignUpViewController") as? KPSignUpViewController {
                rootController.setViewControllers([firstController, onboardingController], animated: false)
                
                window?.rootViewController = rootController
            }
        }
    }
    
    private func configureNotifications(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload = result!.notification.payload
            self.openedNotification = true
            KPContentfulStore.sharedStore.sync({
                if let additionalData = payload.additionalData, let contentId = additionalData["contentId"] as? String {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                        do {
                            let realm = try Realm()
                            if let article = realm.objects(KPArticle.self)
                                .filter(NSPredicate(format: "id == %@", contentId)).first,
                                let url = URL(string: article.link ?? "") {
                                let safariViewController = SFSafariViewController(url: url)
                                
                                safariViewController.preferredBarTintColor =
                                    UIColor(named: KPConstants.Color.TabBarTint)
                                safariViewController.preferredControlTintColor =
                                    UIColor(named: KPConstants.Color.GlobalBlack)
                                
                                if let drug = article.drug, let primaryColor = drug.primaryColor {
                                    let hexColor = UIColor(hex: primaryColor)
                                    safariViewController.preferredControlTintColor = hexColor
                                } else if let company = article.author, let primaryColor = company.primaryColor {
                                    let hexColor = UIColor(hex: primaryColor)
                                    safariViewController.preferredControlTintColor = hexColor
                                }
                                
                                self.selectedArticle = article
                                self.timeStartedViewing = Date()
                                UIApplication.shared.topController()?.present(safariViewController,
                                                                              animated: true,
                                                                              completion: {
                                                                                self.openedNotification = false
                                })
                            }
                        } catch {
                            
                        }
                    })
                }
            })
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: KPConstants.OneSignal.AppID,
                                        handleNotificationAction: notificationOpenedBlock,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
    }

}

extension AppDelegate: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if let article = selectedArticle {
            KPImpressionStore.sharedStore.recordView(article.id,
                                                     article.title ?? "",
                                                     .article,
                                                     fabs(timeStartedViewing.timeIntervalSinceNow))
        }
    }
}
