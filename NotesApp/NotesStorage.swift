//
//  NotesStorage.swift
//  NotesApp
//
//  Created by Sveta on 27.09.2021.
//  Copyright © 2021 Sveta. All rights reserved.
//

import Foundation

final class NotesStorage {
    static private let notesStorageKey = "noteList"
    private let userDefaults = UserDefaults.standard
    
    static let shared = NotesStorage()
    
    var items: [NoteItem] = [] {
        didSet {
            saveItems(items)
        }
    }

    init() {
        items = loadItems() ?? []
    }
    
    private func loadItems() -> [NoteItem]? {
        guard let data = userDefaults.value(forKey: Self.notesStorageKey) as? Data else {
            return nil
        }
        
        return try? PropertyListDecoder().decode([NoteItem].self, from: data)
    }
    
    private func saveItems(_ items: [NoteItem]) {
        guard let data = try? PropertyListEncoder().encode(items) else {
            return
        }

        userDefaults.set(data, forKey: Self.notesStorageKey)
    }
            
    func saveNote(title: String, text: NSAttributedString) {
        let identifier = UUID().uuidString
        let note = NoteItem(identifier: identifier, title: title, text: text)
        items.append(note)
    }
    
    func updateNote(identifier: String, title: String, text: NSAttributedString) {
        let note = NoteItem(identifier: identifier, title: title, text: text)
        if let index = items.firstIndex(where:{ $0.identifier == identifier }) {
            items[index] = note
        }
    }
}

struct NoteItem: Codable {
    let identifier: String
    let title: String
    let text: NSAttributedString
    
    enum CodingKeys: String, CodingKey {
        case identifier, title, text
    }
    
    init(identifier: String, title: String, text: NSAttributedString) {
        self.identifier = identifier
        self.title = title
        self.text = text
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        identifier = try container.decode(String.self, forKey: .identifier)

        let decodedString = try container.decode(AttributedStringContainer.self, forKey: .text)
        text = decodedString.attributedString
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(title, forKey: .title)

        let encodedString = AttributedStringContainer(attributedString: text)
        try container.encode(encodedString, forKey: .text)
    }
}

private struct AttributedStringContainer: Codable {
    let attributedString: NSAttributedString

    init(attributedString: NSAttributedString) {
        self.attributedString = attributedString
    }

    init(from decoder: Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        guard let attributedString = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(singleContainer.decode(Data.self)) as? NSAttributedString else {
            throw DecodingError.dataCorruptedError(in: singleContainer, debugDescription: "Data is corrupted")
        }
        self.attributedString = attributedString
    }

    func encode(to encoder: Encoder) throws {
        var singleContainer = encoder.singleValueContainer()
        try singleContainer.encode(NSKeyedArchiver.archivedData(withRootObject: attributedString, requiringSecureCoding: false))
    }
}
