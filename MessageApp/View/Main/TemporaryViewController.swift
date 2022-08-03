//
//  TemporaryViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 03/08/22.
//

import UIKit

class TemporaryViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  @IBAction func logoutButton(_ sender: UIButton) {
    KeychainHelper.shared.deleteMessageAppTerrarestaAccessToken()
    let viewControllerName = String(describing: TopViewController.self)
    let storyboard = UIStoryboard(name: viewControllerName, bundle: nil)
    let topViewController = storyboard.instantiateViewController(identifier: viewControllerName) { coder in
      return TopViewController(coder: coder, presenter: TopPresenter())
    }
    replaceRootViewController(with: UINavigationController(rootViewController: topViewController))
  }
  
}
