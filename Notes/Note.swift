//
//  Note.swift
//  Notes
//
//  Created by JoyDev on 21.11.2023.
//

import Foundation

struct Note: Codable {
    var text: String
    var noteID: UUID
    var data: Data?
    
    init(text: String, data: Data? = nil) {
        self.text = text
        self.noteID = UUID()
        self.data = data
    }
}

class NoteManager {
    static let shared = NoteManager()
    private let userDefaults = UserDefaults.standard
    private let notesKey = "notes"

    func save(note: Note) {
        var notes = getNotes()
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(note) {
            notes.append(encoded)
            userDefaults.set(notes, forKey: notesKey)
            userDefaults.synchronize()
        }
    }

    func getNotes() -> [Data] {
        return userDefaults.array(forKey: notesKey) as? [Data] ?? []
    }

    func getNote(byID id: UUID) -> Note? {
        let notesData = getNotes()
        let decoder = JSONDecoder()
        for noteData in notesData {
            if let note = try? decoder.decode(Note.self, from: noteData), note.noteID == id {
                return note
            }
        }
        return nil
    }
    
    func update(note: Note) {
            var notesData = getNotes()
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()
            
            if let index = notesData.firstIndex(where: { data -> Bool in
                if let storedNote = try? decoder.decode(Note.self, from: data) {
                    return storedNote.noteID == note.noteID
                }
                return false
            }) {
                if let encoded = try? encoder.encode(note) {
                    notesData[index] = encoded
                    userDefaults.set(notesData, forKey: notesKey)
                    userDefaults.synchronize()
                }
            }
    }
    
    func removeNote(at index: Int) {
            var notesData = getNotes()
            notesData.remove(at: index)
            userDefaults.set(notesData, forKey: notesKey)
            userDefaults.synchronize()
    }
}
