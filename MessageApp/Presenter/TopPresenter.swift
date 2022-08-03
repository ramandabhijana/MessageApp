//
//  TopPresenter.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 01/08/22.
//

import Foundation

protocol TopPresenterProtocol {
  var viewController: TopViewController? { get set }
  func registryButtonTapped()
  func loginButtonTapped()
}

class TopPresenter: TopPresenterProtocol {
  weak var viewController: TopViewController?
  
  func registryButtonTapped() {
    let signupViewController = SignUpViewController.createFromStoryboard()
    viewController?.navigationController?.pushViewController(signupViewController, animated: true)
  }
  
  func loginButtonTapped() {
    let loginViewController = LoginViewController()
    viewController?.navigationController?.pushViewController(loginViewController, animated: true)
  }
}
