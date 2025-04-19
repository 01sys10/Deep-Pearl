//
//  DeepPearlApp.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/8/25.
//

import SwiftUI
import SwiftData


@main
struct DeepPearlApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: ThankNote.self)
        // 이 앱의 전체 저장소(ModelContainer) 생성
        // WindowGroup에 붙여서 앱 전체 뷰 계층에 이 모델컨데이너를 공유
        
        // - 모델 스키마 로딩
        // - 저장소 위치 지정
        // - ModelContext 생성 (데이터 저장 수정 삭제하는 실제 작업 공간 생성)
        // - 앱 뷰 계층에 주입 (SwiftUI의 @Environment로 쓸 수 있게 만듦)
        
        // Model container
        // 앱의 스키마 및 모델 저장소 configuration을 관리하는 객체.
        // 패키징한 내용(스키마, configuration). ModelContext와 영구 저장소 사이에 위치, 중개자 역할
        // 모델 타입에 영구적으로 유지되는 백엔드 제공
    }
}
