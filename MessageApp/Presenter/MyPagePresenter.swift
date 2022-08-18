//
//  MyPagePresenter.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 03/08/22.
//

import Foundation
import RxSwift
import FittedSheets

protocol MyPagePresenterProtocol {
  var viewController: MyPageViewController? { get set }
  
  func logout()
  func displayEmailInfo()
  func displayPassword()
  func presentTermCondition()
  func presentDeleteAccountConfirmation()
  func fetchData()
  func presentMediaManageViewController(forceShow: Bool)
  func pushEditProfileViewController()
  func deleteProfileImage()
}

class MyPagePresenter: MyPagePresenterProtocol, RootViewControllerReplacing, APIErrorHandling {
  weak var viewController: MyPageViewController?
  
  private let dataSource: MyPageDataSourceProtocol
  private let disposeBag = DisposeBag()
  
  private var loading: Bool = false {
    didSet {
      loading ? viewController?.applyLoadingState() : viewController?.applyNormalState()
    }
  }
  
  init(dataSource: MyPageDataSourceProtocol) {
    self.dataSource = dataSource
  }
  
  func logout() {
    // Delete token and replace root view controller
    KeychainHelper.shared.delete(service: AUTH_SERVICE,
                                 account: TERRARESTA_ACCOUNT)
    replaceRootViewControllerWithTopViewController()
  }
  
  func displayEmailInfo() {
    guard let email = dataSource.email else { return }
    viewController?.showAlert(title: "Email", message: email)
  }
  
  func displayPassword() {
    guard let password = dataSource.password else { return }
    viewController?.showAlert(title: "Password", message: password)
  }
  
  func presentTermCondition() {
    guard let tncURL = URL(string: "https://s3-ap-northeast-1.amazonaws.com/app-lesson-media/tos.html") else {
      viewController?.showAlert(title: "Error", message: "Unable to open Terms & Condition page")
      return
    }
    let webViewController = WebViewController(url: tncURL)
    viewController?.present(UINavigationController(rootViewController: webViewController), animated: true)
  }
  
  func presentDeleteAccountConfirmation() {
    viewController?.showAlert(
      title: "Warning",
      message: "Are you sure want to delete account?",
      actions: [
        UIAlertAction(title: "Cancel", style: .cancel),
        UIAlertAction(title: "OK", style: .destructive, handler: deleteAccountHandler(_:))
      ])
  }
  
  func presentMediaManageViewController(forceShow: Bool = false) {
    guard !loading else { return }
    // Check whether show mediamanage or not
    viewController?.fetchLibraryAuthStatus { authorized in
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        
        guard authorized else {
          self.viewController?.showAlert(
            title: "Gallery permission denied",
            message: "You can still change the permission on your device's settings")
          return
        }
        
        if self.dataSource.profileImageIsSet && !forceShow {
          // Show bottom sheet
          let replaceDeleteViewController = ReplaceDeleteProfileImageViewController.createFromStoryboard()
          replaceDeleteViewController.delegate = self.viewController
          let sheetOptions = SheetOptions(pullBarHeight: 16, presentingViewCornerRadius: .zero, shouldExtendBackground: true, setIntrinsicHeightOnNavigationControllers: false, useFullScreenMode: false, shrinkPresentingViewController: false, useInlineMode: false, horizontalPadding: 0, maxWidth: nil)
          let sheetController = SheetViewController(controller: replaceDeleteViewController,
                                                    sizes: [.fixed(250)],
                                                    options: sheetOptions)
          self.viewController?.present(sheetController, animated: true, completion: nil)
        } else {
          let viewController = UINavigationController(rootViewController: MediaManageViewController.createFromStoryboard())
          viewController.modalPresentationStyle = .fullScreen
          self.viewController?.present(viewController, animated: true)
        }
      }
    }
  }
  
  func pushEditProfileViewController() {
    guard let profile = dataSource.profile else { return }
    let editDataSource = EditProfileDataSource(profile: profile)
    let editPresenter = EditProfilePresenter(dataSource: editDataSource)
    viewController?.navigationController?.pushViewController(
      EditProfileViewController.createFromStoryboard(presenter: editPresenter),
      animated: true)
  }
  
  func deleteProfileImage() {
    let token = KeychainHelper.shared.read(
      service: AUTH_SERVICE,
      account: TERRARESTA_ACCOUNT,
      type: LoggedInAuth.self)!.accessToken
    let deleteRequest = DeleteProfilePictureRequest(accessToken: token, imageId: dataSource.imageID)
    TerrarestaAPIClient.performRequest(deleteRequest)
      .subscribeOn(MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] _ in
          self?.fetchData()
        },
        onError: onError(_:)
      )
      .disposed(by: disposeBag)
  }
  
  private func deleteAccountHandler(_ action: UIAlertAction) {
    // Make API call, delete session, then show TopVC
    let token = KeychainHelper.shared.read(
      service: AUTH_SERVICE,
      account: TERRARESTA_ACCOUNT,
      type: LoggedInAuth.self)!.accessToken
    let request = DeleteAccountRequest(accessToken: token)
    TerrarestaAPIClient.performRequest(request)
      .subscribe(
        onNext: { [weak self] _ in
          KeychainHelper.shared.delete(
            service: AUTH_SERVICE,
            account: TERRARESTA_ACCOUNT)
          self?.replaceRootViewControllerWithTopViewController()
        },
        onError: onError(_:)
      )
      .disposed(by: disposeBag)
  }
}

// MARK: - Data
extension MyPagePresenter {
  func fetchData() {
    loading = true
    dataSource.fetchProfile()
      .subscribe(
        onNext: { [weak self] profile in
          guard let self = self else { return }
          self.viewController?.profileImageUrlFetched(self.dataSource.profileImageURL)
          self.viewController?.nickNameLabel.text = profile.nickname
          self.viewController?.userIDLabel.text = "#ID: \(profile.userId)"
          self.loading = false
        },
        onError: onError(_:)
      )
      .disposed(by: disposeBag)
  }
  
  private func onError(_ error: Error) {
    if let apiError = error as? APIError {
      viewController?.showError(content: getErrorTitleAndMessage(forError: apiError))
      return
    }
    viewController?.showError(content: ("Error", error.localizedDescription))
  }
}
