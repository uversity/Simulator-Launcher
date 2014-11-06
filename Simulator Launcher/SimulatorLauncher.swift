//
//  SimulatorLauncher.swift
//  Simulator Launcher
//
//  Created by Daniel Resnick on 11/6/14.
//  Copyright (c) 2014 Uversity. All rights reserved.
//

import Foundation

class SimulatorLauncher {
    
    class func launch(#info: AppInfo, device: Device) {
        let deviceTypeID = "\(device.rawValue), \(info.iOSVersion)"
        
        let arguments = ["launch", info.path, "--devicetypeid", deviceTypeID, "--exit"]
        let launchPath = NSBundle.mainBundle().pathForResource("ios-sim", ofType: nil)
        NSTask.launchedTaskWithLaunchPath(launchPath!, arguments: arguments)
    }
    
}