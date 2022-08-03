//
//  ViewController+.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 02/08/22.
//

import UIKit

extension UIViewController {
  func showAlert(title: String, message: String?) {
    let alertDialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertDialog.addAction(ok)
    self.present(alertDialog, animated: true, completion: nil)
  }
  
  func replaceRootViewController(with aViewController: UIViewController) {
    let keyWindow = UIApplication.shared.connectedScenes
      .filter { $0.activationState == .foregroundActive }
      .first(where: { $0 is UIWindowScene })
      .flatMap({ $0 as? UIWindowScene })?
      .windows
      .first(where: \.isKeyWindow)
    
    guard let keyWindow = keyWindow else { fatalError("KeyWindow is not found") }
    
    let snapshot = keyWindow.snapshotView(afterScreenUpdates: true)!
    aViewController.view.addSubview(snapshot)
    
    keyWindow.rootViewController = aViewController
    
    UIView.transition(
      with: snapshot,
      duration: 0.4,
      options: .transitionCrossDissolve,
      animations: {
        snapshot.layer.opacity = 0
      },
      completion: { _ in
        snapshot.removeFromSuperview()
    })
  }
}
