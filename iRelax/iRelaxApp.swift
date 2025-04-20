//
//  iRelaxApp.swift
//  iRelax
//
//  Created by zoe on 2025/4/19.
//

import SwiftUI

@main
struct iRelaxApp: App {
    @StateObject private var timerModel = TimerModel()
    @AppStorage("showInMenuBar") private var showInMenuBar = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerModel)
                .onAppear {
                    // 初始加载时设置窗口大小
                    if let window = NSApplication.shared.windows.first {
                        window.setContentSize(NSSize(width: 380, height: 550))
                        window.center()
                    }
                }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            // 添加自定义菜单
            CommandGroup(replacing: .appSettings) {
                Button("偏好设置...") {
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
        
        // 添加菜单栏支持
        MenuBarExtra(showInMenuBar ? "iRelax" : "", systemImage: "timer") {
            Button("开始工作") {
                timerModel.startWorking()
            }
            .disabled(timerModel.timerState == .working)
            
            Button("开始休息") {
                timerModel.startResting()
            }
            .disabled(timerModel.timerState == .resting)
            
            Button(timerModel.isTimerRunning ? "暂停" : "继续") {
                if timerModel.isTimerRunning {
                    timerModel.pause()
                } else {
                    timerModel.resume()
                }
            }
            .disabled(timerModel.timerState == .idle)
            
            Button("重置") {
                timerModel.reset()
            }
            
            Divider()
            
            Button("退出") {
                NSApplication.shared.terminate(nil)
            }
        }
        .menuBarExtraStyle(.window)
    }
}
