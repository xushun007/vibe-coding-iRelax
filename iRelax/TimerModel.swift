import Foundation
import UserNotifications
import AppKit

class TimerModel: ObservableObject {
    // 计时器状态
    enum TimerState {
        case idle         // 空闲状态
        case working      // 工作状态
        case resting      // 休息状态
        case paused       // 暂停状态
    }
    
    // 发布属性
    @Published var timerState: TimerState = .idle
    @Published var secondsLeft: Int = 0
    @Published var totalSeconds: Int = 0
    @Published var workDuration: Int = 20 * 60  // 默认20分钟
    @Published var restDuration: Int = 20       // 默认20秒
    @Published var isTimerRunning: Bool = false
    @Published var showRestScreen: Bool = false // 控制 ContentView 中的休息视图显示
    
    // 使用最简单的标准Timer
    private var timer: Timer?
    
    // 标志位防止重复处理倒计时结束
    private var isHandlingTimerEnd = false
    
    // 初始化
    init() {
        // 从用户默认设置加载配置
        loadSettings()
    }
    
    deinit {
        print("TimerModel deinit")
        // 确保在销毁时清理资源
        stopTimer()
    }
    
    // 读取设置
    private func loadSettings() {
        let defaults = UserDefaults.standard
        workDuration = defaults.integer(forKey: "workDuration")
        if workDuration == 0 { workDuration = 20 * 60 }
        
        restDuration = defaults.integer(forKey: "restDuration")
        if restDuration == 0 { restDuration = 20 }
    }
    
    // 保存设置
    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(workDuration, forKey: "workDuration")
        defaults.set(restDuration, forKey: "restDuration")
    }
    
    // 开始工作计时
    func startWorking() {
        // 重置标志位
        isHandlingTimerEnd = false
        
        timerState = .working
        secondsLeft = workDuration
        totalSeconds = workDuration
        startTimer()
    }
    
    // 开始休息计时
    func startResting() {
        // 防止嵌套调用导致的卡死
        if isHandlingTimerEnd {
            print("已经在处理定时器结束，忽略startResting调用")
            return
        }
        
        print("进入startResting方法")
        
        timerState = .resting
        secondsLeft = restDuration
        totalSeconds = restDuration
        
        // 播放声音
        SoundManager.shared.playStartRestSound()
        
        // 发送通知
        sendNotification(title: "休息时间", body: UserDefaults.standard.string(forKey: "restPromptText") ?? "请眺望远方")
        
        // 启动定时器
        startTimer()
        
        // 显示休息界面 (通过状态通知 ContentView)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.showRestScreen = true
            print("startResting: 设置显示休息界面 showRestScreen = true")
            
            // 将窗口弹到最前面
            if let window = NSApplication.shared.windows.first {
                window.level = .floating  // 设置为浮动窗口层级
                window.orderFrontRegardless()  // 强制窗口显示在最前面
                print("startResting: 将窗口置顶")
                
                // 在休息结束后恢复普通窗口层级
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(self.restDuration)) {
                    if self.timerState == .resting {
                        window.level = .normal
                        print("startResting: 定时恢复窗口层级")
                    }
                }
            }
        }
    }
    
    // 重置计时器
    func reset() {
        stopTimer()
        timerState = .idle
        isTimerRunning = false
        showRestScreen = false
        isHandlingTimerEnd = false
        
        // 重置所有计时相关状态
        secondsLeft = 0
        totalSeconds = 0
        
        // 确保窗口恢复正常层级
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                window.level = .normal
            }
        }
    }
    
    // 暂停计时器
    func pause() {
        stopTimer()
        timerState = .paused
        isTimerRunning = false
    }
    
    // 继续计时
    func resume() {
        startTimer()
    }
    
    // 跳过当前阶段
    func skip() {
        // 防止嵌套调用导致的卡死
        if isHandlingTimerEnd {
            print("已经在处理定时器结束，忽略skip调用")
            return
        }
        
        if timerState == .working {
            stopTimer()
            DispatchQueue.main.async {
                self.startResting()
            }
        } else if timerState == .resting {
            stopTimer()
            isTimerRunning = false
            
            // 隐藏休息界面
            showRestScreen = false
            
            // 播放声音
            SoundManager.shared.playEndRestSound()
            
            // 根据设置决定下一步
            if UserDefaults.standard.bool(forKey: "cycleEnabled") {
                timerState = .working
                secondsLeft = workDuration
                totalSeconds = workDuration
                startTimer()
            } else {
                timerState = .idle
            }
            
            isHandlingTimerEnd = false
        }
    }
    
    // 启动定时器
    private func startTimer() {
        // 停止已有定时器
        stopTimer()
        
        isTimerRunning = true
        
        // 创建一个简单的重复定时器
        timer = Timer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
        // 添加到RunLoop中，使用common模式确保在各种情况下都能正常工作
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    // 定时器回调
    @objc private func timerAction() {
        // 在主线程执行UI更新
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.timerAction()
            }
            return
        }
        
        // 防止回调重入
        guard !isHandlingTimerEnd else {
            print("正在处理定时器结束，忽略此次回调")
            return
        }
        
        // 如果当前不是运行状态，不执行倒计时
        if !isTimerRunning {
            return
        }
        
        // 倒计时
        if secondsLeft > 1 {
            secondsLeft -= 1
            
            // 处理预通知
            if timerState == .working && 
               secondsLeft == Int(UserDefaults.standard.double(forKey: "notificationTime")) && 
               UserDefaults.standard.bool(forKey: "showNotificationBefore") {
                sendNotification(title: "即将休息", body: "休息时间即将开始")
            }
        } else if secondsLeft == 1 {
            // 最后一秒，设置为0
            secondsLeft = 0
            
            print("TimerAction: 最后1秒，处理状态转换")
            
            // 设置标志防止多次处理
            isHandlingTimerEnd = true
            
            // 停止计时器，执行最简单的状态转换
            stopTimer()
            isTimerRunning = false
            
            // 根据当前状态，执行基本操作
            if timerState == .working {
                // 直接切换到休息状态
                print("TimerAction: 工作结束，切换到休息状态")
                
                // 使用主线程异步执行，确保UI更新在正确的线程
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.timerState = .resting
                    self.secondsLeft = self.restDuration
                    self.totalSeconds = self.restDuration
                    
                    // 播放声音
                    SoundManager.shared.playStartRestSound()
                    
                    // 发送通知
                    self.sendNotification(title: "休息时间", body: UserDefaults.standard.string(forKey: "restPromptText") ?? "请眺望远方")
                    
                    // 显示休息界面
                    self.showRestScreen = true
                    print("TimerAction: 设置显示休息界面 showRestScreen = true")
                    
                    // 将窗口弹到最前面
                    if let window = NSApplication.shared.windows.first {
                        window.level = .floating
                        window.orderFrontRegardless()
                        print("TimerAction: 将窗口置顶")
                    }
                    
                    // 开始计时
                    self.startTimer()
                    
                    // 完成处理
                    self.isHandlingTimerEnd = false
                }
                
                return // 提前返回，避免下面的代码重置标志位
            } else if timerState == .resting {
                print("TimerAction: 休息结束")
                
                // 隐藏休息界面
                showRestScreen = false
                print("TimerAction: 隐藏休息界面 showRestScreen = false")
                
                // 基本操作
                SoundManager.shared.playEndRestSound()
                sendNotification(title: "休息结束", body: "是时候回到工作中了")
                
                // 恢复窗口层级
                if let window = NSApplication.shared.windows.first {
                    window.level = .normal
                    print("TimerAction: 恢复窗口层级")
                }
                
                // 根据设置决定下一个状态
                if UserDefaults.standard.bool(forKey: "cycleEnabled") {
                    print("TimerAction: 开始新一轮工作")
                    timerState = .working
                    secondsLeft = workDuration
                    totalSeconds = workDuration
                    startTimer()
                } else {
                    print("TimerAction: 设置为空闲状态")
                    timerState = .idle
                }
            }
            
            isHandlingTimerEnd = false
        }
    }
    
    // 停止定时器
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // 发送系统通知
    private func sendNotification(title: String, body: String) {
        if UserDefaults.standard.bool(forKey: "playSound") {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                if granted {
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = body
                    content.sound = UNNotificationSound.default
                    
                    let request = UNNotificationRequest(identifier: UUID().uuidString, 
                                                      content: content, 
                                                      trigger: nil)
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("通知发送失败: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    // 格式化时间显示
    func formattedTime() -> String {
        let minutes = secondsLeft / 60
        let seconds = secondsLeft % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // 计算进度百分比
    func progressPercentage() -> Double {
        if totalSeconds == 0 { return 0 }
        return Double(totalSeconds - secondsLeft) / Double(totalSeconds)
    }
}