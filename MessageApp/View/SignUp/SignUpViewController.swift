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
  @IBOutlet weak var userNameTextField: InputTextField!
  @IBOutlet weak var emailTextField: InputTextField!
  @IBOutlet weak var passwordTextField: InputTextField!
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
      nameText: userNameTextField.rx.text.orEmpty.share(),
      emailText: emailTextField.rx.text.orEmpty.share(),
      passwordText: passwordTextField.rx.text.orEmpty.share())
  }
  
  private func setupView() {
    userNameTextField.fieldName = "User Name"
    emailTextField.fieldName = "Email"
    emailTextField.keyboardType = .emailAddress
    passwordTextField.fieldName = "Password"
    passwordTextField.isSecureTextEntry = true
    registryButton.configuration?.title = REGISTRY_BUTTON_TITLE
    registryButton.disable()
  }
  
  private func setupNameTextFieldCharacterLimiter() {
    userNameTextField.rx.controlEvent(.editingChanged)
      .subscribe(onNext: { [weak self] in
        guard let text = self?.userNameTextField.text else { return }
        self?.userNameTextField.text = String(text.prefix(MAX_CHARACTER_COUNT_FOR_NAME))
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
