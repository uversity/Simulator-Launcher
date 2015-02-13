//
//  Device.swift
//  Simulator Launcher
//
//  Created by Daniel Resnick on 9/26/14.
//  Copyright (c) 2014 Uversity. All rights reserved.
//

import Cocoa

class Device {
    
    let id: String
    
    var supportediOSVersions = [String]()
    
    let name: String
    
    init(id: String) {
        self.id = id
        
        if let dashedName = id.componentsSeparatedByString(".").last {
            self.name = " ".join(dashedName.componentsSeparatedByString("-"))
        } else {
            self.name = id
        }
    }
    
    convenience init(id: String, iOSVersion: String) {
        self.init(id: id)
        supportediOSVersions.append(iOSVersion)
    }
    
    class func processDeviceStrings(deviceStrings: [String]) -> [Device] {
        var devices: [String: Device] = [:]
        
        for deviceString in deviceStrings {
            let components = deviceString.componentsSeparatedByString(", ")
            if components.count == 2 {
                let deviceID = components[0]
                let iOSVersion = components[1]
                
                if let device = devices[deviceID] {
                    device.supportediOSVersions.append(iOSVersion)
                } else {
                    devices[deviceID] = Device(id: deviceID, iOSVersion: iOSVersion)
                }
            }
        }
        
        return sorted(devices.values) { $0.name.lowercaseString < $1.name.lowercaseString }
    }
    
}