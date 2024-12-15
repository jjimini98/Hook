//
//  Menu.swift
//  Hook
//
//  Created by Jimin Yoo on 12/7/24.
//
import SwiftUI

struct MenuView : View {
    @State private var showPomodoro = false
    @State private var showStudyRank = false
    @State private var showWeeklyStatistics = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                
                // 버튼들을 수직으로 나열
                ForEach(menuItems, id: \.title) { item in
                    Button(action: {
                        // 버튼 액션 실행
                        handleButtonTap(item.title)
                    }) {
                        VStack(spacing: 5) {
                            // 시스템 아이콘 사용
                            Image(systemName: item.icon)
                                .font(.system(size: 24))
                            
                            Text(item.title)
                                .font(.system(size: 16))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal, 10)
        }
        .sheet(isPresented: $showPomodoro) {
            PomodoroView()
        }
        .sheet(isPresented: $showStudyRank) {
            StudyDistributionView()
        }
        .sheet(isPresented: $showWeeklyStatistics) {
            WeeklyStatisticsView()
        }

    }
// TODO : 뒤로가기 버튼이 있었으면 좋겠다 (뒤로가기 시 메인화면으로 진입)
//struct BackButton: View {
//    let dismiss: DismissAction
//    
//    var body: some View {
//        Button(action: {
//            dismiss()
//        }) {
//            Image(systemName: "chevron.left")
//        }
//    }
//}
    
    // 메뉴 아이템 데이터
    private let menuItems = [
        MenuItem(title: "타이머", icon: "alarm.fill"),
        MenuItem(title: "통계", icon: "chart.bar.fill"),
        MenuItem(title: "수면", icon: "moon.fill"),
        MenuItem(title: "일정", icon: "calendar"),
        MenuItem(title: "메시지", icon: "message.fill"),
        MenuItem(title: "알림", icon: "bell.fill")
    ]
    
    // 버튼 탭 처리 함수
    private func handleButtonTap(_ title: String) {
            switch title {
            case "타이머":
                showPomodoro = true
            case "통계" :
                showStudyRank = true
            case "주간 통계" :
                showWeeklyStatistics = true
            default:
                print("\(title) 버튼이 탭되었습니다")
            }
    }
}

//// 메뉴 아이템 구조체
struct MenuItem {
    let title: String
    let icon: String
}

#Preview {
    MenuView()
}

