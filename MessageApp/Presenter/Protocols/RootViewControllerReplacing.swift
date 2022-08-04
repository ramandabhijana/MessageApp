//
//  RootViewControllerReplacing.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 04/08/22.
//

import UIKit

protocol RootViewControllerReplacing: AnyObject {
  func replaceRootViewControllerWithMainTabViewController()
  func replaceRootViewControllerWithTopViewController()
}

extension RootViewControllerReplacing {
  func replaceRootViewControllerWithMainTabViewController() {
    let mainTabViewController = MainTabViewController.createFromStoryboard()
    replaceRootViewController(with: mainTabViewController)
  }
  
  func replaceRootViewControllerWithTopViewController() {
    let topViewController = TopViewController.createFromStoryboard()
    replaceRootViewController(with: topViewController)
  }
  
  private func replaceRootViewController(with aViewController: UIViewController) {
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


