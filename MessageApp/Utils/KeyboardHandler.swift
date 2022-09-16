//
//  KeyboardHandler.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 03/08/22.
//

import UIKit
import RxSwift

final class KeyboardResponder {
  static let SOME_ADDITIONAL_PADDING: CGFloat = 20.0
  
  private var notificationCenter: NotificationCenter
  private let keyboardHeightSubject = PublishSubject<CGFloat>()
  
  var keyboardHeight: Observable<CGFloat> {
    keyboardHeightSubject.asObservable()
  }
  
  init(center: NotificationCenter = .default) {
    notificationCenter = center
    notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  deinit {
    notificationCenter.removeObserver(self)
    keyboardHeightSubject.onCompleted()
  }
  
  @objc func keyBoardWillShow(notification: Notification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
      keyboardHeightSubject.onNext(keyboardSize.height + Self.SOME_ADDITIONAL_PADDING)
    }
  }
  
  @objc func keyBoardWillHide(notification: Notification) {
    keyboardHeightSubject.onNext(.zero)
  }
}
