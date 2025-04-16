//
//  DataManager.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/16/25.
//

import SwiftData

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
