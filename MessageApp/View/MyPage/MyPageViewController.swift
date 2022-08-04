//
//  MyPageViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 03/08/22.
//

import UIKit

class MyPageViewController: UIViewController {
  static func createFromStoryboard(presenter: MyPagePresenterProtocol = MyPagePresenter()) -> MyPageViewController {
    let name = String(describing: MyPageViewController.self)
    let storyboard = UIStoryboard(name: name, bundle: nil)
    return storyboard.instantiateViewController(identifier: name) { coder in
      MyPageViewController(coder: coder, presenter: presenter)
    }
  }
  
  private static let LOGOUT_BTN_TITLE = "Logout"
  
  private var presenter: MyPagePresenterProtocol
  
  init?(coder: NSCoder, presenter: MyPagePresenterProtocol) {
    self.presenter = presenter
    super.init(coder: coder)
    self.presenter.viewController = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = APP_NAME
    setupLogoutButton()
  }
  
  private func setupLogoutButton() {
    let button = UIBarButtonItem(
      title: Self.LOGOUT_BTN_TITLE,
      style: .plain,
      target: self,
      action: #selector(didTapLogout))
    button.tintColor = COLOR_APP_GREEN
    navigationItem.rightBarButtonItem = button
  }
  
  @objc private func didTapLogout() {
    let actions = [
      UIAlertAction(title: "Cancel", style: .cancel),
      UIAlertAction(title: "Continue", style: .destructive, handler: { [weak self] _ in
        self?.presenter.logout()
      })
    ]
    showAlert(title: "Log out",
              message: "You are about to log out. Continue?",
              actions: actions)
  }
}
