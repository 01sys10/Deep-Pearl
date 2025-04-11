//
//  LightRayView.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/8/25.
//

import SwiftUI

struct LightRayView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack{
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
            Image("light_rays")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(x: animate ? 20 : 40, y: animate ? -40 : 0)
                .animation(
                    Animation.easeInOut(duration: 4).repeatForever(autoreverses: true),
                    value: animate
                )
                .blendMode(.screen)
                .opacity(0.3)
                .ignoresSafeArea()
                .onAppear {
                    animate = true
                }
            Image("light_dots")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(x: animate ? -5 : 20, y: animate ? 0 : 50)
                .animation(
                    Animation.easeInOut(duration: 8).repeatForever(autoreverses: true),
                    value: animate
                )
        }
    }
}

#Preview {
    LightRayView()
}
