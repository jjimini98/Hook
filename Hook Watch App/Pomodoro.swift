import SwiftUI
import UserNotifications
import WatchKit


import SwiftUI
import UserNotifications
import WatchKit

struct PomodoroView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var timer: Timer?
    @State private var isActive = false
    @State private var isWorkTime = true
    @FocusState private var isFocused: Bool
    @State private var timeRemaining: Double = 25.0 * 60.0
    @State private var startTime: Double = 25.0 * 60.0
    @State private var lastTapTime: Date? = nil
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    TimerProgressView(timeRemaining: Int(timeRemaining),
                                    startTime: Int(startTime),
                                    isWorkTime: isWorkTime)
                    
                    TimerDisplayView(timeRemaining: $timeRemaining,
                                   isFocused: _isFocused,
                                   isActive: $isActive,
                                   toggleTimer: toggleTimer,
                                   handleCrownButton: handleCrownButton)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    BackButton(dismiss: dismiss)
                }
            }
        }
        .onAppear {
            requestNotificationPermission()
        }
    }
    
    private func handleCrownButton() {
        let now = Date()
        
        if let lastTap = lastTapTime,
           now.timeIntervalSince(lastTap) < 0.3 {
            if isActive {
                toggleTimer()
            }
            lastTapTime = nil
        } else {
            if !isActive {
                toggleTimer()
            }
            lastTapTime = now
        }
    }
    
    private func toggleTimer() {
        if isActive {
            timer?.invalidate()
            timer = nil
        } else {
            startNewTimer()
        }
        isActive.toggle()
    }
    
    private func startNewTimer() {
        // 기존 타이머가 있다면 무효화
        timer?.invalidate()
        timer = nil
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                // 타이머가 끝났을 때
                sendNotification()
                isWorkTime.toggle()
                
                // 다음 세션 시간 설정
                timeRemaining = isWorkTime ? (25 * 60) : (5 * 60)
                startTime = timeRemaining
                
                // 자동으로 다음 세션 시작 전에 기존 타이머 무효화
                timer?.invalidate()
                timer = nil
                
                // 햅틱 피드백
                WKInterfaceDevice.current().play(.notification)
                
                // 새로운 타이머 시작
                startNewTimer()
            }
        }
    }
}


struct TimerProgressView: View {
    let timeRemaining: Int
    let startTime: Int
    let isWorkTime: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 6)
            
            Circle()
                .trim(from: 0, to: Double(timeRemaining) / Double(startTime))
                .stroke(
                    isWorkTime ? Color.red.opacity(0.8) : Color.blue.opacity(0.8),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
    }
}

struct TimerDisplayView: View {
    @Binding var timeRemaining: Double
    @FocusState var isFocused: Bool
    @Binding var isActive: Bool
    let toggleTimer: () -> Void
    let handleCrownButton: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            Text(timeString(from: Int(timeRemaining)))
                .font(.system(size: 44, weight: .bold))
                .focusable(true, onFocusChange: { focused in
                    isFocused = focused
                    if focused {
                        WKInterfaceDevice.current().play(.click)
                        handleCrownButton()
                    }
                })
                .digitalCrownRotation(
                    $timeRemaining,
                    from: 1.0 * 60.0,
                    through: 60.0 * 60.0,
                    by: 60.0,
                    sensitivity: .medium,
                    isContinuous: false,
                    isHapticFeedbackEnabled: true
                )
                .onTapGesture {
                    toggleTimer()
                }
          
            Text("\(timeString(from: Int(timeRemaining), showSeconds: false))")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func timeString(from seconds: Int, showSeconds: Bool = true) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return showSeconds ?
            String(format: "%02d:%02d", minutes, remainingSeconds) :
            String(format: "%d분", minutes)
    }
}

struct BackButton: View {
    let dismiss: DismissAction
    
    var body: some View {
        Button(action: {
            dismiss()
        }) {
            Image(systemName: "chevron.left")
        }
    }
}

extension PomodoroView {
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("알림 권한이 허용되었습니다")
            } else {
                print("알림 권한이 거부되었습니다")
            }
        }
    }
    
    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = isWorkTime ? "작업 시간 종료!" : "휴식 시간 종료!"
        content.body = isWorkTime ? "휴식을 시작하세요." : "작업을 시작하세요."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

#Preview {
    PomodoroView()
}
