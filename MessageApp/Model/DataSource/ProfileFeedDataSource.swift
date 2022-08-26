//
//  ProfileFeedDataSource.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 23/08/22.
//

import Foundation
import RxSwift

class ProfileFeedDataSource {
  private(set) var items: [ProfileFeedItem] = []
  private(set) var canLoadMore: Bool = false
  private var lastLogin: String? = nil {
    didSet {
      if let lastLogin = lastLogin, !lastLogin.isEmpty {
        canLoadMore = true
      } else {
        canLoadMore = false
      }
    }
  }
  
  func fetchProfileFeeds(shouldUseLastLoginTime: Bool = false,
                         shouldAppendFetchedResults: Bool = true) -> Observable<Void>
  {
    switch AuthManager.accessToken {
    case .failure(let error):
      return Observable.error(error)
    case .success(let token):
      let request = ProfileFeedRequest(
        accessToken: token,
        lastLoginTime: shouldUseLastLoginTime ? lastLogin : nil)
      return TerrarestaAPIClient.performRequest(request)
        .do(onNext: { [weak self] response in
          if shouldAppendFetchedResults {
            self?.items.append(contentsOf: response.items)
          } else {
            self?.items = response.items
          }
          self?.lastLogin = response.lastLoginTime
        })
        .map { _ in () }
    }
  }
}
