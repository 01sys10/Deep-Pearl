//
//  PersistenceController.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/14/25.
//

// TODO: 

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ThankNotesModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("❌ Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
