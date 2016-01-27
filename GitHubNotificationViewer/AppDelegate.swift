//
//  AppDelegate.swift
//  GitHubNotificationViewer
//
//  Copyright © 2016 laiso. All rights reserved.
//

import UIKit
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if (url.host == "oauth-callback") {
            OAuthSwift.handleOpenURL(url)
        }
        return true
    }

}

