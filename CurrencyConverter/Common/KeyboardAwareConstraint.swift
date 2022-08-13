//
//  KeyboardAwareConstraint.swift
//  CurrencyConverter
//
//  Created by mdubkov on 13.08.2022.
//

import UIKit

class KeyboardAwareConstraint: NSLayoutConstraint {
  private var defaultConst: CGFloat = 0.0
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupKeyboardObservers()
    defaultConst = constant
  }
  
  deinit {
    removeKeyboardObservers()
  }
  
  private func setupKeyboardObservers() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(_keyboardWillShow(notification:)),
                                           name: UIResponder.keyboardWillShowNotification, object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(_keyboardWillHide(notification:)),
                                           name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  private func removeKeyboardObservers() {
    NotificationCenter.default.removeObserver(
      self,
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.removeObserver(
      self,
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
  @objc
  private func _keyboardWillShow(notification: Notification) {
    if let frame: CGRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
      self.keyboardWillShow(frame: frame)
    }
  }
  
  @objc
  private func _keyboardWillHide(notification _: Notification) {
    self.keyboardWillHide()
  }
  
  private func keyboardWillShow(frame keyboardFrame: CGRect) {
    let guide = self.firstItem as? UILayoutGuide ?? self.secondItem as? UILayoutGuide
    let mainHeight = guide?.owningView?.frame.height ?? 0.0
    let safeAreaBottomInset = mainHeight - (guide?.layoutFrame.maxY ?? 0.0)
    constant = defaultConst + keyboardFrame.height - safeAreaBottomInset
  }
  
  private func keyboardWillHide() {
    constant = defaultConst
  }
}
