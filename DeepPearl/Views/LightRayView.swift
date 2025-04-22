//
//  LightRayView.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/8/25.
//

import SwiftUI

struct LightRayView: View {
    @State private var animate = false
    // 메인뷰의 전환 방식이 .sheet든 .transition이든 뷰가 실제로 제거되고 다시 그려지지 않는 한 @State는 유지된다.
    // @State 변수는 뷰가 완전히 사라졌다가 다시 생길 때만 초기화됨.
    // 애니메이션을 강제로 트리거하려면 @State를 리셋하거나 ObservableObject로 분리해서 전역에서 제어.

    
    var body: some View {
//        TimelineView(.animation){ timeline in
//            let date = timeline.date.timeIntervalSinceReferenceDate
//            let offsetX = CGFloat(sin(date / 4) * 20)
//            let offsetY = CGFloat(cos(date / 6) * 20)
            ZStack{
                Color.black.opacity(0.05)
                    .edgesIgnoringSafeArea(.all)
                Image("light_rays")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(x: animate ? 20 : 40, y: animate ? -40 : 0)
                    //.offset(x: offsetX, y: offsetY)
                    .animation(
                        Animation.easeInOut(duration: 4).repeatForever(autoreverses: true),
                        value: animate
                    )
                    .blendMode(.screen)
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onAppear {
                        animate = false // 애니메이트 한 번 껐다가 다시 켜서 애니메이션 리셋, 다시 시작되도록.
                        DispatchQueue.main.async {
                            animate = true
                        }
                    }
                Image("light_dots")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(x: animate ? -5 : 20, y: animate ? 0 : 50)
                    //.offset(x: -offsetX / 2, y: offsetY / 2)

                    .animation(
                        Animation.easeInOut(duration: 8).repeatForever(autoreverses: true),
                        value: animate
                    )
            }
        //}
    }
}

#Preview {
    LightRayView()
}
