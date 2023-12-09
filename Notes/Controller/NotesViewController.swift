//
//  NotesViewController.swift
//  Notes
//
//  Created by JoyDev on 21.11.2023.
//

import UIKit
import SnapKit


protocol NotesDelegate: AnyObject {
    func updateNotes()
}

class NotesViewController: UIViewController {

    private let noteManager = NoteManager.shared
    private let addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .yellow
        button.tintColor = .black
        button.layer.cornerRadius = 56 / 2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addNoteTapped), for: .touchUpInside)
        button.setTitle("+", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 35)
        return button
    }()
    
    private let singOutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.tintColor = .black
        button.layer.cornerRadius = 5 / 2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(singOutTapped), for: .touchUpInside)
        button.setTitle("Выйти", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return button
    }()
    
    let tableView = UITableView()
    private var notes: [Note] = []
    let lightYellowColor = UIColor(red: 241/255, green: 235/255, blue: 228/255, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        configureTableView()
        setAddButtonConstraints()
        loadNotes()
        firstNoteInit()
        singOutButtonConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
        }

        @objc private func appWillEnterBackground() {
            let alert = UIAlertController(title: "Выход", message: "Вы уверены, что хотите выйти?", preferredStyle: .alert)
          
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
          
            let exitAction = UIAlertAction(title: "Выйти", style: .destructive) { _ in
                
                exit(0)
            }
            alert.addAction(exitAction)
          
            present(alert, animated: true, completion: nil)
        }

        deinit {
            NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        }

    private func loadNotes() {
        notes = noteManager.getNotes()
    }

    private func saveNotes() {
        for note in notes {
            noteManager.save(note: note)
        }
    }

    private func deleteNote(index: Int) {
        noteManager.removeNote(byID: notes[index].noteID)
        notes.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    private func firstNoteInit() {
        if notes.isEmpty {
            let firstNote = Note(text: "Привет!", noteID: UUID())
            notes.append(firstNote)
            saveNotes()
            tableView.reloadData()
        }
    }

    private func setAddButtonConstraints() {
        view.addSubview(addButton)
        addButton.snp.makeConstraints { maker in
            maker.width.height.equalTo(65)
            maker.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            maker.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    private func singOutButtonConstraints() {
        view.addSubview(singOutButton)
        singOutButton.snp.makeConstraints { maker in
            maker.height.equalTo(25)
            maker.width.equalTo(45)
            maker.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            maker.left.equalToSuperview().offset(20)
        }
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .zero
        tableView.backgroundColor = lightYellowColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        setTableViewConstraints()
    }

    private func setTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.snp.makeConstraints { maker in
            maker.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            maker.bottom.left.right.equalToSuperview()
        }
    }



    @objc private func addNoteTapped() {
        let newNote = Note(text: "Empty Note", noteID: UUID())
        notes.append(newNote)
        saveNotes()
        tableView.reloadData()
    }
    
    @objc private func singOutTapped() {
        let alertController = UIAlertController(title: "Выйти!", message: "Выйти из", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "приложения", style: .default, handler: { _ in
            exit(0)
        }))
        
        alertController.addAction(UIAlertAction(title: "аккаунта", style: .default, handler: { _ in
            
            UserDefaults.standard.set(false, forKey: "isLoggedIn") 
            self.dismiss(animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "отмена", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}

extension NotesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = notes[indexPath.row].text
        cell.backgroundColor = .white
        //lightYellowColor
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ac = UIAlertController(title: "Удалить заметку?", message: "Это действие нельзя отменить", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                self.deleteNote(index: indexPath.row)
            }))
            ac.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            present(ac, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sketchViewController = SketchViewController()
        sketchViewController.delegate = self
        sketchViewController.note = notes[indexPath.row]
        present(sketchViewController, animated: true, completion: nil)
    }
}

extension NotesViewController: NotesDelegate {
    func updateNotes() {
        loadNotes()
        tableView.reloadData()
    }
}
