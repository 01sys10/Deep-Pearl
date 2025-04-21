//
//  SwimmingGoshaView.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/11/25.
//

import SwiftUI

struct SwimmingGoshaView: View {
    var fishLevel: Int
    @State private var frameIndex = 0
    private let timer = Timer.publish(every: 0.6, on: .main, in: .common).autoconnect()

    var body: some View {
        let baseName = "gosha_lv\(fishLevel)_"
        let frames = [baseName + "1", baseName + "2"]
        Image(frames[frameIndex])
            .interpolation(.none) // 픽셀아트 선명하게
            .resizable()
            .frame(width: fishLevel > 2 ? 220 : 180,
                   height: fishLevel > 2 ? 220 : 180)
            .onReceive(timer) { _ in
                frameIndex = (frameIndex + 1) % frames.count
            }
    }
}

#Preview {
    SwimmingGoshaView(fishLevel: 1)
}
