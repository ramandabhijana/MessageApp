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
  var canLogin: Bool { get }
  
  func setupFormValidation(nameText: Observable<String>, emailText: Observable<String>, passwordText: Observable<String>)
  func submitForm()
}

class SignUpPresenter: SignUpPresenterProtocol {
  weak var viewController: SignUpViewController?
  
  private(set) var canLogin: Bool = false
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
    guard canLogin else {
      viewController?.showAlert(
        title: "Check your input",
        message: "Make sure all are filled in correctly then try again."
      )
      return
    }
    viewController?.registryButton.showLoading()
    // make API request
    let registryRequest = RegistryRequest(
      email: (viewController?.emailField.textField.text)!,
      password: (viewController?.passwordField.textField.text)!,
      nickname: (viewController?.userNameField.textField.text)!
    )
    TerrarestaAPIClient.performRequest(registryRequest)
      .subscribe(
        onNext: { [weak self] response in
          // Save access token
          let accessTokenData = Data(response.accessToken!.utf8)
          KeychainHelper.shared.save(accessTokenData) { success in
            guard success else {
              self?.viewController?.showAlert(
                title: "Error",
                message: "Something went wrong while saving your access token.")
              return
            }
            // Replace the rootViewController
            let mainTabViewController = MainTabViewController.createFromStoryboard()
            self?.viewController?.replaceRootViewController(with: UINavigationController(rootViewController: mainTabViewController))
          }
        },
        onError: { [weak self] error in
          guard let apiError = error as? APIError else { return }
          let title: String
          let message: String?
          switch apiError {
          case .requestFailed(let statusCode):
            title = "Error \(statusCode)"
            message = nil
            break
          case .postProcessingFailed(let error):
            print(error.localizedDescription)
            title = "Internal Error"
            message = "Something went wrong please contact the developer."
          case .noData:
            title = "No Data"
            message = "Seems there is an error with our server."
          case .badResponse(let errorResponse):
            title = errorResponse.titleOrDefault
            message = errorResponse.messageOrDefault
          }
          self?.viewController?.showAlert(title: title, message: message)
          self?.viewController?.registryButton.enable()
        },
        onCompleted: {
          print("\nRegistry request completed\n")
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
      if emailIsValid {
        self?.viewController?.emailField.hideError()
      } else {
        self?.viewController?.emailField.showError(with: "Email is not properly formatted")
      }
    })
    .disposed(by: disposeBag)
    
    passwordValid
      .skip(2)
      .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] passwordIsValid in
        if passwordIsValid {
          self?.viewController?.passwordField.hideError()
        } else {
          self?.viewController?.passwordField.showError(with: "Incorrect password format. Please use 5-9 character alphabets and/or numbers only")
        }
      })
      .disposed(by: disposeBag)
    
    let validFieldsObservable = Observable.combineLatest(emailValid, passwordValid) {
      $0 && $1
    }
    validFieldsObservable.subscribe(onNext: { [weak self] allFieldsAreValid in
      self?.canLogin = allFieldsAreValid
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
