//
//  Note.swift
//  Notes
//
//  Created by JoyDev on 21.11.2023.
//



import Foundation
import CoreData

struct Note: Codable {
    var text: String
    var noteID: UUID
    var data: Data? // Добавлено свойство data
    
    init(text: String, noteID: UUID) {
        self.text = text
        self.noteID = noteID
    }
    
    init(from model: NoteEntity) {
        self.noteID = model.noteID ?? UUID()
        self.text = model.text ?? ""
        self.data = model.data!
    }
}

class NoteManager {
    static let shared = NoteManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func save(note: Note) {
        let managedContext = persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NoteEntity")
            fetchRequest.predicate = NSPredicate(format: "noteID == %@", note.noteID as CVarArg)

            do {
                let results = try managedContext.fetch(fetchRequest)
                if let existingNote = results.first {
                    // Обновление существующей заметки
                    existingNote.setValue(note.text, forKeyPath: "text")
                } else {
                    // Создание новой заметки
                    let entity = NSEntityDescription.entity(forEntityName: "NoteEntity", in: managedContext)!
                    let noteEntity = NSManagedObject(entity: entity, insertInto: managedContext)
                    noteEntity.setValue(note.text, forKeyPath: "text")
                    noteEntity.setValue(note.noteID, forKeyPath: "noteID")
                }

                saveContext()
            } catch let error as NSError {
                print("Failed to save note. \(error), \(error.userInfo)")
            }
    }
    
    func getNotes() -> [Note] {
        var notes: [Note] = []
        let managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NoteEntity")

        do {
            let results = try managedContext.fetch(fetchRequest)
            for noteEntity in results {
                let text = noteEntity.value(forKeyPath: "text") as? String ?? ""
                let noteID = noteEntity.value(forKeyPath: "noteID") as? UUID ?? UUID()
                let note = Note(text: text, noteID: noteID)
                notes.append(note)
            }
        } catch let error as NSError {
            print("Could not fetch notes. \(error), \(error.userInfo)")
        }
        
        return notes
    }
    
    func getNote(byID id: UUID) -> Note? {
        let managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NoteEntity")
        fetchRequest.predicate = NSPredicate(format: "noteID == %@", id as CVarArg)
        
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            if let noteEntity = results.first {
                let text = noteEntity.value(forKeyPath: "text") as? String ?? ""
                let noteID = noteEntity.value(forKeyPath: "noteID") as? UUID ?? UUID()
                
                return Note(text: text, noteID: noteID)
            }
        } catch let error as NSError {
            print("Could not fetch note. \(error), \(error.userInfo)")
        }
        
        return nil
    }
    
    func update(note: Note) {
        let managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NoteEntity")
        fetchRequest.predicate = NSPredicate(format: "noteID == %@", note.noteID as CVarArg)
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            if let noteEntity = results.first {
                noteEntity.setValue(note.text, forKeyPath: "text")
                
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not update note. \(error), \(error.userInfo)")
                }
            }
        } catch let error as NSError {
            print("Could not fetch note. \(error), \(error.userInfo)")
        }
    }
    
    func removeNote(byID id: UUID) {
        let managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NoteEntity")
        fetchRequest.predicate = NSPredicate(format: "noteID == %@", id as CVarArg)
        
        do {
            let item = try managedContext.fetch(fetchRequest)
            for noteEntity in item {
                managedContext.delete(noteEntity)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        saveContext()
    }
}
