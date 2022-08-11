//
//  MediaManageViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 09/08/22.
//

import UIKit
import Photos

class MediaManageViewController: UICollectionViewController, UINavigationControllerDelegate {
  private static let ROOT_VC_NAME = "MediaManageNavigationController"
  private static let DECIDE_BTN_TITLE = "Decide"
  private static let CLOSE_BTN_IMG_NAME = "xmark"
  private static let NAVIGATION_TITLE = "Select Image"
  
  static func createFromStoryboard(presenter: MediaManagePresenterProtocol = MediaManagePresenter()) -> UIViewController {
    let storyboard = UIStoryboard(name: String(describing: MediaManageViewController.self), bundle: nil)
    return storyboard.instantiateViewController(identifier: String(describing: MediaManageViewController.self)) { coder in
      MediaManageViewController(coder: coder, presenter: presenter)
    }
  }
  
  private lazy var manager = PHCachingImageManager()
  
  private lazy var photos = MediaManageViewController.loadPhotos()
  
  private lazy var thumbnailSize: CGSize = {
    let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
    return CGSize(
      width: cellSize.width * UIScreen.main.scale,
      height: cellSize.height * UIScreen.main.scale)
  }()
  
  private lazy var decideButton: UIBarButtonItem = {
    let button = UIBarButtonItem(
      title: Self.DECIDE_BTN_TITLE,
      style: .done,
      target: self,
      action: #selector(didTapDecide))
    button.tintColor = COLOR_APP_GREEN
    button.isEnabled = false
    return button
  }()
  private lazy var closeButton = UIBarButtonItem(
    image: UIImage(systemName: Self.CLOSE_BTN_IMG_NAME),
    style: .plain,
    target: self,
    action: #selector(didTapClose)
  )
  private let loadingIndicator: UIBarButtonItem = {
    let indicator = UIActivityIndicatorView()
    indicator.hidesWhenStopped = true
    return UIBarButtonItem(customView: indicator)
  }()
  
  private var presenter: MediaManagePresenterProtocol
  private var selectedPhoto: UIImage? = nil
  
  init?(coder: NSCoder, presenter: MediaManagePresenterProtocol) {
    self.presenter = presenter
    super.init(coder: coder)
    self.presenter.viewController = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    applyNormalAppearance()
  
    let photoCellNib = UINib(nibName: PhotoCell.reuseIdentifier, bundle: nil)
    collectionView.register(photoCellNib, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
    let cameraCellNib = UINib(nibName: CameraCell.reuseIdentifier, bundle: nil)
    collectionView.register(cameraCellNib, forCellWithReuseIdentifier: CameraCell.reuseIdentifier)
    
    PHPhotoLibrary.fetchAuthorizationStatus { [weak self] authorized in
      if !authorized {
        self?.dismiss(animated: true)
      }
    }
  }
  
  @objc private func didTapDecide() {
    uploadImage()
  }
  
  func decideButtonEnabled(_ enabled: Bool) {
    decideButton.isEnabled = enabled
  }
  
  @objc private func didTapClose() {
    dismiss(animated: true)
  }
  
  func applyLoadingAppearance() {
    closeButton.isEnabled = false
    navigationItem.title = "Uploading Image..."
    navigationItem.rightBarButtonItem = loadingIndicator
    (loadingIndicator.customView as? UIActivityIndicatorView)?.startAnimating()
    collectionView.isUserInteractionEnabled = false
  }
  
  func applyNormalAppearance() {
    closeButton.isEnabled = true
    navigationItem.title = Self.NAVIGATION_TITLE
    navigationItem.rightBarButtonItem = decideButton
    navigationItem.leftBarButtonItem = closeButton
    (loadingIndicator.customView as? UIActivityIndicatorView)?.stopAnimating()
    collectionView.isUserInteractionEnabled = true
  }
  
  func fetchCameraPermissionStatus(handler: @escaping (Bool) -> Void) {
    AVCaptureDevice.fetchPermissionStatus(handler: handler)
  }
  
  private func uploadImage() {
    guard let imageData = selectedPhoto?.jpegData(compressionQuality: 0.5) else {
      showAlert(title: "Couldn't use this one",
                message: "Please select other photo and try again.")
      return
    }
    presenter.upload(imageData: imageData)
  }
  
  // MARK: UICollectionViewDataSource
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return photos.count + 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard indexPath.item != 0 else {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CameraCell.reuseIdentifier, for: indexPath) as! CameraCell
      return cell
    }
    
    let photoIndexPath = presenter.photoIndexPath(for: indexPath)
    let asset = photos.object(at: photoIndexPath.item)
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: photoIndexPath) as! PhotoCell
    cell.assetIdentifier = asset.localIdentifier
    
    photoIndexPath == presenter.selectedPhotoIndexPath ? cell.selected() : cell.deselected()
    
    manager.requestImage(for: asset,
                         targetSize: thumbnailSize,
                         contentMode: .aspectFill,
                         options: nil,
                         resultHandler: { image, _ in
      if cell.assetIdentifier == asset.localIdentifier {
        cell.previewImageView.image = image
      }
    })
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath)
    switch cell {
    case is CameraCell:
      presenter.openCamera()
    case is PhotoCell:
      // Check if index path is same as current saved indexpath
      if
        let collectionViewSelectedPhotoIndexPath = presenter.collectionViewSelectedPhotoIndexPath,
        collectionViewSelectedPhotoIndexPath == indexPath
      {
        // Deselect
        presenter.selectedPhotoIndexPath = nil
        selectedPhoto = nil
        (cell as! PhotoCell).deselected()
        return
      }
      let photoIndexPath = presenter.photoIndexPath(for: indexPath)
      let asset = photos.object(at: photoIndexPath.item)
      manager.requestImage(
        for: asset,
        targetSize: view.frame.size,
        contentMode: .aspectFill,
        options: nil
      ) { [weak self] image, info in
        guard let self = self, let image = image, let info = info else { return }
        
        guard
          let isThumbnail = info[PHImageResultIsDegradedKey] as? Bool,
          isThumbnail == false
        else { return }
        
        self.selectedPhoto = image
        
        (cell as! PhotoCell).selected()
        
        if let collectionViewPreviouslySelectedPhotoIndexPath = self.presenter.collectionViewSelectedPhotoIndexPath {
          // Deselect the previously selected if any
          if let previousSelectedCell = self.collectionView.cellForItem(at: collectionViewPreviouslySelectedPhotoIndexPath) as? PhotoCell {
            previousSelectedCell.deselected()
          }
        }
        self.presenter.selectedPhotoIndexPath = photoIndexPath
      }
    default:
      break
    }
  
  }
  
  // MARK: UICollectionViewDelegate
  
  /*
   // Uncomment this method to specify if the specified item should be highlighted during tracking
   override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
   return true
   }
   */
  
  /*
   // Uncomment this method to specify if the specified item should be selected
   override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
   return true
   }
   */
  
  /*
   // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
   override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
   return false
   }
   
   override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
   return false
   }
   
   override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
   
   }
   */
  
  
  static func loadPhotos() -> PHFetchResult<PHAsset> {
    let options = PHFetchOptions()
    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    return PHAsset.fetchAssets(with: options)
  }
}

extension MediaManageViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let scaleFactor = collectionView.bounds.width / 3
    return CGSize(width: scaleFactor, height: scaleFactor)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets.zero
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
}

extension PHPhotoLibrary {
  static func fetchAuthorizationStatus(completion: @escaping (Bool) -> Void) {
    let authorized = authorizationStatus(for: .readWrite) == .authorized
    
    if authorized { return completion(authorized) }
    
    requestAuthorization(for: .readWrite) { status in
      completion(status == .authorized)
    }
  }
}

extension AVCaptureDevice {
  static func fetchPermissionStatus(handler: @escaping (Bool) -> Void) {
    AVCaptureDevice.requestAccess(for: .video) { granted in
      DispatchQueue.main.async { handler(granted) }
    }
  }
}

extension MediaManageViewController: UIImagePickerControllerDelegate {
  func presentCamera() {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.sourceType = UIImagePickerController.SourceType.camera
    picker.allowsEditing = true
    picker.cameraCaptureMode = .photo
    self.present(picker, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let pickedImage = info[.editedImage] as? UIImage {
      presenter.selectedPhotoIndexPath = nil
      selectedPhoto = pickedImage
      uploadImage()
    }
    picker.dismiss(animated: true)
  }
}
