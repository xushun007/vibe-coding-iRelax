import SwiftUI

struct TimerView: View {
    @ObservedObject var timerModel: TimerModel
    @State private var animationAmount = 1.0
    @AppStorage("restPromptText") private var restPromptText = "请眺望远方"
    @AppStorage("workPromptText") private var workPromptText = "站起来活动一下"
    
    var body: some View {
        VStack {
            // 添加顶部空间，将计时器位置下移
            Spacer().frame(height: 50)
            
            // 计时器圆形进度 - 放在美观的卡片中
            ZStack {
                // 卡片背景
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white.opacity(0.1))
                    .shadow(color: Color.black.opacity(0.1), radius: 10)
                    .frame(width: 280, height: 320)
                
                VStack {
                    // 计时器圆形进度容器
                    ZStack {
                        // 进度背景
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                            .frame(width: 220, height: 220)
                        
                        // 进度条 - 添加渐变效果
                        Circle()
                            .trim(from: 0, to: CGFloat(timerModel.progressPercentage()))
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        timerModel.timerState == .working ? Color.blue : Color.green,
                                        timerModel.timerState == .working ? Color.blue.opacity(0.7) : Color.green.opacity(0.7)
                                    ]),
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 15, lineCap: .round)
                            )
                            .frame(width: 220, height: 220)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear, value: timerModel.progressPercentage())
                            .shadow(color: timerModel.timerState == .working ? Color.blue.opacity(0.3) : Color.green.opacity(0.3), radius: 5)
                        
                        // 内部圆形背景 - 半透明效果
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.gray.opacity(0.15),
                                        Color.gray.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 200, height: 200)
                        
                        // 始终显示时间，暂停状态显示更大
                        VStack(spacing: 5) {
                            Text(timerModel.formattedTime())
                                .font(.system(size: timerModel.isTimerRunning ? 50 : 60, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 1)
                            
                            if timerModel.isTimerRunning {
                                // 显示暂停图标
                                HStack(spacing: 12) {
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: 5, height: 25)
                                        .cornerRadius(2)
                                    
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: 5, height: 25)
                                        .cornerRadius(2)
                                }
                                .padding(.top, 5)
                                .opacity(0.9)
                            }
                        }
                    }
                    
                    // 状态文本，移除剩余时间显示
                    if timerModel.timerState == .working {
                        Text("专注中")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                    } else if timerModel.timerState == .resting {
                        Text("休息中")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                    } else if timerModel.timerState == .idle {
                        Text("准备开始")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                    } else {
                        Text("已暂停")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                    }
                }
            }
            .padding(.vertical, 20)
            
            // 当在休息状态时显示休息文本
            if timerModel.timerState == .resting {
                Text(restPromptText)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .foregroundColor(.white)
                    .scaleEffect(animationAmount)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: animationAmount
                    )
                    .onAppear {
                        animationAmount = 1.1
                    }
                    .onDisappear {
                        animationAmount = 1.0
                    }
            }
            
            Spacer()
            
            // 控制按钮 - 更扁平化美观的设计
            HStack(spacing: 40) {
                // 重置按钮 - 扁平化设计
                Button(action: {
                    timerModel.reset()
                }) {
                    Text("重置")
                        .font(.system(size: 17, weight: .medium))
                        .frame(width: 120, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "4A4A4A"))
                        )
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                
                // 开始/暂停按钮 - 扁平化设计
                Button(action: {
                    if timerModel.timerState == .idle {
                        timerModel.startWorking()
                    } else if timerModel.isTimerRunning {
                        timerModel.pause()
                    } else if timerModel.timerState == .paused {
                        timerModel.resume()
                    } else if timerModel.timerState == .resting {
                        timerModel.skip()
                    }
                }) {
                    Text(getActionButtonText())
                        .font(.system(size: 17, weight: .medium))
                        .frame(width: 120, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(getActionButtonColor())
                        )
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "394867"),
                    Color(hex: "212A3E")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    // 格式化时间文本
    private func formatTimeText(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        if minutes > 0 {
            return " \(minutes)分\(remainingSeconds)秒"
        } else {
            return " \(remainingSeconds)秒"
        }
    }
    
    // 获取操作按钮文本
    private func getActionButtonText() -> String {
        switch timerModel.timerState {
        case .idle:
            return "开始"
        case .working:
            return timerModel.isTimerRunning ? "暂停" : "继续"
        case .resting:
            return "跳过"
        case .paused:
            return "继续"
        }
    }
    
    // 获取操作按钮颜色
    private func getActionButtonColor() -> Color {
        switch timerModel.timerState {
        case .idle, .paused:
            return Color(hex: "3498DB")
        case .working:
            return timerModel.isTimerRunning ? Color(hex: "E74C3C") : Color(hex: "3498DB")
        case .resting:
            return Color(hex: "2ECC71")
        }
    }
}

// 新增：用于全屏休息界面的 SwiftUI 视图
struct RestScreenView: View {
    @ObservedObject var timerModel: TimerModel
    let restPromptText: String
    
    var body: some View {
        ZStack {
            // 黑色背景
            Color.black
            
            VStack(spacing: 40) {
                Spacer()
                
                // 时间显示
                Text(timerModel.formattedTime())
                    .font(.system(size: 90, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // 提示文本
                Text(restPromptText)
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                Spacer()
                
                // 跳过按钮 - 完全重新设计
                ZStack {
                    // 按钮背景
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red)
                        .frame(width: 120, height: 44)
                    
                    // 按钮文字
                    Text("跳过")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .onTapGesture {
                    timerModel.skip()
                }
                .padding(.bottom, 50)
            }
        }
        // 强制 ZStack 扩展并忽略安全区域
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        // 当此视图出现时，确保 timerModel 的状态是 .resting
        .onAppear {
            if timerModel.timerState != .resting {
                print("Warning: RestScreenView appeared but state is not .resting")
            }
        }
    }
}

// 颜色扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    TimerView(timerModel: TimerModel())
}