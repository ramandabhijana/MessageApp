//
//  LoginPresenter.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 03/08/22.
//

import Foundation
import RxSwift

protocol LoginPresenterProtocol {
  var viewController: LoginViewController? { get set }
  var canSubmitForm: Bool { get }
  
  func setupFormValidation(emailText: Observable<String>, passwordText: Observable<String>)
  func submitForm()
}

class LoginPresenter: LoginPresenterProtocol, RootViewControllerReplacing {
  weak var viewController: LoginViewController?
  
  private(set) var canSubmitForm: Bool = false
  private let disposeBag = DisposeBag()
  
  func setupFormValidation(emailText: Observable<String>, passwordText: Observable<String>) {
    setupInputFieldsValidation(emailText: emailText, passwordText: passwordText)
    setupEmptyFieldsValidation(emailText: emailText, passwordText: passwordText)
  }
  
  func submitForm() {
    guard canSubmitForm else {
      viewController?.showUnsatisfiedInputAlert()
      return
    }
    viewController?.submitButton.showLoading()
    AuthManager.login(
      email: (viewController?.emailTextField.text)!,
      password: (viewController?.passwordTextField.text)!
    )
    .subscribe(
      onNext: { [weak self] _ in
        self?.replaceRootViewControllerWithMainTabViewController()
      },
      onError: { [weak self] error in
        self?.viewController?.showError(error)
        self?.viewController?.submitButton.enable()
      }
    )
    .disposed(by: disposeBag)
  }
  
}

// MARK: - Validation
private extension LoginPresenter {
  func setupInputFieldsValidation(emailText: Observable<String>,
                                  passwordText: Observable<String>) {
    let emailValid = emailText.map(\.isValidEmail)
    let passwordValid = passwordText.map(\.isSecurePassword)
    let allFieldsValid = Observable.combineLatest(emailValid, passwordValid) {
      $0 && $1
    }
    
    emailValid
      .skip(2)
      .subscribe(onNext: { [weak self] emailIsValid in
        self?.viewController?.emailTextField.textFieldState = emailIsValid
          ? .normal
          : .error(message: EMAIL_INCORRECT_FORMAT_MESSAGE)
      })
      .disposed(by: disposeBag)
    
    passwordValid
      .skip(2)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] passwordIsValid in
        self?.viewController?.passwordTextField.textFieldState = passwordIsValid
          ? .normal
          : .error(message: PASSWORD_INCORRECT_FORMAT_MESSAGE)
      })
      .disposed(by: disposeBag)
    
    allFieldsValid
      .subscribe(onNext: { [weak self] allFieldsAreValid in
        self?.canSubmitForm = allFieldsAreValid
      })
      .disposed(by: disposeBag)
  }
  
  func setupEmptyFieldsValidation(emailText: Observable<String>,
                                  passwordText: Observable<String>) {
    let emailEmpty = emailText.map(\.isEmpty)
    let passwordEmpty = passwordText.map(\.isEmpty)
    let fieldsEmpty = Observable.combineLatest(emailEmpty, passwordEmpty) {
      $0 || $1
    }
    fieldsEmpty.subscribe(onNext: { [weak self] allFieldsAreEmpty in
      let submitButton = self?.viewController?.submitButton
      allFieldsAreEmpty
        ? submitButton?.disable()
        : submitButton?.enable()
    })
    .disposed(by: disposeBag)
  }
}
