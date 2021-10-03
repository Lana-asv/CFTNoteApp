//
//  EnterNoteViewController.swift
//  NotesApp
//
//  Created by Sveta on 24.09.2021.
//  Copyright © 2021 Sveta. All rights reserved.
//

import UIKit

final class EnterNoteViewController: UIViewController, KeyboardInfoControllerDelegate {
    @IBOutlet private weak var titleFieldNoteEdite: UITextField!
    @IBOutlet private weak var noteFieldNoteEdite: UITextView!
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var bottomOffsetConstraint: NSLayoutConstraint!

    private let keyboardInfoController = KeyboardInfoController()

    private var noteItem: NoteItem?
    
    func setupNote(_ note: NoteItem) {
        self.noteItem = note
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButton))

        noteFieldNoteEdite.font = UIFont.systemFont(ofSize: 20)
        titleFieldNoteEdite.becomeFirstResponder()
        titleFieldNoteEdite?.text = noteItem?.title
        noteFieldNoteEdite?.attributedText = noteItem?.text
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardInfoController.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardInfoController.delegate = nil
    }
    
    @objc func saveButton() {
        guard let title = titleFieldNoteEdite.text, !title.isEmpty, !noteFieldNoteEdite.text.isEmpty else {
            return
        }

        if let identifier = noteItem?.identifier {
            NotesStorage.shared.updateNote(identifier: identifier, title: title, text: noteFieldNoteEdite.attributedText)
        } else {
            NotesStorage.shared.saveNote(title: title, text: noteFieldNoteEdite.attributedText)
        }

        navigationController?.popViewController(animated: true)
    }
   
    @IBAction func sizeFontChange(_ sender: Any) {
        let fontSize = CGFloat(slider.value)
        setFontSize(fontSize)
        noteFieldNoteEdite.sizeToFit()
    }

    func setFontSize(_ fontSize: CGFloat) {
        guard let noteTextView = noteFieldNoteEdite, let attributedString = noteTextView.attributedText else {
            return
        }

        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.enumerateAttribute(.font, in: range, options: []) { (font, range, pointee) in
            let newFont: UIFont
            if let font = font as? UIFont {
                newFont = UIFont(descriptor: font.fontDescriptor, size: fontSize)
            } else {
                newFont = UIFont.systemFont(ofSize: fontSize, weight: .regular)
            }

            noteTextView.textStorage.removeAttribute(.font, range: range)
            noteTextView.textStorage.addAttributes([.font : newFont], range: range)
        }
    }

    @IBAction func boldButton(_ sender: Any) {
        guard let noteTextView = noteFieldNoteEdite, let attributedString = noteTextView.attributedText else {
            return
        }

        let selectedRange = noteTextView.selectedRange
        var containsAttribute = false
        attributedString.enumerateAttribute(.font, in: selectedRange, options: []) { (font, range, pointee) in
            if let font = font as? UIFont {
                containsAttribute = containsAttribute || font.fontDescriptor.symbolicTraits.contains(.traitBold)
            } else {
                containsAttribute = false
            }
        }

        attributedString.enumerateAttribute(.font, in: selectedRange, options: []) { (font, range, pointee) in
            let newFont: UIFont
            if let font = font as? UIFont {
                var symbolicTraits = font.fontDescriptor.symbolicTraits
                    if containsAttribute {
                        symbolicTraits = symbolicTraits.subtracting(.traitBold)
                    } else {
                        symbolicTraits.update(with: .traitBold)
                    }
                if let fontDescriptor = font.fontDescriptor.withSymbolicTraits(symbolicTraits) {
                    newFont = UIFont(descriptor: fontDescriptor, size: font.pointSize)
                } else {
                    newFont = UIFont.systemFont(ofSize: 20, weight: containsAttribute ? .regular: .bold)
                }
            } else {
                newFont = UIFont.systemFont(ofSize: 20, weight: containsAttribute ? .regular: .bold)
            }

            noteTextView.textStorage.removeAttribute(.font, range: range)
            noteTextView.textStorage.addAttributes([.font : newFont], range: range)
        }
    }
    
    @IBAction func italicButton(_ sender: Any) {
        guard let noteTextView = noteFieldNoteEdite, let attributedString = noteTextView.attributedText else {
            return
        }

        let selectedRange = noteTextView.selectedRange
        var containsAttribute = false
        attributedString.enumerateAttribute(.font, in: selectedRange, options: []) { (font, range, pointee) in
            if let font = font as? UIFont {
                containsAttribute = containsAttribute || font.fontDescriptor.symbolicTraits.contains(.traitItalic)
            } else {
                containsAttribute = false
            }
        }

        attributedString.enumerateAttribute(.font, in: selectedRange, options: []) { (font, range, pointee) in
            let newFont: UIFont
            if let font = font as? UIFont {
              var symbolicTraits = font.fontDescriptor.symbolicTraits
                if containsAttribute {
                    symbolicTraits = symbolicTraits.subtracting(.traitItalic)
                } else {
                    symbolicTraits.update(with: .traitItalic)
                }
              if let fontDescriptor = font.fontDescriptor.withSymbolicTraits(symbolicTraits) {
                newFont = UIFont(descriptor: fontDescriptor, size: font.pointSize)
              } else {
                newFont = UIFont.systemFont(ofSize: 20, weight: .regular)
              }
            } else {
              newFont = UIFont.systemFont(ofSize: 20, weight: .regular)
            }

            noteTextView.textStorage.removeAttribute(.font, range: range)
            noteTextView.textStorage.addAttributes([.font : newFont], range: range)
        }
    }
    
    @IBAction func underlineButton(_ sender: Any) {
        guard let noteTextView = noteFieldNoteEdite, let attributedString = noteTextView.attributedText else {
            return
        }

        let selectedRange = noteTextView.selectedRange
        var containsUnderlineStyle = false
        attributedString.enumerateAttributes(in: NSRange(location: 0, length: attributedString.length), options: []) { (attributes, range, value) in
            containsUnderlineStyle = containsUnderlineStyle || attributes.keys.contains(.underlineStyle)
        }

        if containsUnderlineStyle {
            noteTextView.textStorage.removeAttribute(.underlineStyle, range: selectedRange)
        } else {
            noteTextView.textStorage.addAttributes([.underlineStyle : NSUnderlineStyle.single.rawValue], range: selectedRange)
        }
    }

  // KeyboardInfoController

    func keyboardInfoController(_ controller: KeyboardInfoController, willShowWithInfo info: KeyboardInfo) {
        let keyboardHeight = view.convert(info.keyboardFrame, from: nil).height
        bottomOffsetConstraint.constant = keyboardHeight
        UIView.animate(withDuration: info.animationDuration, delay: 0.0, options: info.animationOptions, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    func keyboardInfoController(_ controller: KeyboardInfoController, willHideWithInfo info: KeyboardInfo) {
        bottomOffsetConstraint.constant = 20.0
        UIView.animate(withDuration: info.animationDuration, delay: 0.0, options: info.animationOptions, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
