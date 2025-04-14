//
//  SwimmingGoshaView.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/11/25.
//

import SwiftUI

struct AnimatedGoblinSharkView: View {
    @State private var frameIndex = 0
    private let frames = ["gosha_swimming_1", "gosha_swimming_2"]
    private let timer = Timer.publish(every: 0.6, on: .main, in: .common).autoconnect()

    var body: some View {
        Image(frames[frameIndex])
            .interpolation(.none) // 픽셀아트 선명하게
            .resizable()
            .frame(width: 240, height: 240)
            .onReceive(timer) { _ in
                    frameIndex = (frameIndex + 1) % frames.count
            }
    }
}

#Preview {
    AnimatedGoblinSharkView()
}
