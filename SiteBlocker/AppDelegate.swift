//
//  AppDelegate.swift
//  SiteBlocker
//
//  Created by Chris Adams on 4/17/18.
//  Copyright © 2018 cadams. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if isFirstLaunch {
            firstLaunchInit()
        }
        updateBlockerList()

        let navigationController = self.window!.rootViewController! as! UINavigationController
        let tableViewController = navigationController.topViewController! as! TableViewController
        tableViewController.managedObjectContext = self.persistentContainer.viewContext
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        updateBlockerList()
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
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "SiteBlocker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error initializing persistent store \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Updating the content blocker JSON

    let jsonEntryTemplate = "{\"trigger\":{\"url-filter\":\"%@\"},\"action\":{\"type\":\"block\"}}"

    func updateBlockerList() {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        do {
            let entries = try persistentContainer.viewContext.fetch(fetchRequest)
            let json = "[\(entries.filter { $0.enabled }.map { String(format: jsonEntryTemplate, $0.url!) }.joined(separator: ","))]"
            let jsonURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.cadams.SiteBlocker")?.appendingPathComponent("BlockerList.json")

            try json.data(using: .utf8)?.write(to: jsonURL!, options: .atomic)
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

        SFContentBlockerManager.reloadContentBlocker(
        withIdentifier: "cadams.SiteBlocker.Blocker") {
            (e:Error?) in
            NSLog("Completed with \(String(describing: e)) for cadams.SiteBlocker.Blocker")
        }
    }

    // MARK: - First launch

    var isFirstLaunch: Bool = {
        let userDefaults = UserDefaults.standard
        let wasLaunchedBefore = userDefaults.bool(forKey: "SiteBlocker.WasLaunchedBefore")
        if !wasLaunchedBefore {
            userDefaults.set(true, forKey: "SiteBlocker.WasLaunchedBefore")
        }
        NSLog("isFirstLaunch: returning \(!wasLaunchedBefore)")
        return !wasLaunchedBefore
    }()

    func firstLaunchInit() {
        if let url = Bundle.main.url(forResource: "FirstLaunchURLs", withExtension: "plist") {
            let context = persistentContainer.viewContext
            do {
                let data = try Data(contentsOf: url)
                let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String:Any]
                let firstLaunchURLs = plistData["FirstLaunchURLs"] as! [String]
                let _ = firstLaunchURLs.map {
                    let entry = Entry(context: context)
                    entry.url = $0
                    entry.enabled = true
                }
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error configuring initial URLs \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

