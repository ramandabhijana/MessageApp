//
//  MyPagePresenter.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 03/08/22.
//

import Foundation
import RxSwift

protocol MyPagePresenterProtocol {
  var viewController: MyPageViewController? { get set }
  
  func logout()
}

class MyPagePresenter: MyPagePresenterProtocol, RootViewControllerReplacing {
  weak var viewController: MyPageViewController?
  
  func logout() {
    // Delete token and replace root view controller
    KeychainHelper.shared.deleteMessageAppTerrarestaAccessToken()
    replaceRootViewControllerWithTopViewController()
  }
}
