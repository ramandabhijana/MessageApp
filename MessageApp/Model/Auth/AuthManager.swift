//
//  AuthManager.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 22/08/22.
//

import Foundation
import RxSwift

class AuthManager {
  static var userExist: Bool {
    guard UserDefaults.standard.bool(forKey: IS_LOGGED_IN_KEY) else { return false }
    let authData = KeychainHelper.shared.read(service: AUTH_SERVICE, account: TERRARESTA_ACCOUNT)
    return authData != nil
  }
  
  static var accessToken: Result<String, AuthError> {
    if let token = KeychainHelper.shared.read(service: AUTH_SERVICE, account: TERRARESTA_ACCOUNT, type: LoggedInAuth.self)?.accessToken {
      return Result.success(token)
    }
    return Result.failure(.missingCreddential)
  }
  
  static var userId: Result<Int, AuthError> {
    if let id = KeychainHelper.shared.read(service: AUTH_SERVICE, account: TERRARESTA_ACCOUNT, type: LoggedInAuth.self)?.userId {
      return Result.success(id)
    }
    return Result.failure(.missingCreddential)
  }
  
  static func login(email: String, password: String) -> Observable<Void> {
    let loginRequest = LoginRequest(email: email, password: password)
    return TerrarestaAPIClient.performRequest(loginRequest)
      .do(onNext: { response in
        let authData = LoggedInAuth(accessToken: response.accessToken!, userId: response.userId)
        cacheAuthData(authData)
      })
      .map { _ in () }
  }
  
  static func signup(nickname: String, email: String, password: String) -> Observable<Void> {
    let registryRequest = RegistryRequest(email: email, password: password, nickname: nickname)
    return TerrarestaAPIClient.performRequest(registryRequest)
      .do(onNext: { response in
        let authData = LoggedInAuth(accessToken: response.accessToken!, userId: response.userId)
        cacheAuthData(authData)
      })
      .map { _ in () }
  }
  
  static func logout() {
    KeychainHelper.shared.delete(service: AUTH_SERVICE, account: TERRARESTA_ACCOUNT)
    UserDefaults.standard.set(false, forKey: IS_LOGGED_IN_KEY)
  }
  
  static func deleteAccount() -> Observable<Void> {
    switch accessToken {
    case .success(let token):
      let request = DeleteAccountRequest(accessToken: token)
      return TerrarestaAPIClient.performRequest(request)
        .do(onNext: { _ in logout() })
        .map { _ in () }
    case .failure(let error):
      return Observable.error(error)
    }
  }
  
  private static func cacheAuthData(_ authData: LoggedInAuth) {
    KeychainHelper.shared.save(authData, service: AUTH_SERVICE, account: TERRARESTA_ACCOUNT)
    UserDefaults.standard.set(true, forKey: IS_LOGGED_IN_KEY)
  }
}
