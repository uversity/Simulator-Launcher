//
//  AppInfo.swift
//  Simulator Launcher
//
//  Created by Daniel Resnick on 11/6/14.
//  Copyright (c) 2014 Uversity. All rights reserved.
//

import Foundation

struct AppInfo {
    
    let path: String
    
    let name: String
    
    let version: String
    
    let iOSVersion: String
    
    init?(path: String) {
        let fileManager = NSFileManager.defaultManager()
        let plistPath = path.stringByAppendingPathComponent("Info.plist")
        
        if let plistURL = NSURL(fileURLWithPath: plistPath) {
            if let plist = NSDictionary(contentsOfURL: plistURL) {
                if let sdkName = plist["DTSDKName"] as? String {
                    let platformName = "iphonesimulator"
                    if sdkName.hasPrefix(platformName) {
                        self.path = path
                        self.name = plist["CFBundleName"] as? String ?? ""
                        self.version = plist["CFBundleShortVersionString"] as? String ?? ""
                        self.iOSVersion = sdkName.substringFromIndex(platformName.endIndex)
                        return
                    }
                }
            }
        }
        
        return nil
    }
    
}