//
//  AppDelegate.swift
//  SilentMode
//
//  Created by Arvind on 2/2/26.
//

import Cocoa
import CoreAudio

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let menu = NSMenu()
    var originalAlertVolume: Float32 = 1
    var isSilentMode = false
    // let audioManager = AudioManager()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        setOriginalAlertVolume()
        updateIcon()
        setupMenu()
    }
    
    func setOriginalAlertVolume() {
        var volume: Float32 = 0
        let status = SSVLGetSystemVolume(&volume)
        // Set original volume to volume variable, otherwise keep it at the default of 1
        if status == noErr {
            print("Original alert volume is: \(volume)")
            originalAlertVolume = volume
        }
    }
    
    func updateIcon() {
        let symbolName = isSilentMode ? "bell.slash.fill" : "bell.fill"
        let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Silent Mode")
        image?.isTemplate = true // Not sure if we need this
        statusItem.button?.image = image
    }
    
    func setupMenu() {
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "")
        menu.addItem(quitItem)
        
        statusItem.button?.action = #selector(statusItemClicked)
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
    
    @objc func quit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(nil)
    }
    
    @objc func statusItemClicked() {
        guard let event = NSApp.currentEvent else { return }
        
        // Show menu when right clicking, otherwise toggle alert volume
        if event.type == .rightMouseUp {
            print("Right click")
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            print("Left click")
            toggleSilentMode()
        }
    }
    
    func toggleSilentMode() {
        if isSilentMode {
            // Restore original alert volume
            let status = SSVLSetSystemVolume(originalAlertVolume)
            if status == noErr {
                isSilentMode = false
                print("Restored alert volume")
                updateIcon()
            }
        } else {
            // Set alert volume to 0
            let status = SSVLSetSystemVolume(0.000000 as Float32)
            if status == noErr {
                isSilentMode = true
                print("Muted alert volume")
                updateIcon()
            } else {
                print("Failed to set silent mode: \(status)")
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}
