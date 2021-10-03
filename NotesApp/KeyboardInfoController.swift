//
//  KeyboardInfoController.swift
//  NotesApp
//
//  Created by Sveta on 24.09.2021.
//  Copyright © 2021 Sveta. All rights reserved.
//

import UIKit

protocol KeyboardInfoControllerDelegate: AnyObject {
    func keyboardInfoController(_ controller: KeyboardInfoController, willShowWithInfo info: KeyboardInfo)
    func keyboardInfoController(_ controller: KeyboardInfoController, willHideWithInfo info: KeyboardInfo)
}

final class KeyboardInfoController {
    weak var delegate: KeyboardInfoControllerDelegate?

    private let notificationCenter = NotificationCenter.default

    init() {
        subscribeForKeyboardNotifications()
    }

    deinit {
        unsubscribeFromKeyboardNotifications()
    }

    private func subscribeForKeyboardNotifications() {
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func unsubscribeFromKeyboardNotifications() {
        notificationCenter.removeObserver(self)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }

        let info = KeyboardInfo(userInfo: userInfo)
        delegate?.keyboardInfoController(self, willShowWithInfo: info)
    }

    @objc private func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }

        let info = KeyboardInfo(userInfo: userInfo)
        delegate?.keyboardInfoController(self, willHideWithInfo: info)
    }
}

struct KeyboardInfo {
    let animationDuration: TimeInterval
    let animationOptions: UIView.AnimationOptions
    let keyboardFrame: CGRect

    init(userInfo: [AnyHashable: Any]) {
        animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let rawAnimationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
        animationOptions = UIView.AnimationOptions(rawValue: UInt(rawAnimationCurve))
    }
}
