//
//  AppDelegate.swift
//  AutoClicker
//
//  Created by Espen Wiborg on 2016-04-19.
//  Copyright © 2016 Espen Wiborg. All rights reserved.
//

import MASShortcut

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    @IBOutlet weak var preferencesWindow: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var shortcutView: MASShortcutView!

    @IBOutlet weak var intervalLabel: NSTextField!
    @IBOutlet weak var intervalSlider: NSSlider!
    
    var prefsActive: Bool = false
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    let shortcutKey = "GlobalShortcut"
    let intervalKey = "Interval"
    
    let defaults = NSUserDefaults.standardUserDefaults()

    @IBAction func intervalChanged(sender: NSSlider) {
        intervalLabel.stringValue = String(sender.intValue)
        defaults.setInteger(sender.integerValue, forKey: intervalKey)
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBAction func preferencesClicked(sender: NSMenuItem) {
        preferencesWindow.makeKeyAndOrderFront(self)
        NSApp.activateIgnoringOtherApps(true)
        prefsActive = true
    }
    
    func windowWillClose(notification: NSNotification) {
        prefsActive = false
    }
    
    func callback() {
        let skip = prefsActive && preferencesWindow.frame.contains(NSEvent.mouseLocation())
        
        if !skip {
            toggleClicking()
        }
    }
    
    var timer: NSTimer? = nil
    
    func toggleClicking() {
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(intervalSlider.doubleValue / 1000, target: self, selector: Selector("click"), userInfo: nil, repeats: true)
        } else {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func click() {
        let dummy = CGEventCreate(nil)
        let loc = CGEventGetLocation(dummy)
        
        let mouseDown = CGEventCreateMouseEvent(nil, CGEventType.LeftMouseDown, loc, CGMouseButton.Left)
        let mouseUp = CGEventCreateMouseEvent(nil, CGEventType.LeftMouseUp, loc, CGMouseButton.Left)
        CGEventPost(CGEventTapLocation.CGHIDEventTap, mouseDown)
        CGEventPost(CGEventTapLocation.CGHIDEventTap, mouseUp)
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItem.title = "AutoClicker"
        statusItem.menu = statusMenu
        shortcutView.associatedUserDefaultsKey = shortcutKey
        
        
        
        intervalSlider.integerValue = max(defaults.integerForKey(intervalKey), Int(intervalSlider.minValue))
        intervalChanged(intervalSlider)
        
        preferencesWindow.delegate = self
        preferencesWindow.level = Int(CGWindowLevelForKey(.FloatingWindowLevelKey))
        
        MASShortcutBinder.sharedBinder().bindShortcutWithDefaultsKey(shortcutKey, toAction: callback)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        MASShortcutMonitor.sharedMonitor().unregisterAllShortcuts()
    }
}

