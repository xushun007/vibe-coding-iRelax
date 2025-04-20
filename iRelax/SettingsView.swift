import SwiftUI

// 启动部分设置视图
struct LaunchSettingsView: View {
    @Binding var autoStartOnLaunch: Bool
    
    var body: some View {
        Section(header: Text("启动")) {
            Toggle("开机自动启动", isOn: $autoStartOnLaunch)
        }
    }
}

// 外观部分设置视图
struct AppearanceSettingsView: View {
    @Binding var appearanceStyle: String
    
    var body: some View {
        Section(header: Text("外观")) {
            HStack {
                Text("外观风格")
                Spacer()
                Picker("", selection: $appearanceStyle) {
                    Text("系统").tag("系统")
                    Text("浅色").tag("浅色")
                    Text("深色").tag("深色")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 100)
            }
        }
    }
}

// 通知部分设置视图
struct NotificationSettingsView: View {
    @Binding var notificationTime: Double
    @Binding var playSound: Bool
    
    var body: some View {
        Section(header: Text("通知")) {
            HStack {
                Text("休息前通知")
                Spacer()
                Picker("", selection: $notificationTime) {
                    Text("10秒").tag(10.0)
                    Text("20秒").tag(20.0)
                    Text("30秒").tag(30.0)
                    Text("1分钟").tag(60.0)
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 100)
            }
            
            Toggle("播放声音", isOn: $playSound)
        }
    }
}

// 屏幕部分设置视图
struct ScreenSettingsView: View {
    @Binding var pauseDuringScreenshare: Bool
    @Binding var resumeOnWake: Bool
    
    var body: some View {
        Section(header: Text("屏幕")) {
            Toggle("当镜像或共享屏幕时暂停休息", isOn: $pauseDuringScreenshare)
            
            HStack {
                Text("当唤醒或解锁屏幕时")
                Spacer()
                Picker("", selection: $resumeOnWake) {
                    Text("重新计时").tag(true)
                    Text("继续").tag(false)
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 100)
            }
        }
    }
}

// 菜单栏部分设置视图
struct MenuBarSettingsView: View {
    @Binding var showInMenuBar: Bool
    
    var body: some View {
        Section(header: Text("菜单栏")) {
            Toggle("在菜单栏显示计时", isOn: $showInMenuBar)
        }
    }
}

// 小憩部分设置视图
struct BreakSettingsView: View {
    @ObservedObject var timerModel: TimerModel
    @Binding var showCustomWorkTimeAlert: Bool
    @Binding var showCustomRestTimeAlert: Bool
    
    var body: some View {
        Section(header: Text("小憩")) {
            HStack {
                Text("工作时间")
                Spacer()
                Picker("", selection: $timerModel.workDuration) {
                    Text("20分钟").tag(20 * 60)
                    Text("25分钟").tag(25 * 60)
                    Text("30分钟").tag(30 * 60)
                    Text("45分钟").tag(45 * 60)
                    Text("60分钟").tag(60 * 60)
                    Text("自定义...").tag(-1)
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 100)
                .onChange(of: timerModel.workDuration) { newValue in
                    if newValue == -1 {
                        showCustomWorkTimeAlert = true
                        // 重置回之前的值，直到用户确认自定义时间
                        timerModel.workDuration = UserDefaults.standard.integer(forKey: "workDuration")
                        if timerModel.workDuration == 0 || timerModel.workDuration == -1 {
                            timerModel.workDuration = 20 * 60
                        }
                    } else {
                        timerModel.saveSettings()
                    }
                }
            }
            
            HStack {
                Text("小憩时间")
                Spacer()
                Picker("", selection: $timerModel.restDuration) {
                    Text("20秒").tag(20)
                    Text("30秒").tag(30)
                    Text("1分钟").tag(60)
                    Text("5分钟").tag(5 * 60)
                    Text("10分钟").tag(10 * 60)
                    Text("自定义...").tag(-1)
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 100)
                .onChange(of: timerModel.restDuration) { newValue in
                    if newValue == -1 {
                        showCustomRestTimeAlert = true
                        // 重置回之前的值，直到用户确认自定义时间
                        timerModel.restDuration = UserDefaults.standard.integer(forKey: "restDuration")
                        if timerModel.restDuration == 0 || timerModel.restDuration == -1 {
                            timerModel.restDuration = 20
                        }
                    } else {
                        timerModel.saveSettings()
                    }
                }
            }
        }
    }
}

// 休息部分设置视图
struct RestSettingsView: View {
    @Binding var cycleEnabled: Bool
    @ObservedObject var timerModel: TimerModel
    
    var body: some View {
        Section(header: Text("休息 👑")) {
            HStack {
                Text("循环")
                Spacer()
                Picker("", selection: $cycleEnabled) {
                    Text("关闭").tag(false)
                    Text("开启").tag(true)
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 100)
            }
            
            HStack {
                Text("休息时间")
                Spacer()
                Picker("", selection: $timerModel.restDuration) {
                    Text("5分钟").tag(5 * 60)
                    Text("10分钟").tag(10 * 60)
                    Text("15分钟").tag(15 * 60)
                    Text("20分钟").tag(20 * 60)
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 100)
            }
        }
    }
}

// 重复部分设置视图
struct RepeatSettingsView: View {
    var body: some View {
        Section(header: Text("重复 👑")) {
            HStack {
                Text("日")
                Text("一")
                Text("二")
                Text("三")
                Text("四")
                Text("五")
                Text("六")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
            .background(Color.blue)
            .cornerRadius(8)
            .foregroundColor(.white)
        }
    }
}

// 勿扰模式部分设置视图
struct DoNotDisturbSettingsView: View {
    var body: some View {
        Section(header: Text("勿扰模式 👑")) {
            NavigationLink(destination: Text("设置定时界面")) {
                Text("设置定时")
            }
        }
    }
}

// 严格模式部分设置视图
struct StrictModeSettingsView: View {
    @Binding var skipAllowed: Bool
    
    var body: some View {
        Section(header: Text("严格模式 👑")) {
            Toggle("允许跳过", isOn: $skipAllowed)
        }
    }
}

// 外观设置部分视图
struct UISettingsView: View {
    @Binding var autoHide: Bool
    @Binding var fullScreenMode: Bool
    @Binding var fadeAnimation: Bool
    
    var body: some View {
        Section(header: Text("外观")) {
            Toggle("所有屏幕", isOn: $autoHide)
            Toggle("全屏模式", isOn: $fullScreenMode)
            Toggle("淡入淡出", isOn: $fadeAnimation)
            Toggle("自动隐藏", isOn: $autoHide)
        }
    }
}

// 文字设置部分视图
struct TextSettingsView: View {
    @Binding var restPromptText: String
    @Binding var workPromptText: String
    
    var body: some View {
        Section(header: Text("文字")) {
            HStack {
                Text("小憩文字")
                Spacer()
                Picker("", selection: $restPromptText) {
                    Text("请眺望远方").tag("请眺望远方")
                    Text("休息一下").tag("休息一下")
                    Text("站起来伸展").tag("站起来伸展")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 150)
            }
            
            HStack {
                Text("休息文字")
                Spacer()
                Picker("", selection: $workPromptText) {
                    Text("站起来活动一下").tag("站起来活动一下")
                    Text("休息结束").tag("休息结束")
                    Text("开始工作").tag("开始工作")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 150)
            }
        }
    }
}

// 声音设置部分视图
struct SoundSettingsView: View {
    @Binding var workSoundOption: String
    @Binding var restSoundOption: String
    
    var body: some View {
        Section(header: Text("声音")) {
            HStack {
                Text("开始休息")
                Spacer()
                Picker("", selection: $workSoundOption) {
                    Text("放松").tag("放松")
                    Text("叮咚").tag("叮咚")
                    Text("铃声").tag("铃声")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 100)
            }
            
            HStack {
                Text("休息结束")
                Spacer()
                Picker("", selection: $restSoundOption) {
                    Text("清脆").tag("清脆")
                    Text("滴答").tag("滴答")
                    Text("静音").tag("静音")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 100)
            }
        }
    }
}

// 动画设置部分视图
struct AnimationSettingsView: View {
    var body: some View {
        Section(header: Text("动画")) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(1...5, id: \.self) { index in
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 100)
                                .cornerRadius(8)
                            
                            if index == 3 {
                                Image("dinosaur")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                            } else if index == 1 {
                                Image(systemName: "nosign")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            } else if index == 2 {
                                Image(systemName: "arrow.clockwise")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            } else if index == 4 {
                                Image(systemName: "square")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                            } else {
                                Text("日历")
                                    .foregroundColor(.white)
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(index == 3 ? Color.blue : Color.clear, lineWidth: 2)
                        )
                    }
                }
                .padding(.vertical, 10)
            }
            
            Button("预览") {
                // 预览动画
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 5)
        }
    }
}

// 主设置视图
struct SettingsView: View {
    @ObservedObject var timerModel: TimerModel
    @AppStorage("autoStartOnLaunch") private var autoStartOnLaunch = false
    @AppStorage("appearanceStyle") private var appearanceStyle = "系统"
    @AppStorage("showNotificationBefore") private var showNotificationBefore = true
    @AppStorage("notificationTime") private var notificationTime: Double = 20
    @AppStorage("playSound") private var playSound = true
    @AppStorage("pauseDuringScreenshare") private var pauseDuringScreenshare = true
    @AppStorage("resumeOnWake") private var resumeOnWake = true
    @AppStorage("showInMenuBar") private var showInMenuBar = false
    @AppStorage("cycleEnabled") private var cycleEnabled = false
    @AppStorage("skipAllowed") private var skipAllowed = true
    @AppStorage("restPromptText") private var restPromptText = "请眺望远方"
    @AppStorage("workPromptText") private var workPromptText = "站起来活动一下"
    @AppStorage("restSoundOption") private var restSoundOption = "清脆"
    @AppStorage("workSoundOption") private var workSoundOption = "放松"
    @AppStorage("fadeAnimation") private var fadeAnimation = true
    @AppStorage("autoHide") private var autoHide = true
    @AppStorage("fullScreenMode") private var fullScreenMode = true
    @State private var customWorkMinutes: String = ""
    @State private var customRestSeconds: String = ""
    @State private var showCustomWorkTimeAlert = false
    @State private var showCustomRestTimeAlert = false
    
    var body: some View {
        List {
            // 移除启动设置
            // LaunchSettingsView(autoStartOnLaunch: $autoStartOnLaunch)
            // 移除外观设置
            // AppearanceSettingsView(appearanceStyle: $appearanceStyle)
            
            // 移除休息前通知
            // NotificationSettingsView(notificationTime: $notificationTime, playSound: $playSound)
            
            ScreenSettingsView(pauseDuringScreenshare: $pauseDuringScreenshare, resumeOnWake: $resumeOnWake)
            
            // 移除菜单栏
            // MenuBarSettingsView(showInMenuBar: $showInMenuBar)
            
            BreakSettingsView(timerModel: timerModel, showCustomWorkTimeAlert: $showCustomWorkTimeAlert, showCustomRestTimeAlert: $showCustomRestTimeAlert)
            RestSettingsView(cycleEnabled: $cycleEnabled, timerModel: timerModel)
            
            // 移除重复设置
            // RepeatSettingsView()
            
            // 移除勿扰模式
            // DoNotDisturbSettingsView()
            
            StrictModeSettingsView(skipAllowed: $skipAllowed)
            
            // 移除 UISettingsView
            // UISettingsView(autoHide: $autoHide, fullScreenMode: $fullScreenMode, fadeAnimation: $fadeAnimation)
            
            // 移除休息文字
            // TextSettingsView(restPromptText: $restPromptText, workPromptText: $workPromptText)
            
            // 移除声音
            // SoundSettingsView(workSoundOption: $workSoundOption, restSoundOption: $restSoundOption)
            
            // 移除动画
            // AnimationSettingsView()
        }
        .listStyle(SidebarListStyle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .alert("自定义工作时间", isPresented: $showCustomWorkTimeAlert) {
            TextField("输入分钟数", text: $customWorkMinutes)
            
            Button("取消", role: .cancel) {}
            
            Button("确定") {
                if let minutes = Int(customWorkMinutes), minutes > 0 {
                    timerModel.workDuration = minutes * 60
                    timerModel.saveSettings()
                }
                customWorkMinutes = ""
            }
        } message: {
            Text("请输入工作时间的分钟数")
        }
        .alert("自定义休息时间", isPresented: $showCustomRestTimeAlert) {
            TextField("输入秒数", text: $customRestSeconds)
            
            Button("取消", role: .cancel) {}
            
            Button("确定") {
                if let seconds = Int(customRestSeconds), seconds > 0 {
                    timerModel.restDuration = seconds
                    timerModel.saveSettings()
                }
                customRestSeconds = ""
            }
        } message: {
            Text("请输入休息时间的秒数")
        }
    }
}

#Preview {
    SettingsView(timerModel: TimerModel())
}