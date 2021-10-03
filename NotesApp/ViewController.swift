//
//  ViewController.swift
//  NotesApp
//
//  Created by Sveta on 24.09.2021.
//  Copyright © 2021 Sveta. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private weak var notesTableView: UITableView!

    private let storage = NotesStorage.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Notes"

        notesTableView.delegate = self
        notesTableView.dataSource = self
        
        if storage.items.isEmpty {
            let attributeText = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20) ]
            let noteTextModel = NSAttributedString(string: "First note text", attributes: attributeText)
            storage.saveNote(title: "First note title", text: noteTextModel)
        } else { return }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notesTableView.reloadData()
    }

    @IBAction func createNewNote() {
        guard let vc = storyboard?.instantiateViewController(identifier: "newNoteStoryboard") as? EnterNoteViewController else {
            return
        }
        vc.title = "New Note"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: TableView Configuration
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storage.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notesListCell", for: indexPath)
        let noteItem = storage.items[indexPath.row]
        cell.textLabel?.text = noteItem.title
        cell.detailTextLabel?.text = noteItem.text.string
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let noteItem = storage.items[indexPath.row]
        
        guard let vc = storyboard?.instantiateViewController(identifier: "newNoteStoryboard") as? EnterNoteViewController else { return }
        vc.setupNote(noteItem)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            storage.items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
}



