//
//  MyPageDataSource.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 09/08/22.
//

import Foundation
import RxSwift

protocol MyPageDataSourceProtocol {
  func fetchProfile() -> Observable<ProfileResponse>
  var profileImageURL: URL? { get }
  var email: String? { get }
  var password: String? { get }
  var profileImageIsSet: Bool { get }
  var imageID: Int { get }
}

class MyPageDataSource: MyPageDataSourceProtocol {
  private var profile: ProfileResponse?
  private var profileUnwrapped: ProfileResponse {
    guard let profile = profile else {
      fatalError("profile is nil. Please call `fetchProfile() -> Observable<String?>` first")
    }
    return profile
  }
  
  var profileImageURL: URL? {
    guard let urlString = profileUnwrapped.imageUrl else { return nil }
    return URL(string: urlString)
  }
  var email: String? { profileUnwrapped.email }
  var password: String? { profileUnwrapped.password }
  var profileImageIsSet: Bool { profileUnwrapped.hasProfileImage }
  var imageID: Int { profileUnwrapped.imageId }
  
  func fetchProfile() -> Observable<ProfileResponse> {
    guard let auth = KeychainHelper.shared.read(
      service: AUTH_SERVICE,
      account: TERRARESTA_ACCOUNT,
      type: LoggedInAuth.self) else {
      fatalError("Missing auth data")
    }
    let request = ProfileDisplayRequest(
      accessToken: auth.accessToken,
      userId: auth.userId
    )
    return TerrarestaAPIClient.performRequest(request)
      .do(onNext: { [weak self] profile in
        self?.profile = profile
      })
  }
}
