//
//  SignUpViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 01/08/22.
//

import UIKit
import RxCocoa
import RxSwift

class SignUpViewController: UIViewController {
  @IBOutlet weak var userNameField: InputField!
  @IBOutlet weak var emailField: InputField!
  @IBOutlet weak var passwordField: InputField!
  @IBOutlet weak var registryButton: FormSubmitButton!
  @IBOutlet weak var scrollView: UIScrollView!
  
  private var presenter: SignUpPresenterProtocol
  private let keyboardResponder = KeyboardResponder()
  private let disposeBag = DisposeBag()
  
  static func createFromStoryboard(presenter: SignUpPresenterProtocol = SignUpPresenter()) -> SignUpViewController {
    let name = String(describing: SignUpViewController.self)
    let storyboard = UIStoryboard(name: name, bundle: nil)
    return storyboard.instantiateViewController(identifier: name) { coder in
      SignUpViewController(coder: coder, presenter: presenter)
    }
  }
  
  init?(coder: NSCoder, presenter: SignUpPresenterProtocol) {
    self.presenter = presenter
    super.init(coder: coder)
    self.presenter.viewController = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Sign Up"
    setupView()
    setupNameTextFieldCharacterLimiter()
    setupKeyboardInterruptionHandler()
    presenter.setupFormValidation(
      nameText: userNameField.textField.rx.text.orEmpty.share(),
      emailText: emailField.textField.rx.text.orEmpty.share(),
      passwordText: passwordField.textField.rx.text.orEmpty.share())
  }
  
  private func setupView() {
    userNameField.fieldLabel.text = "User Name"
    userNameField.textField.placeholder = "Max. 20 characters"
    emailField.fieldLabel.text = "Email"
    emailField.textField.placeholder = EMAIL_PLACEHOLDER_TEXT
    emailField.textField.keyboardType = .emailAddress
    passwordField.fieldLabel.text = "Password"
    passwordField.textField.placeholder = PASSWORD_PLACEHOLDER_TEXT
    passwordField.textField.autocorrectionType = .no
    passwordField.textField.isSecureTextEntry = true
    registryButton.configuration?.title = REGISTRY_BUTTON_TITLE
    registryButton.disable()
  }
  
  private func setupNameTextFieldCharacterLimiter() {
    let MAX_CHARACTER_COUNT_FOR_NAME = 20
    userNameField.textField.rx.controlEvent(.editingChanged)
      .subscribe(onNext: { [weak self] in
        guard let text = self?.userNameField.textField.text else { return }
        self?.userNameField.textField.text = String(text.prefix(MAX_CHARACTER_COUNT_FOR_NAME))
      })
      .disposed(by: disposeBag)
  }
  
  private func setupKeyboardInterruptionHandler() {
    keyboardResponder.keyboardHeight
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] height in
        self?.scrollView.contentInset.bottom = height
      }
      .disposed(by: disposeBag)
  }
  
  @IBAction func didTapRegistryButton(_ sender: UIButton) {
    presenter.submitForm()
  }
}
