//
//  Devices.swift
//  SimulatorLauncher
//
//  Created by Daniel Resnick on 9/26/14.
//  Copyright (c) 2014 Daniel Resnick. All rights reserved.
//

enum Device: String {
    case iPhone4s = "com.apple.CoreSimulator.SimDeviceType.iPhone-4s"
    case iPhone5 = "com.apple.CoreSimulator.SimDeviceType.iPhone-5"
    case iPhone5s = "com.apple.CoreSimulator.SimDeviceType.iPhone-5s"
    case iPhone6 = "com.apple.CoreSimulator.SimDeviceType.iPhone-6"
    case iPhone6Plus = "com.apple.CoreSimulator.SimDeviceType.iPhone-6-Plus"
    case iPad2 = "com.apple.CoreSimulator.SimDeviceType.iPad-2"
    case iPadRetina = "com.apple.CoreSimulator.SimDeviceType.iPad-Retina"
    case iPadAir = "com.apple.CoreSimulator.SimDeviceType.iPad-Air"
    case ResizableiPhone = "com.apple.CoreSimulator.SimDeviceType.Resizable-iPhone"
    case ResizeableiPad = "com.apple.CoreSimulator.SimDeviceType.Resizable-iPad"
    
    var displayName: String {
        if let nameComponents = rawValue.componentsSeparatedByString(".").last?.componentsSeparatedByString("-") {
            return " ".join(nameComponents)
        }
        
        return ""
    }
}