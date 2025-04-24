//
//  TutorialView.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/23/25.
//

import SwiftUI

struct TutorialView: View {
    @Binding var isPresented: Bool
    @State private var currentStep = 0
    @State private var hasPearlRisen = false

    let steps = [
        "플러스 버튼을 눌러\n오늘 감사했던 일을 간단히 기록해보세요.",
        "기록은 분홍 진주가 되어 바닷속에 가라앉아요.\n일주일이 지나면 노란 진주가 되어 떠오릅니다.",
        "떠오른 진주를 터치하면\n지난 감사를 상기할 수 있어요.\n\n상기를 마치면 고샤가 아름답게 자라납니다🦈",
        "오른쪽 위 상자 버튼으로\n지난 감사 기록을 확인할 수 있어요.",
        "감사한 순간을 소중히 저장하고 다시 꺼내어 보며\n자라나는 긍정과 회복을 경험해보시길 바랍니다.",
    ]

    var body: some View {
        ZStack {
            Image("tutorial_back")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
 
            Text(steps[currentStep])
                .font(.system(size: 16, weight: .bold))
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(11)
                .frame(maxWidth: .infinity)
                .position(x: UIScreen.main.bounds.width / 2, y: 320)

            if currentStep == 1 {
                Image(hasPearlRisen ? "pearl_yellow" : "pearl_pink")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .offset(y: hasPearlRisen ? -320 : 220)
                    .animation(
                        .easeOut(duration: 2.5),
                        value: hasPearlRisen
                    )
            }

            VStack {
                Spacer()

                Button(action: {
                    if currentStep == 1 {
                        if !hasPearlRisen {
                            withAnimation(.easeOut(duration: 0.1)) {
                                hasPearlRisen = true
                            }
                            return
                        }
                    }

                    if currentStep < steps.count - 1 {
                        withAnimation {
                            currentStep += 1
                            hasPearlRisen = false
                        }
                    } else {
                        isPresented = false
                    }
                }) {
                    Text(currentStep < steps.count - 1 ? "다음" : "감사 기록 시작하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 60)
                        .padding(.vertical, 22)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(.vertical, 22)

                }

                Button("건너뛰기") {
                    isPresented = false
                }
                .font(.footnote)
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 16)
            }
        }
        .transition(.opacity)
    }
}

#Preview {
    TutorialView(isPresented: .constant(true))
}
