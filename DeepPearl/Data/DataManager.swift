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
    
    static func saveNote(text: String, in context: ModelContext) { // create & save
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
    
    static func replaceNote(text: String, in context: ModelContext){
        let todayStart = Calendar.current.startOfDay(for: Date())
        let todayEnd = Calendar.current.date(byAdding: .day, value: 1, to: todayStart)!
        
        let fetch = FetchDescriptor<ThankNote>(
            predicate: #Predicate {
                $0.timestamp >= todayStart && $0.timestamp < todayEnd
            }
        )
        if let existingNote = try? context.fetch(fetch).first {
            context.delete(existingNote)
        }

        let newNote = ThankNote(note: text, timestamp: .now)
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
