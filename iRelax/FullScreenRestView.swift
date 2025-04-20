import SwiftUI

struct FullScreenRestView: View {
    @EnvironmentObject var timerModel: TimerModel
    var restPromptText: String
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                Text(timerModel.formattedTime())
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.white)
                
                Text(restPromptText)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Button("跳过") {
                    timerModel.skip()
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, 50)
            }
            .padding(50)
        }
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 49 { // 空格键
                    timerModel.skip()
                    return nil
                }
                return event
            }
        }
    }
}

#Preview {
    FullScreenRestView(restPromptText: "请眺望远方")
        .environmentObject(TimerModel())
}