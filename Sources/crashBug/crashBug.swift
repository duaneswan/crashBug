////
//
//
//   	### dTechInternal File Header Information ###
//
//	UUID:				A2138B1D-20D2-4B82-8661-B691844E9F92
//	File Name:			crashBug.swift
//	Production Name:		crashBug
//	File Creation Date:		9/19/24
//	Modification:			2024:D-Unit
//	Copyright:			TM and © D-Tech Media Creations, Inc. All Rights Reserved.
//
//  	### dTechInternal File Header Information ###
//
//
//


import UIKit
import UserNotifications

class crashBug: NSObject {
    // Property to check if crashBug is enabled
    var isEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "crashBugEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "crashBugEnabled")
        }
    }
    
    // Singleton instance
    static let shared = crashBug()
    private var latestCrashLog: String?
    
    private override init() {
        super.init()
        requestNotificationPermissions()
        if isEnabled {
            startMonitoring()
        }
    }
    
    // Start monitoring for app crashes
    func startMonitoring() {
        NSSetUncaughtExceptionHandler { exception in
            crashBug.handleException(exception: exception)
        }
        
        // Set up signal handlers for common signals
        crashBug.setupSignalHandler()
    }
    
    // Create static C-compatible functions
    private static func setupSignalHandler() {
        signal(SIGABRT, crashSignalHandler)
        signal(SIGILL, crashSignalHandler)
        signal(SIGSEGV, crashSignalHandler)
        signal(SIGFPE, crashSignalHandler)
        signal(SIGBUS, crashSignalHandler)
        signal(SIGPIPE, crashSignalHandler)
    }
    
    // C-compatible signal handler
    private static let crashSignalHandler: @convention(c) (Int32) -> Void = { signal in
        crashBug.handleSignal(signal)
    }
    
    // Handle uncaught exceptions
    private static func handleException(exception: NSException) {
        let crashLog = crashBug.shared.createLog(for: exception)
        crashBug.shared.saveCrashLog(crashLog)
        crashBug.shared.displayCrashNotification(with: crashLog)
    }
    
    // Handle signal-based crashes
    private static func handleSignal(_ signal: Int32) {
        var crashInfo = "App received signal: \(signal)\n"
        crashInfo += "Call stack:\n"
        crashInfo += Thread.callStackSymbols.joined(separator: "\n")
        crashBug.shared.saveCrashLog(crashInfo)
        crashBug.shared.displayCrashNotification(with: crashInfo)
    }
    
    // Create a log for the given exception
    private func createLog(for exception: NSException) -> String {
        var log = "App Crash Log\n"
        log += "====================\n"
        log += "Human Readable Section\n"
        log += "====================\n"
        log += "Crash Reason: \(exception.reason ?? "Unknown")\n"
        log += "Crash Location: \(exception.callStackSymbols.first ?? "Unknown")\n"
        log += "Crash Time: \(Date())\n"
        log += "====================\n"
        log += "Advanced Information\n"
        log += "====================\n"
        log += "Call Stack:\n"
        log += exception.callStackSymbols.joined(separator: "\n")
        
        return log
    }
    
    // Save the crash log to a file
    private func saveCrashLog(_ log: String) {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let logFilePath = documentsPath.appendingPathComponent("CrashLog_\(Date()).txt")
        
        do {
            try log.write(to: logFilePath, atomically: true, encoding: .utf8)
            print("Crash log saved at: \(logFilePath)")
            latestCrashLog = log
        } catch {
            print("Failed to save crash log: \(error)")
        }
    }
    
    // Request notification permissions
    private func requestNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    // Display crash notification with summary
    private func displayCrashNotification(with log: String) {
        let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "The App"
        let logSummary = log.split(separator: "\n").prefix(5).joined(separator: "\n") // Short summary of the crash log
        
        let content = UNMutableNotificationContent()
        content.title = "\(appName) has crashed"
        content.body = "Summary:\n\(logSummary)"
        content.sound = UNNotificationSound.default
        content.userInfo = ["crashLog": log]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "crashBugNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to display notification: \(error)")
            }
        }
        
        // Handle notification tap
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Test crash function
    func testCrash(after duration: TimeInterval, reason: String, shouldGenerateLog: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            if shouldGenerateLog {
                let exception = NSException(name: .genericException, reason: reason, userInfo: nil)
                crashBug.handleException(exception: exception)
            }
            fatalError(reason) // This will crash the app
        }
    }
}

// Extend crashBug to conform to UNUserNotificationCenterDelegate
extension crashBug: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "crashBugNotification",
           let log = response.notification.request.content.userInfo["crashLog"] as? String {
            displayCrashLog(log)
        }
        completionHandler()
    }
    
    // Display the log file within the app (a simple implementation)
    private func displayCrashLog(_ log: String) {
        let alert = UIAlertController(title: "Crash Log", message: log, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.present(alert, animated: true, completion: nil)
        }
    }
}
