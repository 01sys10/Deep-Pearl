//
//  ThankNotesViewModel.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/14/25.
//

import Foundation
import CoreData
import Combine

class ThankNotesViewModel: ObservableObject {
    @Published var notes: [ThankNote] = []
    
    private let context = PersistenceController.shared.container.viewContext

    func fetchNotes() {
        let request: NSFetchRequest<ThankNote> = ThankNote.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ThankNote.timestamp, ascending: false)]
        
        do {
            notes = try context.fetch(request)
        } catch {
            print("❌ Fetch failed: \(error)")
        }
    }

    func addNote(text: String) {
        let newNote = ThankNote(context: context)
        newNote.note = text
        newNote.timestamp = Date()
        
        do {
            try context.save()
            print("🐥 Saved: \(newNote.note ?? "nil") at \(newNote.timestamp!)")
            fetchNotes()
        } catch {
            print("❌ Save failed: \(error.localizedDescription)")
        }
    }
}

