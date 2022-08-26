//
//  MediaManagePresenter.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 10/08/22.
//

import Foundation
import RxSwift

protocol MediaManagePresenterProtocol {
  
  var viewController: MediaManageViewController? { get set }
  var selectedPhotoIndexPath: IndexPath? { get set }
  var collectionViewSelectedPhotoIndexPath: IndexPath? { get }
  
  
  func photoIndexPath(for collectionViewIndexPath: IndexPath) -> IndexPath
  func openCamera()
  func upload(imageData: Data)
}

class MediaManagePresenter: MediaManagePresenterProtocol {
  weak var viewController: MediaManageViewController?
  
  var selectedPhotoIndexPath: IndexPath? = nil {
    didSet {
      viewController?.decideButtonEnabled(selectedPhotoIndexPath != nil)
    }
  }
  var collectionViewSelectedPhotoIndexPath: IndexPath? {
    guard let selectedPhotoIndexPath = selectedPhotoIndexPath else {
      return nil
    }
    return IndexPath(item: selectedPhotoIndexPath.item + 1,
                     section: selectedPhotoIndexPath.section)
  }
  private var loading: Bool = false {
    didSet {
      loading ? viewController?.applyLoadingAppearance() : viewController?.applyNormalAppearance()
    }
  }
  private let disposeBag = DisposeBag()
  
  func openCamera() {
    guard let viewController = viewController else {
      print("ViewController is not set")
      return
    }
    guard viewController.canPresentCamera else {
      viewController.showAlert(title: "Error", message: "This device doesn't equip with camera.")
      return
    }
    viewController.fetchCameraPermissionStatus { [weak self] granted in
      guard let self = self, let viewController = self.viewController else { return }
      
      guard granted else {
        viewController.showAlert(
          title: CAMERA_PERMISSION_DENIED,
          message: PERMISSION_DENIED_MESSAGE,
          actions: [viewController.openSettingsAction()])
        return
      }
      viewController.presentCamera()
    }
    
  }
  
  func photoIndexPath(for collectionViewIndexPath: IndexPath) -> IndexPath {
    IndexPath(item: collectionViewIndexPath.item - 1, section: collectionViewIndexPath.section)
  }
  
  func upload(imageData: Data) {
    loading = true
    
    let token = AuthManager.accessToken
    if case .failure(let error) = token {
      viewController?.showError(error)
    }
    guard case .success(let accessToken) = token else { return }
    
    let uploadRequest = ImageUploadRequest(accessToken: accessToken, location: .profile, imageData: imageData)
    TerrarestaAPIClient.performRequest(uploadRequest)
      .subscribe(
        onNext: { [weak self] response in
          if response.status == SUCCESS_STATUS_CODE {
            self?.viewController?.applyNormalAppearance()
            self?.viewController?.showAlert(
              title: "Success",
              message: "Your profile image has been uploaded successfully",
              actions: [UIAlertAction(title: "Dismiss",
                                      style: .default,
                                      handler: { _ in
                                        self?.viewController?.dismiss(animated: true)
                                      })])
          }
        },
        onError: { [weak self] error in
          self?.viewController?.applyNormalAppearance()
          self?.viewController?.showError(error)
        }
      )
      .disposed(by: disposeBag)
  }
}
