//
//  DataManager.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/16/25.
//

// 뷰모델로 바꿀까 흠흠 ObservableObject로 no~
import SwiftData
import Foundation

struct DataManager {
    
    static func saveNote(text: String, in context: ModelContext) {
        let newNote = ThankNote(note: text, timestamp: .now)
        context.insert(newNote)
        try? context.save()
    }
    
    static func deleteNote(_ note: ThankNote, in context: ModelContext) {
        context.delete(note)
        try? context.save()
    }
    
    static func updateNote(_ note: ThankNote, newText: String, in context: ModelContext) {
        note.note = newText
        try? context.save()
    }
    
    // 덮어쓰기
    // saveNote함수랑 합쳐버릴까
    static func replaceNote(text: String, in context: ModelContext){
        let todayStart = Calendar.current.startOfDay(for: Date())
        let todayEnd = Calendar.current.date(byAdding: .day, value: 1, to: todayStart)!
        
        // FetchDescriptor: SwiftData에서 원하는 데이터를 찾아올 때(fetch) 사용하는 요청 정보
        // “어떤 기준으로 어떤 데이터를 가져올지” 를 SwiftData에게 알려주는 역할
        let fetch = FetchDescriptor<ThankNote>(
            predicate: #Predicate {
                $0.timestamp >= todayStart && $0.timestamp < todayEnd // 오늘 작성한 것만 가져와
            }
        )
        if let existingNote = try? context.fetch(fetch).first {
            context.delete(existingNote) // 오늘의 기록이 있으면 삭제
        }

        let newNote = ThankNote(note: text, timestamp: .now) // 새로운 감사 기록 생성
        context.insert(newNote)

        try? context.save()
    }
    
    static func deleteAllNotes(in context: ModelContext) {
        let descriptor = FetchDescriptor<ThankNote>()
        if let notes = try? context.fetch(descriptor) {
            for note in notes {
                context.delete(note)
            }
            try? context.save()
        }
    }
}
