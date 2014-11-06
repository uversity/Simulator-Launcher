//
//  ViewController.swift
//  Simulator Launcher
//
//  Created by Daniel Resnick on 10/31/14.
//  Copyright (c) 2014 Uversity. All rights reserved.
//

import Cocoa

enum DefaultsKeys: String {
    case AppPath = "AppPath"
    case Device = "Device"
}

class LauncherViewController: NSViewController {
    
    @IBOutlet weak var appLabel: NSTextField!
    
    var appPath: String? {
        didSet {
            if let path = appPath {
                appLabel.stringValue = path
                launchButton.enabled = true
            }
        }
    }
    
    var iOSVersion: String?
    
    @IBOutlet weak var devicePopUp: NSPopUpButton!
    
    @IBOutlet weak var launchButton: NSButton!
    
    let devices: [Device] = [.iPhone5s, .iPhone6, .iPadAir]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        launchButton.enabled = false
        devicePopUp.removeAllItems()
        devicePopUp.addItemsWithTitles(devices.map { $0.displayName } )
        
        loadLastLaunchInfo()
    }
    
    func loadLastLaunchInfo() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let path = defaults.objectForKey(DefaultsKeys.AppPath.rawValue) as String? {
            updateWithAppAtPath(path)
        }
        
        if let deviceTitle = defaults.objectForKey(DefaultsKeys.Device.rawValue) as? String {
            let index = devicePopUp.indexOfItemWithTitle(deviceTitle)
            if index >= 0 {
                devicePopUp.selectItemAtIndex(index)
            }
        }
    }
    
    func saveLaunchInfo() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(appPath, forKey: DefaultsKeys.AppPath.rawValue)
        defaults.setObject(devicePopUp.titleOfSelectedItem, forKey: DefaultsKeys.Device.rawValue)
        
        defaults.synchronize()
    }

    @IBAction func selectAppClicked(sender: NSButton) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["app"]
        
        let clicked = panel.runModal()
        
        if clicked == NSFileHandlingPanelOKButton {
            if let path = panel.URL?.path {
                if !updateWithAppAtPath(path) {
                    displayInvalidAppAlert()
                }
            }
        }
    }
    
    func updateWithAppAtPath(path: String) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        let plistPath = path.stringByAppendingPathComponent("Info.plist")
        
        if let plistURL = NSURL(fileURLWithPath: plistPath) {
            if let plist = NSDictionary(contentsOfURL: plistURL) {
                if let sdkName = plist["DTSDKName"] as? String {
                    let simulatorPrefix = "iphonesimulator"
                    if sdkName.hasPrefix(simulatorPrefix) {
                        appPath = path
                        iOSVersion = sdkName.substringFromIndex(simulatorPrefix.endIndex)
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    func displayInvalidAppAlert() {
        let alert = NSAlert()
        alert.addButtonWithTitle("Dismiss")
        alert.messageText = "Invalid App"
        alert.informativeText = "The App you selected does not run on the iOS Simulator."
        
        if let window = view.window {
            alert.beginSheetModalForWindow(window, completionHandler: nil)
        }
    }
    
    @IBAction func launchClicked(sender: NSButton) {
        if let path = appPath {
            let device = devices[devicePopUp.indexOfSelectedItem]
            SimulatorLauncher.launch(path: path, device: device, iOSVersion: iOSVersion)
            saveLaunchInfo()
        }
    }

}

