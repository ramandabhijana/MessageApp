//
//  LoginViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 01/08/22.
//

import UIKit
import RxSwift

class LoginViewController: UIViewController {
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var emailTextField: InputTextField!
  @IBOutlet weak var passwordTextField: InputTextField!
  @IBOutlet weak var submitButton: FormSubmitButton!
  
  private var presenter: LoginPresenterProtocol
  private let keyboardResponder = KeyboardResponder()
  private let disposeBag = DisposeBag()
  
  static func createFromStoryboard(presenter: LoginPresenterProtocol = LoginPresenter()) -> LoginViewController {
    let name = String(describing: LoginViewController.self)
    let storyboard = UIStoryboard(name: name, bundle: nil)
    return storyboard.instantiateViewController(identifier: name) { coder in
      LoginViewController(coder: coder, presenter: presenter)
    }
  }
  
  init?(coder: NSCoder, presenter: LoginPresenterProtocol) {
    self.presenter = presenter
    super.init(coder: coder)
    self.presenter.viewController = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Login"
    setupView()
    setupKeyboardInterruptionHandler()
    presenter.setupFormValidation(
      emailText: emailTextField.rx.text.orEmpty.share(),
      passwordText: passwordTextField.rx.text.orEmpty.share())
  }
  
  private func setupView() {
    emailTextField.fieldName = "Email"
    emailTextField.keyboardType = .emailAddress
    passwordTextField.fieldName = "Password"
    passwordTextField.isSecureTextEntry = true
    submitButton.configuration?.title = LOGIN_BUTTON_TITLE
    submitButton.disable()
  }
  
  private func setupKeyboardInterruptionHandler() {
    keyboardResponder.keyboardHeight
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] height in
        self?.scrollView.contentInset.bottom = height
      }
      .disposed(by: disposeBag)
  }
  
  @IBAction func didTapSubmitButton(_ sender: Any) {
    presenter.submitForm()
  }
}
