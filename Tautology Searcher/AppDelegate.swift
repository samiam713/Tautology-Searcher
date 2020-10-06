//
//  AppDelegate.swift
//  Tautology Searcher
//
//  Created by Samuel Donovan on 9/20/20.
//

import Cocoa
import SwiftUI

var windowReference: NSWindow! = nil
func toView<T:View>(_ view: T) {
    windowReference.contentView = NSHostingView(rootView: view.frame(maxWidth: .infinity, maxHeight: .infinity))
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        
        let tautologySearcher = TautologySearcher(tautologies: tautologiesList)
        
        let contentView = TautologySearcherView(tautologySearcher: tautologySearcher)

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSScreen.main!.visibleFrame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        windowReference = window
        toView(contentView)
        window.makeKeyAndOrderFront(nil)
    
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        print("Application Terminating")
        let expressions = tautologiesList.map({$0.expression.toString()}).map({Expression(fromString: $0)})
        print(expressions.count)
    }

}

