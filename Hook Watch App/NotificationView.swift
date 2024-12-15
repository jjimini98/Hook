//
//  NotificationView.swift
//  Hook
//
//  Created by Jimin Yoo on 12/15/24.
//

import SwiftUI

// 알림 데이터 모델
struct NotificationItem: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let appIcon: String
    let timestamp: Date
    var isRead: Bool = false
}

// 알림센터 메인 뷰
struct NotificationCenterView: View {
    @State private var notifications: [NotificationItem] = [
        NotificationItem(
            title: "알림",
            body: "새로운 메시지가 도착했습니다",
            appIcon: "message.fill",
            timestamp: Date()
        ),
        NotificationItem(
            title: "캘린더",
            body: "30분 후 회의가 있습니다",
            appIcon: "calendar",
            timestamp: Date().addingTimeInterval(-3600)
        ),
        NotificationItem(
            title : "수면",
            body : "이번주 수면 통계가 도착했습니다",
            appIcon: "moon.fill",
            timestamp: Date().addingTimeInterval(-7200)
        )
    ]
    
    @State private var showClearConfirmation = false
    
    var body: some View {
        NavigationStack {
            if notifications.isEmpty {
                EmptyNotificationView()
            } else {
                List {
                    ForEach(notifications) { notification in
                        NotificationCell(notification: notification)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                                        notifications.remove(at: index)
                                    }
                                } label: {
                                    Label("삭제", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("알림")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            showClearConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
                .confirmationDialog(
                    "모든 알림을 삭제하시겠습니까?",
                    isPresented: $showClearConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("모두 삭제", role: .destructive) {
                        notifications.removeAll()
                    }
                    Button("취소", role: .cancel) {}
                }
            }
        }
    }
}

// 개별 알림 셀
struct NotificationCell: View {
    let notification: NotificationItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: notification.appIcon)
                    .foregroundColor(.blue)
                Text(notification.title)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(timeAgo(from: notification.timestamp))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Text(notification.body)
                .font(.system(size: 14))
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
    
    private func timeAgo(from date: Date) -> String {
        let minutes = Int(-date.timeIntervalSinceNow / 60)
        if minutes < 60 {
            return "\(minutes)분 전"
        } else {
            let hours = minutes / 60
            return "\(hours)시간 전"
        }
    }
}

// 알림이 없을 때 보여줄 뷰
struct EmptyNotificationView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.slash.fill")
                .font(.system(size: 30))
                .foregroundColor(.gray)
            Text("알림이 없습니다")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    NotificationCenterView()
}
