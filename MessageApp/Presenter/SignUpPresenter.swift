//
//  SignUpPresenter.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 02/08/22.
//

import Foundation
import RxSwift

protocol SignUpPresenterProtocol {
  var viewController: SignUpViewController? { get set }
  var canSubmitForm: Bool { get }
  
  func setupFormValidation(nameText: Observable<String>, emailText: Observable<String>, passwordText: Observable<String>)
  func submitForm()
}

class SignUpPresenter: SignUpPresenterProtocol, RootViewControllerReplacing {
  weak var viewController: SignUpViewController?
  
  private(set) var canSubmitForm: Bool = false
  private let disposeBag = DisposeBag()
  
  func setupFormValidation(
    nameText: Observable<String>,
    emailText: Observable<String>,
    passwordText: Observable<String>
  ) {
    setupInputFieldValidation(emailText: emailText,
                              passwordText: passwordText)
    setupEmptyFieldsValidation(nameText: nameText,
                               emailText: emailText,
                               passwordText: passwordText)
  }
  
  func submitForm() {
    guard canSubmitForm else {
      viewController?.showUnsatisfiedInputAlert()
      return
    }
    viewController?.registryButton.showLoading()
    AuthManager.signup(
      nickname: (viewController?.userNameTextField.text)!,
      email: (viewController?.emailTextField.text)!,
      password: (viewController?.passwordTextField.text)!
    )
    .subscribe(
      onNext: { [weak self] _ in
        self?.replaceRootViewControllerWithMainTabViewController()
      },
      onError: { [weak self] error in
        self?.viewController?.showError(error)
        self?.viewController?.registryButton.enable()
      }
    )
    .disposed(by: disposeBag)
  }
  
  private func setupInputFieldValidation(
    emailText: Observable<String>,
    passwordText: Observable<String>
  ) {
    let emailValid = emailText.map(\.isValidEmail)
    let passwordValid = passwordText.map(\.isSecurePassword)
    
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
      .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] passwordIsValid in
        self?.viewController?.passwordTextField.textFieldState = passwordIsValid
          ? .normal
          : .error(message: PASSWORD_INCORRECT_FORMAT_MESSAGE)
      })
      .disposed(by: disposeBag)
    
    let validFieldsObservable = Observable.combineLatest(emailValid, passwordValid) {
      $0 && $1
    }
    validFieldsObservable.subscribe(onNext: { [weak self] allFieldsAreValid in
      self?.canSubmitForm = allFieldsAreValid
    })
    .disposed(by: disposeBag)
  }
  
  private func setupEmptyFieldsValidation(
    nameText: Observable<String>,
    emailText: Observable<String>,
    passwordText: Observable<String>
  ) {
    let nameEmpty = nameText.map(\.isEmpty)
    let emailEmpty = emailText.map(\.isEmpty)
    let passwordEmpty = passwordText.map(\.isEmpty)
    
    let emptyFieldsObservable = Observable.combineLatest(nameEmpty, emailEmpty, passwordEmpty) {
      $0 || $1 || $2
    }
    emptyFieldsObservable.subscribe(onNext: { [weak self] allFieldsAreEmpty in
      if allFieldsAreEmpty {
        self?.viewController?.registryButton.disable()
      } else {
        self?.viewController?.registryButton.enable()
      }
    })
    .disposed(by: disposeBag)
  }
}
