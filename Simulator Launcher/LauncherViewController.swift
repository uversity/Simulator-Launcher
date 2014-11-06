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
            self.appInfo = AppInfo(path: path)
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
        defaults.setObject(appInfo?.path, forKey: DefaultsKeys.AppPath.rawValue)
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
                SimulatorLauncher.launch(info: updatedInfo, device: device)
                saveLaunchInfo()
            } else {
                displayInvalidPathAlert()
            }
        }
    }
    
    func displayInvalidAppAlert() {
        displayAlert(message: "Invalid App", description: "The App you selected does not run on the iOS Simulator.")
    }
    
    func displayInvalidPathAlert() {
        displayAlert(message: "Invalid App Location", description: "The location of the App you specified is no longer valid.")
    }
    
    func displayAlert(#message: String, description: String) {
        let alert = NSAlert()
        alert.addButtonWithTitle("Dismiss")
        alert.messageText = message
        alert.informativeText = description
        
        if let window = view.window {
            alert.beginSheetModalForWindow(window, completionHandler: nil)
        }
    }

}

