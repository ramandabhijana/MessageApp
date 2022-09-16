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
  var allowsVideoAsset: Bool { get }
  
  func photoIndexPath(for collectionViewIndexPath: IndexPath) -> IndexPath
  func openCamera()
  func upload(imageData: Data)
  func upload(videoData: Data, fileURL: URL)
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
  
  private(set) var allowsVideoAsset: Bool
  
  init(allowsVideoAsset: Bool = false) {
    self.allowsVideoAsset = allowsVideoAsset
  }
  
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
    guard case .success(let accessToken) = token,
          case .success(let userId) = AuthManager.userId else { return }
    let uploadRequest = ImageUploadRequest(accessToken: accessToken, location: .talk, imageData: imageData, fileId: userId)
    TerrarestaAPIClient.performRequest(uploadRequest)
      .subscribe(
        onNext: { [weak self] response in
          if let onSuccessUpload = self?.viewController?.onSuccessUploadAsset {
            onSuccessUpload(response.imageId, .image)
          }
          self?.showSuccessAlert(with: "The photo has been uploaded successfully")
        },
        onError: { [weak self] error in
          self?.viewController?.showError(error)
        },
        onDisposed: { [weak self] in
          self?.loading = false
        }
      )
      .disposed(by: disposeBag)
  }
  
  func upload(videoData: Data, fileURL: URL) {
    DispatchQueue.main.async {
      self.loading = true
    }
    let token = AuthManager.accessToken
    if case .failure(let error) = token {
      viewController?.showError(error)
    }
    guard case .success(let accessToken) = token else { return }
    let videoUploadRequest = VideoUploadRequest(
      accessToken: accessToken,
      videoData: videoData,
      fileURL: fileURL)
    TerrarestaAPIClient.performRequest(videoUploadRequest)
      .observeOn(MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] uploadResponse in
          if let onSuccessUpload = self?.viewController?.onSuccessUploadAsset {
            onSuccessUpload(uploadResponse.videoId, .video)
          }
          self?.showSuccessAlert(with: "The video has been uploaded successfully")
        },
        onError: { [weak self] error in
          self?.viewController?.showError(error)
        },
        onDisposed: { [weak self] in
          self?.loading = false
          self?.cleanupExportVideoFile(fileUrl: fileURL)
        }
      )
      .disposed(by: disposeBag)
  }
  
  private func cleanupExportVideoFile(fileUrl: URL) {
    // check if file exists
    if FileManager.default.fileExists(atPath: fileUrl.path) {
      do {
        try FileManager.default.removeItem(atPath: fileUrl.path)
      } catch {
        print("Could not delete file, probably read-only filesystem")
      }
    }
  }
  
  private func showSuccessAlert(with message: String) {
    viewController?.showAlert(
      title: "Success",
      message: message,
      actions: [UIAlertAction(
        title: "Dismiss",
        style: .default,
        handler: { [weak self] _ in
          self?.viewController?.dismiss(animated: true)
        })])
  }
}
