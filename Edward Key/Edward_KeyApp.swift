//
//  Edward_KeyApp.swift
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

import SwiftUI

@main
struct Edward_KeyApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
//    @StateObject var model = AppModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(AppModel.shared)
                .fixedSize()
                .onAppear {
                    appDelegate.model = AppModel.shared
                    appDelegate.setupStatusBarMenu()
                }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
    }
}
