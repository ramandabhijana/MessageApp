//
//  ViewController+.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 02/08/22.
//

import UIKit

extension UIViewController {
  func showAlert(title: String, message: String?, actions: [UIAlertAction]? = nil) {
    let alertDialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
    if let actions = actions {
      actions.forEach { alertDialog.addAction($0) }
    } else {
      let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
      alertDialog.addAction(ok)
    }
    self.present(alertDialog, animated: true, completion: nil)
  }
  
  func showUnsatisfiedInputAlert() {
    showAlert(title: UNSATISFIED_INPUT_ALERT_TITLE,
              message: UNSATISFIED_INPUT_ALERT_MESSAGE)
  }
}
