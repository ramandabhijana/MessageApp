//
//  TopViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 01/08/22.
//

import UIKit

class TopViewController: UIViewController {
  @IBOutlet weak var appNameLabel: UILabel!
  @IBOutlet weak var registryButton: UIButton!
  @IBOutlet weak var loginButton: UIButton!
  
  private var presenter: TopPresenterProtocol
  
  static func createFromStoryboard(presenter: TopPresenterProtocol = TopPresenter()) -> UIViewController {
    let name = String(describing: TopViewController.self)
    let storyboard = UIStoryboard(name: name, bundle: nil)
    let topViewController = storyboard.instantiateViewController(identifier: name) { coder in
      TopViewController(coder: coder, presenter: presenter)
    }
    return UINavigationController(rootViewController: topViewController)
  }
  
  init?(coder: NSCoder, presenter: TopPresenterProtocol) {
    self.presenter = presenter
    super.init(coder: coder)
    self.presenter.viewController = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  @IBAction func didTapRegistryButton(_ sender: UIButton) {
    presenter.registryButtonTapped()
  }
  
  @IBAction func didTapLoginButton(_ sender: UIButton) {
    presenter.loginButtonTapped()
  }
  
  private func setupView() {
    title = " "
    appNameLabel.text = APP_NAME
    setupRegistryButton()
    setupLoginButton()
  }
  
  private func setupRegistryButton() {
    registryButton.setTitle(REGISTRY_BUTTON_TITLE, for: .normal)
    registryButton.tintColor = COLOR_APP_ORANGE
  }
  
  private func setupLoginButton() {
    loginButton.setTitle(LOGIN_BUTTON_TITLE, for: .normal)
    loginButton.tintColor = COLOR_APP_GREEN
  }
}
