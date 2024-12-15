//
//  StudyRankView.swift
//  Hook
//
//  Created by Jimin Yoo on 12/14/24.
//
import SwiftUI
import Charts

// MARK: - 메인 통계 뷰
struct StudyDistributionView: View {
    let userStudyTime: Double = 180
    let percentile: Double = 85.5
    let distributionPoints = generateNormalDistribution(
        mean: 180,
        stdDev: 60,
        points: 100
    )
    
    @Environment(\.dismiss) private var dismiss
    @State private var showView = false
    @State private var showChart = false
    @State private var showUserPosition = false
    @State private var showText = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // 상위 백분위 표시
                Text("상위 \(String(format: "%.1f", 100 - percentile))%")
                    .font(.system(size: 28, weight: .bold))
                    .opacity(showText ? 1 : 0)
                    .offset(y: showText ? 0 : 20)
                
                // 분포 차트
                Chart {
                    // 정규분포 곡선
                    if showChart {
                        ForEach(distributionPoints.indices.dropLast(), id: \.self) { index in
                            LineMark(
                                x: .value("Time", distributionPoints[index].time),
                                y: .value("Distribution", distributionPoints[index].value)
                            )
                            .foregroundStyle(.gray.opacity(0.5))
//                            .transition(.opacity) 
                        }
                    }
                    
                    // 사용자 위치 표시
                    if showUserPosition {
                        RuleMark(
                            x: .value("Your Time", userStudyTime)
                        )
                        .foregroundStyle(.blue)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        
                        PointMark(
                            x: .value("Your Time", userStudyTime),
                            y: .value("Distribution", normalDistribution(
                                x: userStudyTime,
                                mean: 180,
                                stdDev: 60
                            ))
                        )
                        .foregroundStyle(.blue)
                        .symbolSize(100)
                    }
                }
                .frame(height: 100)
                .chartYAxis(.hidden)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { value in
                        AxisValueLabel {
                            if let time = value.as(Double.self) {
                                Text(formatHours(minutes: time))
                                    .font(.system(size: 10))
                            }
                        }
                    }
                }
                .opacity(showChart ? 1 : 0)
                
                // 학습 시간 표시
                VStack(spacing: 4) {
                    Text("나의 학습시간")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text(formatStudyTime(minutes: userStudyTime))
                        .font(.system(size: 20, weight: .semibold))
                }
                .opacity(showText ? 1 : 0)
                .offset(y: showText ? 0 : 20)
            }
            .padding()
            .offset(y: showView ? 0 : 50)
            .opacity(showView ? 1 : 0)
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
    
    private func animateEntrance() {
        // 전체 뷰 페이드인
        withAnimation(.easeOut(duration: 0.5)) {
            showView = true
        }
        
        // 차트 베이스 표시
        withAnimation(.easeOut(duration: 0.7).delay(0.3)) {
            showChart = true
        }
        
        // 사용자 위치 표시
        withAnimation(.spring(duration: 0.7).delay(0.8)) {
            showUserPosition = true
        }
        
        // 텍스트 표시
        withAnimation(.easeOut(duration: 0.5).delay(1.0)) {
            showText = true
        }
    }
    
    private func formatStudyTime(minutes: Double) -> String {
        let hours = Int(minutes / 60)
        let mins = Int(minutes.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return "\(hours)시간 \(mins)분"
        } else {
            return "\(mins)분"
        }
    }
    
    private func formatHours(minutes: Double) -> String {
        let hours = Int(minutes / 60)
        return "\(hours)h"
    }
}

// MARK: - 데이터 모델
struct DistributionPoint {
    let time: Double
    let value: Double
}

// MARK: - 통계 계산 함수들
func normalDistribution(x: Double, mean: Double, stdDev: Double) -> Double {
    let exp = -pow(x - mean, 2) / (2 * pow(stdDev, 2))
    return (1 / (stdDev * sqrt(2 * .pi))) * pow(M_E, exp)
}

func generateNormalDistribution(mean: Double, stdDev: Double, points: Int) -> [DistributionPoint] {
    let start = mean - (3 * stdDev)
    let end = mean + (3 * stdDev)
    let step = (end - start) / Double(points)
    
    var result: [DistributionPoint] = []
    
    for i in 0...points {
        let x = start + (Double(i) * step)
        let y = normalDistribution(x: x, mean: mean, stdDev: stdDev)
        result.append(DistributionPoint(time: x, value: y))
    }
    
    return result
}

// MARK: - 메인 뷰 (통계 버튼)
struct MainView: View {
    @State private var showStats = false
    
    var body: some View {
        Button(action: {
            showStats = true
        }) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                Text("학습 통계")
            }
        }
        .sheet(isPresented: $showStats) {
            StudyDistributionView()
        }
    }
}

// MARK: - 프리뷰
struct StudyDistributionView_Previews: PreviewProvider {
    static var previews: some View {
        StudyDistributionView()
    }
}
