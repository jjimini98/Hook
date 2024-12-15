import SwiftUI
import UserNotifications
import WatchKit

// MARK: - 메인 뷰
struct PomodoroView: View {
    @Environment(\.dismiss) private var dismiss
//    @State private var timeRemaining = 25 * 60
    @State private var timer: Timer?
    @State private var isActive = false
    @State private var isWorkTime = true
//    @State private var startTime = 25 * 60
    @FocusState private var isFocused: Bool
    @State private var timeRemaining: Double = 25.0 * 60.0
    @State private var startTime: Double = 25.0 * 60.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                TimerProgressView(timeRemaining: Int(timeRemaining),
                                startTime: Int(startTime),
                                isWorkTime: isWorkTime)
                
                VStack {
                    TimerDisplayView(timeRemaining: /*$timeRemaining,*/
                                     $timeRemaining,
                                   isFocused: _isFocused)
                    
                    ControlButtonsView(isActive: isActive,
                                     toggleTimer: toggleTimer,
                                     resetTimer: resetTimer)
                }
            }
            .padding()
            .navigationTitle("뽀모도로")
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
    
    // MARK: - 타이머 관련 메서드
    private func toggleTimer() {
        if isActive {
            timer?.invalidate()
            timer = nil
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer?.invalidate()
                    timer = nil
                    isActive = false
                    sendNotification()
                    isWorkTime.toggle()
                    timeRemaining = isWorkTime ? (25 * 60) : (5 * 60)
                    startTime = timeRemaining
                }
            }
        }
        isActive.toggle()
    }
    
    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        isActive = false
        timeRemaining = 25 * 60
        startTime = timeRemaining
        isWorkTime = true
    }
}

// MARK: - 타이머 프로그레스 뷰
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

// MARK: - 타이머 디스플레이 뷰
struct TimerDisplayView: View {
    @Binding var timeRemaining: Double  // Int에서 Double로 변경
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack {
            Text(timeString(from: Int(timeRemaining)))  // Double을 Int로 변환하여 표시
                .font(.system(size: 36, weight: .bold))
                .focusable(true, onFocusChange: { isFocused = $0 })
                .digitalCrownRotation(
                    $timeRemaining,
                    from: 1.0 * 60.0,      // Double 리터럴 사용
                    through: 60.0 * 60.0,  // Double 리터럴 사용
                    by: 60.0,             // Double 리터럴 사용
                    sensitivity: .medium,
                    isContinuous: false,
                    isHapticFeedbackEnabled: true
                )
            
            Text("\(timeString(from: Int(timeRemaining), showSeconds: false))")  // Double을 Int로 변환
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
    
    private func timeString(from seconds: Int, showSeconds: Bool = true) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return showSeconds ?
            String(format: "%02d:%02d", minutes, remainingSeconds) :
            String(format: "%d분", minutes)
    }
}
// MARK: - 컨트롤 버튼 뷰
struct ControlButtonsView: View {
    let isActive: Bool
    let toggleTimer: () -> Void
    let resetTimer: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: toggleTimer) {
                Image(systemName: isActive ? "pause.fill" : "play.fill")
                    .font(.system(size: 20))
            }
            
            Button(action: resetTimer) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 20))
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - 뒤로가기 버튼 뷰
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

// MARK: - 알림 관련 확장
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
