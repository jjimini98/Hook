//
//  Home.swift
//  Hook
//
//  Created by Jimin Yoo on 12/7/24.
//
import SwiftUI

// 메인 화면
struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("Image")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .cornerRadius(10)

                Text("안녕하세요, 새이솔입니다 오늘도 좋은 하루 보내세요")
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)  // 텍스트 정렬 방식

                NavigationLink(
                    destination: MenuView(),
                    label: {
                        Text("입장")
                            .font(.system(size: 16))
//                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
//                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                )
            }
            .padding()
        }
    }
}



#Preview {
    HomeView()
}


