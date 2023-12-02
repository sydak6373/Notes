//
//  SketchViewController.swift
//  Notes
//
//  Created by JoyDev on 21.11.2023.
//

import UIKit
import SnapKit

class SketchViewController: UIViewController, UINavigationControllerDelegate {

    weak var delegate: NotesDelegate?
    let textView = UITextView()
    var note: Note!
    var fontSize: CGFloat = 20

    private var text: NSMutableAttributedString?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textView)
        configureTextView()
        configureNotificationCenter()
    }

    private func updateNote() {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            note.text = "Empty note"
        } else {
            if let attributedText = textView.attributedText {
                do {
                    let data = try attributedText.data(
                        from: NSRange(location: 0, length: attributedText.length),
                        documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd]
                    )
                    note.text = textView.text
                    note.data = data
                } catch let error as NSError {
                    print("Error creating rtfd data: \(error)")
                }
            }
        }
        
        NoteManager.shared.update(note: note)
        delegate?.updateNotes()
    }

    private func setTextViewConstraints() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.snp.makeConstraints { maker in
            maker.top.bottom.left.right.equalTo(0)
        }
    }

    private func configureNotificationCenter() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(updateKeyboard),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(updateKeyboard),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    private func configureTextView() {
        if note.data != nil {
            do {
                try textView.attributedText = NSAttributedString(
                    data: note.data!,
                    options: [.documentType: NSAttributedString.DocumentType.rtfd],
                    documentAttributes: nil
                )
            } catch let error as NSError {
                print("Error decoding NSAttributedString from data: \(error)")
            }
        } else {
            textView.text = note.text
            textView.font = UIFont.systemFont(ofSize: fontSize)
        }
        textView.delegate = self
        textView.isEditable = true
        textView.isSelectable = true
        textView.backgroundColor = UIColor(
            red: 253/255,
            green: 249/255,
            blue: 169/255,
            alpha: 1
        )
        textView.allowsEditingTextAttributes = true
        text = NSMutableAttributedString(attributedString: textView.attributedText)
        configureTextViewImage()
        textView.attributedText = text
        setTextViewConstraints()
    }

    private func configureTextViewImage() {
        let width = view.frame.size.width - 10
        text?.enumerateAttribute(
            NSAttributedString.Key.attachment,
            in: NSRange(location: 0, length: textView.attributedText.length),
            options: [],
            using: { [width] (object, range, _) in
                let textViewAsAny: Any = self.textView
                if let attachment = object as? NSTextAttachment, let img = attachment.image(
                    forBounds: self.textView.bounds,
                    textContainer: textViewAsAny as? NSTextContainer,
                    characterIndex: range.location
                ) {
                    guard let fileType = attachment.fileType else { return }
                    if fileType == "public.png" {
                        let aspect = img.size.width / img.size.height
                        if img.size.width <= width {
                            attachment.bounds = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
                            return
                        }
                        let height = width / aspect
                        attachment.bounds = CGRect(
                            x: 0,
                            y: 0,
                            width: width,
                            height: height
                        )
                        attachment.image = img
                    }
                }
            }
        )
    }

    @objc private func updateKeyboard(notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardFrameKey = UIResponder.keyboardFrameEndUserInfoKey
        guard let keyboardValue = userInfo?[keyboardFrameKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: keyboardViewEndFrame.height,
                right: 0
            )
        }
        textView.scrollIndicatorInsets = textView.contentInset
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
}

extension SketchViewController: UITextViewDelegate {

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            note.text = "Empty note"
        } else {
            if let attributedText = textView.attributedText {
                do {
                    let data = try attributedText.data(
                        from: NSRange(location: 0, length: attributedText.length),
                        documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd]
                    )
                    note.text = textView.text
                    note.data = data
                } catch let error as NSError {
                    print("Error creating rtfd data: \(error)")
                }
            }
        }
        
        NoteManager.shared.update(note: note)
        updateNote()
    }
}
