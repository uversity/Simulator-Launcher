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
    case DeviceName = "DeviceName"
    case iOSVersion = "iOSVersion"
}

class LauncherViewController: NSViewController {
    
    @IBOutlet weak var appLabel: NSTextField!
    
    var appInfo: AppInfo? {
        didSet {
            if let info = appInfo {
                appLabel.stringValue = "\(info.name) \(info.version)"
                launchButton.enabled = true
            } else {
                appLabel.stringValue = ""
                launchButton.enabled = false
            }
        }
    }
    
    @IBOutlet weak var devicePopUp: NSPopUpButton!
    
    @IBOutlet weak var iOSPopUp: NSPopUpButton!
    
    @IBOutlet weak var launchButton: NSButton!
    
    var devices = [Device]()
    
    let defaultDeviceTitle = "iPhone 6"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        launchButton.enabled = false
        devicePopUp.removeAllItems()
        iOSPopUp.removeAllItems()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "launcherViewReceivedDraggedPath:", name: LauncherViewReceivedDraggedPathNotification, object: view)
        
        SimulatorLauncher.loadDevices { devices in
            if let devices = devices {
                self.devicesLoaded(devices)
            } else {
                self.deviceLoadingFailed()
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func loadLastLaunchInfo() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let path = defaults.objectForKey(DefaultsKeys.AppPath.rawValue) as? String {
            self.appInfo = AppInfo(path: path)
        }
        
        let savedDeviceTitle = defaults.objectForKey(DefaultsKeys.DeviceName.rawValue) as? String
        let deviceTitle = savedDeviceTitle ?? defaultDeviceTitle
        let index = devicePopUp.indexOfItemWithTitle(deviceTitle)
        if index != -1 {
            devicePopUp.selectItemAtIndex(index)
        }
        
        updateiOSPopUp()
    }
    
    func saveLaunchInfo() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(appInfo?.path, forKey: DefaultsKeys.AppPath.rawValue)
        defaults.setObject(devicePopUp.titleOfSelectedItem, forKey: DefaultsKeys.DeviceName.rawValue)
        defaults.setObject(iOSPopUp.titleOfSelectedItem, forKey: DefaultsKeys.iOSVersion.rawValue)
        
        defaults.synchronize()
    }
    
    func updateiOSPopUp() {
        var iOSVersion = iOSPopUp.titleOfSelectedItem
        iOSPopUp.removeAllItems()
        
        let selectedDeviceIndex = devicePopUp.indexOfSelectedItem
        if selectedDeviceIndex == -1 {
            return
        }
        
        let device = devices[selectedDeviceIndex]
        iOSPopUp.addItemsWithTitles(device.supportediOSVersions)
        
        if iOSVersion == nil {
            NSUserDefaults.standardUserDefaults().objectForKey(DefaultsKeys.iOSVersion.rawValue) as? String
        }
        
        if let version = iOSVersion {
            let index = iOSPopUp.indexOfItemWithTitle(version)
            if index != -1 {
                iOSPopUp.selectItemAtIndex(index)
                return
            }
        }
        
        iOSPopUp.selectItemAtIndex(iOSPopUp.numberOfItems - 1)
    }

    @IBAction func deviceSelected(sender: NSPopUpButton) {
        updateiOSPopUp()
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
                if let appInfo = AppInfo(path: path) {
                    self.appInfo = appInfo
                } else {
                    displayInvalidAppAlert()
                }
            }
        }
    }
    
    @IBAction func launchClicked(sender: NSButton) {
        if let appInfo = appInfo {
            self.appInfo = AppInfo(path: appInfo.path)
            if let updatedInfo = self.appInfo {
                let device = devices[devicePopUp.indexOfSelectedItem]
                let iOSVersion = iOSPopUp.titleOfSelectedItem!
                SimulatorLauncher.launch(info: updatedInfo, device: device, iOSVersion: iOSVersion)
                saveLaunchInfo()
            } else {
                displayInvalidPathAlert()
            }
        }
    }
    
    func devicesLoaded(devices: [Device]) {
        self.devices = devices
        
        devicePopUp.removeAllItems()
        devicePopUp.addItemsWithTitles(devices.map { $0.name })
        
        loadLastLaunchInfo()
    }
    
    func deviceLoadingFailed() {
        let description = "Open Xcode, select \"Window\", then \"Devices\". In the Devices window, " +
        "if there is no \"Simulator\" section (or if it exists but contains no devices), click the " +
        "plus icon in the bottom left of the window, and choose the device you would like to add. " +
        "After adding a device, relaunch this app."
        
        displayAlert(message: "Simulator Device Loading Failed", description: description) {
            _ in NSApplication.sharedApplication().terminate(self)
        }
    }
    
    func launcherViewReceivedDraggedPath(notification: NSNotification) {
        if let path = notification.userInfo?["path"] as? String {
            if let appInfo = AppInfo(path: path) {
                self.appInfo = appInfo
            }
        }
    }
    
    func displayInvalidAppAlert() {
        displayAlert(message: "Invalid App", description: "The App you selected does not run on the iOS Simulator.")
    }
    
    func displayInvalidPathAlert() {
        displayAlert(message: "Invalid App Location", description: "The location of the App you specified is no longer valid.")
    }
    
    func displayAlert(#message: String, description: String, completion: ((NSModalResponse) -> Void)? = nil) {
        let alert = NSAlert()
        alert.addButtonWithTitle("Dismiss")
        alert.messageText = message
        alert.informativeText = description
        
        if let window = view.window {
            alert.beginSheetModalForWindow(window, completionHandler: completion)
        }
    }

}

