//
//  LauncherView.swift
//  Simulator Launcher
//
//  Created by Daniel Resnick on 11/6/14.
//  Copyright (c) 2014 Uversity. All rights reserved.
//

import Cocoa

let LauncherViewReceivedDraggedPathNotification = "LauncherViewReceivedDraggedPathNotification"

class LauncherView: NSView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        registerForDraggedTypes([NSFilenamesPboardType])
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        if let path = pathForDrag(sender) {
            if AppInfo.isValidPath(path) {
                return NSDragOperation.Copy
            }
        }
        
        return NSDragOperation.None
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        if let path = pathForDrag(sender) {
            NSNotificationCenter.defaultCenter().postNotificationName(LauncherViewReceivedDraggedPathNotification, object: self, userInfo: ["path": path])
            return true
        }
        
        return false
    }
    
    func pathForDrag(sender: NSDraggingInfo) -> String? {
        return (sender.draggingPasteboard()?.propertyListForType(NSFilenamesPboardType)? as? [String])?.first
    }
    
}
