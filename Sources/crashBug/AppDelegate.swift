////
//
//
//   	### dTechInternal File Header Information ###
//
//	UUID:				3F7BB5EA-17CA-4065-ABB8-86EB84DDCBA3
//	File Name:			AppDelegate.swift
//	Production Name:		
//	File Creation Date:		9/19/24
//	Modification:			2024:D-Unit
//	Copyright:			TM and © D-Tech Media Creations, Inc. All Rights Reserved.
//
//  	### dTechInternal File Header Information ###
//
//
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        crashBug.shared.startMonitoring()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }



    lazy var persistentContainer: NSPersistentCloudKitContainer = {

        let container = NSPersistentCloudKitContainer(name: "crashBug")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

            }
        })
        return container
    }()



    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError

            }
        }
    }

}

