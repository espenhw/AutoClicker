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

    @IBOutlet weak var speedLabel: NSTextField!
    @IBOutlet weak var speedSlider: NSSlider!
    
    var prefsActive: Bool = false
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    let shortcutKey = "GlobalShortcut"
    let intervalKey = "Interval"
    
    let defaults = NSUserDefaults.standardUserDefaults()

    @IBAction func speedChanged(sender: NSSlider) {
        let clicksPerSecond = sender.integerValue
        speedLabel.stringValue = "\(clicksPerSecond) clicks/s"
        defaults.setInteger(1000 / clicksPerSecond, forKey: intervalKey)
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
            let interval = defaults.doubleForKey(intervalKey)
            timer = NSTimer.scheduledTimerWithTimeInterval(interval / 1000, target: self, selector: Selector("click"), userInfo: nil, repeats: true)
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
        
        defaults.registerDefaults([ intervalKey: 1000 ])
        
        let clicksPerSecond = 1000 / defaults.integerForKey(intervalKey)
        
        speedSlider.integerValue = max(clicksPerSecond, Int(speedSlider.minValue))
        speedChanged(speedSlider)
        
        preferencesWindow.delegate = self
        preferencesWindow.level = Int(CGWindowLevelForKey(.FloatingWindowLevelKey))
        
        MASShortcutBinder.sharedBinder().bindShortcutWithDefaultsKey(shortcutKey, toAction: callback)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        MASShortcutMonitor.sharedMonitor().unregisterAllShortcuts()
    }
}

