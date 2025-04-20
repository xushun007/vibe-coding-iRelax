//
//  ContentView.swift
//  iRelax
//
//  Created by zoe on 2025/4/19.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var timerModel = TimerModel()
    @State private var selectedTab = 0
    
    var body: some View {
        // 使用 ZStack 来允许覆盖层
        ZStack {
            TabView(selection: $selectedTab) {
                // 计时器视图
                TimerView(timerModel: timerModel)
                    .tabItem {
                        Label("休息", systemImage: "moon.fill")
                    }
                    .tag(0)
                
                // 设置视图
                SettingsView(timerModel: timerModel)
                    .tabItem {
                        Label("设置", systemImage: "gear")
                    }
                    .tag(1)
            }
            
            // 如果需要显示休息屏幕，则覆盖在 TabView 之上
            if timerModel.showRestScreen {
                // 从 TimerView 引入 RestScreenView (需要确保 RestScreenView 可访问)
                RestScreenView(timerModel: timerModel, restPromptText: UserDefaults.standard.string(forKey: "restPromptText") ?? "请眺望远方")
                    .zIndex(1) // 确保它在 TabView 之上
            }
        }
        .onChange(of: timerModel.timerState) { newState in
            // 当状态变更时切换到主视图以便查看当前状态
            if newState == .idle || newState == .working {
                withAnimation {
                    selectedTab = 0
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
