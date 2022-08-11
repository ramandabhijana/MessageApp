//
//  ViewController+.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 02/08/22.
//

import UIKit

extension UIViewController {
  func showAlert(title: String, message: String?, actions: [UIAlertAction]? = [UIAlertAction(title: "OK", style: .default, handler: nil)]) {
    let alertDialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
    if let actions = actions {
      actions.forEach { alertDialog.addAction($0) }
    }
    self.present(alertDialog, animated: true, completion: nil)
  }
  
  func showUnsatisfiedInputAlert() {
    showAlert(title: UNSATISFIED_INPUT_ALERT_TITLE,
              message: UNSATISFIED_INPUT_ALERT_MESSAGE)
  }
  
  func showError(content: (title: String, message: String?)) {
    showAlert(title: content.title, message: content.message)
  }
  
  var canPresentCamera: Bool {
    return UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
  }
}
