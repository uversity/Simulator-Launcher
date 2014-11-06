//
//  ViewController.swift
//  Simulator Launcher
//
//  Created by Daniel Resnick on 10/31/14.
//  Copyright (c) 2014 Uversity. All rights reserved.
//

import Cocoa

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
    
    @IBOutlet weak var devicePopUp: NSPopUpButton!
    
    @IBOutlet weak var launchButton: NSButton!
    
    let devices: [Device] = [.iPhone5s, .iPhone6, .iPadAir]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        launchButton.enabled = false
        devicePopUp.removeAllItems()
        devicePopUp.addItemsWithTitles(devices.map { $0.displayName } )
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
                appPath = path
            }
        }
    }
    
    @IBAction func launchClicked(sender: NSButton) {
        if let path = appPath {
            let device = devices[devicePopUp.indexOfSelectedItem]
            launchSimulator(appPath: path, device: device)
        }
    }
    
    func launchSimulator(#appPath: String, device: Device) {
        let arguments = ["launch", appPath, "--devicetypeid", device.rawValue, "--exit"]
        let launchPath = NSBundle.mainBundle().pathForResource("ios-sim", ofType: nil)
        NSTask.launchedTaskWithLaunchPath(launchPath!, arguments: arguments)
    }

}

