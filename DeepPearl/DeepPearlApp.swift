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
    }
}
