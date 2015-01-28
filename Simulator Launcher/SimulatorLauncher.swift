//
//  SimulatorLauncher.swift
//  Simulator Launcher
//
//  Created by Daniel Resnick on 11/6/14.
//  Copyright (c) 2014 Uversity. All rights reserved.
//

import Foundation

private var outputObserver: NSObjectProtocol? = nil

private let launchPath = NSBundle.mainBundle().pathForResource("ios-sim", ofType: nil)!

class SimulatorLauncher {
    
    class func launch(#info: AppInfo, device: Device, iOSVersion: String) {
        let deviceTypeID = "\(device.id), \(iOSVersion)"
        
        let arguments = ["launch", info.path, "--devicetypeid", deviceTypeID, "--exit"]
        NSTask.launchedTaskWithLaunchPath(launchPath, arguments: arguments)
    }
    
    class func loadDevices() {
        let task = NSTask()
        task.launchPath = launchPath
        task.arguments = ["showdevicetypes"]
        
        let outputPipe = NSPipe()
        outputPipe.fileHandleForReading.readToEndOfFileInBackgroundAndNotify()
        task.standardOutput = outputPipe
        
        outputObserver = NSNotificationCenter.defaultCenter().addObserverForName(NSFileHandleReadToEndOfFileCompletionNotification, object: outputPipe.fileHandleForReading, queue: nil) { notification in
            self.removeObserver()
            if let readData = notification.userInfo?[NSFileHandleNotificationDataItem]? as? NSData {
                if readData.bytes == nil {
                    NSNotificationCenter.defaultCenter().postNotificationName(DeviceLoadingFailedNotification, object: nil)
                    return
                }
                
                if let dataString = String(CString: UnsafePointer<CChar>(readData.bytes), encoding: NSUTF8StringEncoding) {
                    Device.processDeviceStrings(dataString.componentsSeparatedByString("\n"))
                }
            }
        }
        
        task.launch()
    }
    
    class func removeObserver() {
        if let observer = outputObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
            outputObserver = nil
        }
    }
    
}