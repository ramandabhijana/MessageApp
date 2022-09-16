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
  private static let NAVIGATION_TITLE = "Select Image"
  
  static func createFromStoryboard(presenter: MediaManagePresenterProtocol = MediaManagePresenter(allowsVideoAsset: false)) -> MediaManageViewController {
    let storyboard = UIStoryboard(name: String(describing: MediaManageViewController.self), bundle: nil)
    return storyboard.instantiateViewController(identifier: String(describing: MediaManageViewController.self)) { coder in
      MediaManageViewController(coder: coder, presenter: presenter)
    }
  }
  
  private lazy var manager = PHCachingImageManager()
  
  private lazy var mediaAssets: PHFetchResult<PHAsset> = {
    let options = PHFetchOptions()
    if presenter.allowsVideoAsset == false {
      options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
    }
    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    return PHAsset.fetchAssets(with: options)
  }()
  
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
    image: UIImage(systemName: CLOSE_BTN_IMG_NAME),
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
  
  private var selectedPhoto: UIImage? = nil {
    didSet {
      if selectedPhoto != nil {
        selectedVideo = nil
      }
    }
  }
  private var selectedVideo: AVAsset? = nil {
    didSet {
      if selectedVideo != nil {
        selectedPhoto = nil
      }
    }
  }
  var onSuccessUploadAsset: ((_ assetId: Int, _ mediaType: PHAssetMediaType) -> ())?
  
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
    if let photo = selectedPhoto {
      uploadImage(photo)
    } else if let video = selectedVideo {
      uploadVideo(video)
    }
  }
  
  func decideButtonEnabled(_ enabled: Bool) {
    decideButton.isEnabled = enabled
  }
  
  @objc private func didTapClose() {
    dismiss(animated: true)
  }
  
  func applyLoadingAppearance() {
    closeButton.isEnabled = false
    navigationItem.title = "Uploading Media..."
    navigationItem.rightBarButtonItem = loadingIndicator
    (loadingIndicator.customView as? UIActivityIndicatorView)?.startAnimating()
    collectionView.isUserInteractionEnabled = false
  }
  
  func applyNormalAppearance() {
    closeButton.isEnabled = true
    decideButtonEnabled(true)
    navigationItem.title = Self.NAVIGATION_TITLE
    navigationItem.rightBarButtonItem = decideButton
    navigationItem.leftBarButtonItem = closeButton
    (loadingIndicator.customView as? UIActivityIndicatorView)?.stopAnimating()
    collectionView.isUserInteractionEnabled = true
  }
  
  func fetchCameraPermissionStatus(handler: @escaping (Bool) -> Void) {
    AVCaptureDevice.fetchPermissionStatus(handler: handler)
  }
  
  private func uploadImage(_ image: UIImage) {
    guard let imageData = image.jpegData(compressionQuality: 0.5) else {
      showAlert(title: "Couldn't use this one",
                message: "Please select other photo and try again.")
      return
    }
    presenter.upload(imageData: imageData)
  }
  
  private func uploadVideo(_ video: AVAsset) {
    decideButtonEnabled(false)
    let fileURL = FileManager.default
      .urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("new_video_upload.mp4")
    let exportSession = AVAssetExportSession(asset: video, presetName: AVAssetExportPresetMediumQuality)
    exportSession?.outputURL = fileURL
    exportSession?.outputFileType = AVFileType.mp4
    exportSession?.exportAsynchronously(completionHandler: { [weak self] in
      // Check whether the video has been written to the file URL
      guard let self = self else { return }
      // Try to get video data out of the file
      if let videoData = try? Data(contentsOf: fileURL) {
        self.presenter.upload(videoData: videoData, fileURL: fileURL)
      } else {
        DispatchQueue.main.async {
          self.decideButtonEnabled(true)
          self.showAlert(title: "Missing data",
                         message: "Please use other video.")
        }
        
      }
    })
  }
  
  // MARK: UICollectionViewDataSource
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return mediaAssets.count + 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard indexPath.item != 0 else {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CameraCell.reuseIdentifier, for: indexPath) as! CameraCell
      return cell
    }
    
    let photoIndexPath = presenter.photoIndexPath(for: indexPath)
    let asset = mediaAssets.object(at: photoIndexPath.item)
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: photoIndexPath) as! PhotoCell
    cell.assetIdentifier = asset.localIdentifier
    cell.isVideo = asset.mediaType == .video
    
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
      let asset = mediaAssets.object(at: photoIndexPath.item)
      
      switch asset.mediaType {
      case .video:
        manager.requestAVAsset(forVideo: asset, options: nil) { [weak self] videoAsset, audioMix, info in
          guard let self = self, let videoAsset = videoAsset else { return }
          self.selectedVideo = videoAsset
        }
      case .image:
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
        }
      default:
        return
      }
      
      (cell as! PhotoCell).selected()
      
      if let collectionViewPreviouslySelectedPhotoIndexPath = self.presenter.collectionViewSelectedPhotoIndexPath {
        // Deselect the previously selected if any
        if let previousSelectedCell = self.collectionView.cellForItem(at: collectionViewPreviouslySelectedPhotoIndexPath) as? PhotoCell {
          previousSelectedCell.deselected()
        }
      }
      
      presenter.selectedPhotoIndexPath = photoIndexPath
    default:
      break
    }
  
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
      uploadImage(pickedImage)
    }
    picker.dismiss(animated: true)
  }
}
