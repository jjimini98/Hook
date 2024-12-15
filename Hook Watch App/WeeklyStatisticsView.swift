import SwiftUI
import Charts

// MARK: - 학습 데이터 모델
struct StudyData {
    let day: String
    let studyMinutes: Double
    let focusedMinutes: Double
}

// MARK: - 주간 통계 뷰
struct WeeklyStatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // 샘플 데이터
    let weekData = [
        StudyData(day: "월", studyMinutes: 180, focusedMinutes: 150),
        StudyData(day: "화", studyMinutes: 210, focusedMinutes: 180),
        StudyData(day: "수", studyMinutes: 160, focusedMinutes: 140),
        StudyData(day: "목", studyMinutes: 240, focusedMinutes: 200),
        StudyData(day: "금", studyMinutes: 190, focusedMinutes: 170),
        StudyData(day: "토", studyMinutes: 300, focusedMinutes: 260),
        StudyData(day: "일", studyMinutes: 120, focusedMinutes: 100)
    ]
    
    // 애니메이션 상태
    @State private var showChart = false
    @State private var showStats = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 오늘의 통계
                    VStack(spacing: 15) {
                        todayStats
                    }
                    .opacity(showStats ? 1 : 0)
                    .offset(y: showStats ? 0 : 20)
                    
                    // 주간 차트
                    weeklyChart
                        .frame(height: 200)
                        .opacity(showChart ? 1 : 0)
                        .offset(y: showChart ? 0 : 50)
                    
                    // 상세 통계
                    VStack(alignment: .leading, spacing: 15) {
                        Text("상세 통계")
                            .font(.headline)
                            .padding(.top)
                        
                        ForEach(weekData.reversed(), id: \.day) { data in
                            DailyStatRow(
                                day: data.day,
                                studyMinutes: data.studyMinutes,
                                focusedMinutes: data.focusedMinutes
                            )
                        }
                    }
                    .opacity(showStats ? 1 : 0)
                }
                .padding()
            }
            .navigationTitle("학습 통계")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
            .onAppear {
                animateEntrance()
            }
        }
    }
    
    // MARK: - 서브뷰
    
    // 오늘의 통계 뷰
    private var todayStats: some View {
        HStack(spacing: 20) {
            StatCard(
                title: "오늘 학습시간",
                value: formatTime(minutes: weekData.last?.studyMinutes ?? 0),
                icon: "clock.fill",
                color: .blue
            )
            
            StatCard(
                title: "집중 시간",
                value: formatTime(minutes: weekData.last?.focusedMinutes ?? 0),
                icon: "brain.head.profile",
                color: .green
            )
        }
    }
    
    // 주간 차트 뷰
    private var weeklyChart: some View {
        Chart {
            ForEach(weekData, id: \.day) { data in
                BarMark(
                    x: .value("Day", data.day),
                    y: .value("Minutes", data.studyMinutes)
                )
                .foregroundStyle(Color.blue.opacity(0.8))
                
                BarMark(
                    x: .value("Day", data.day),
                    y: .value("Focus", data.focusedMinutes)
                )
                .foregroundStyle(Color.green.opacity(0.8))
            }
        }
        .chartLegend(position: .top) {
            HStack {
                Text("총 학습시간")
                    .foregroundColor(.blue)
                Text("집중 시간")
                    .foregroundColor(.green)
            }
            .font(.caption)
        }
    }
    
    // MARK: - 헬퍼 메서드
    
    private func animateEntrance() {
        withAnimation(.easeOut(duration: 0.6)) {
            showStats = true
        }
        
        withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
            showChart = true
        }
    }
    
    private func formatTime(minutes: Double) -> String {
        let hours = Int(minutes / 60)
        let mins = Int(minutes.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return "\(hours)시간 \(mins)분"
        } else {
            return "\(mins)분"
        }
    }
}

// MARK: - 통계 카드 컴포넌트
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - 일별 상세 통계 행
struct DailyStatRow: View {
    let day: String
    let studyMinutes: Double
    let focusedMinutes: Double
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(day + "요일")
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Circle()
                            .fill(Color.blue.opacity(0.8))
                            .frame(width: 8, height: 8)
                        Text("학습: \(formatTime(minutes: studyMinutes))")
                    }
                    
                    HStack {
                        Circle()
                            .fill(Color.green.opacity(0.8))
                            .frame(width: 8, height: 8)
                        Text("집중: \(formatTime(minutes: focusedMinutes))")
                    }
                }
                Spacer()
                
                Text(String(format: "%.0f%%", (focusedMinutes/studyMinutes) * 100))
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func formatTime(minutes: Double) -> String {
        let hours = Int(minutes / 60)
        let mins = Int(minutes.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return "\(hours)시간 \(mins)분"
        } else {
            return "\(mins)분"
        }
    }
}

// MARK: - 프리뷰
#Preview {
    WeeklyStatisticsView()
}
