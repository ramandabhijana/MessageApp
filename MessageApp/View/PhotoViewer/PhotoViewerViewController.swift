//
//  PhotoViewerViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 29/08/22.
//

import UIKit
import Combine

class PhotoViewerViewController: UIViewController {
  static func createFromStoryboard(image: UIImage) -> PhotoViewerViewController {
    let name = String(describing: PhotoViewerViewController.self)
    let storyboard = UIStoryboard(name: name, bundle: nil)
    return storyboard.instantiateViewController(identifier: name) { coder in
      PhotoViewerViewController(coder: coder, image: image)
    }
  }
  
  static func createFromStoryboard(imageURL: URL) -> PhotoViewerViewController {
    let name = String(describing: PhotoViewerViewController.self)
    let storyboard = UIStoryboard(name: name, bundle: nil)
    return storyboard.instantiateViewController(identifier: name) { coder in
      PhotoViewerViewController(coder: coder, imageURL: imageURL)
    }
  }
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var imageView: UIImageView!
  
  private lazy var closeButton: UIBarButtonItem = {
    let button = UIBarButtonItem(
      image: UIImage(systemName: CLOSE_BTN_IMG_NAME),
      style: .done,
      target: self,
      action: #selector(didTapClose))
    button.tintColor = .white
    return button
  }()
  
  private var image: UIImage?
  
  private var imageURL: URL?
  private var imageViewImageDidSet: AnyCancellable?
  
  init?(coder: NSCoder, image: UIImage) {
    self.image = image
    super.init(coder: coder)
  }
  
  init?(coder: NSCoder, imageURL: URL?) {
    self.imageURL = imageURL
    super.init(coder: coder)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.leftBarButtonItem = closeButton
    navigationController?.view.backgroundColor = .black
    navigationController?.navigationBar.barTintColor = .black
    scrollView.delegate = self
    
    if let image = image {
      imageView.image = image
      setupImageView(withImage: image)
      updateZoomScale(forSize: scrollView.bounds.size)
      centerImage()
    }
    
    if let imageURL = imageURL {
      imageViewImageDidSet = imageView.publisher(for: \.image)
        .compactMap { $0 }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] image in
          guard let self = self else { return }
          self.setupImageView(withImage: image)
          self.updateZoomScale(forSize: self.scrollView.bounds.size)
          self.centerImage()
        }
    
      loadImage(withURL: imageURL, imageView: imageView, failureImage: nil)
    }
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    updateZoomScale(forSize: scrollView.bounds.size)
    centerImage()
  }
  
  private func setupImageView(withImage image: UIImage) {
    imageView.frame.size = imageView.image!.size
    let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapImageView(_:)))
    doubleTapRecognizer.numberOfTapsRequired = 2
    imageView.addGestureRecognizer(doubleTapRecognizer)
  }
  
  private func updateZoomScale(forSize size: CGSize) {
    let widthScale = size.width / imageView.bounds.size.width
    let heightScale = size.height / imageView.bounds.size.height
    let minScale = min(widthScale, heightScale)
    scrollView.minimumZoomScale = minScale
    scrollView.maximumZoomScale = 3.0
    scrollView.zoomScale = minScale
  }
  
  private func centerImage() {
    let scrollViewSize = scrollView.bounds.size
    let imageSize = imageView.frame.size
    let horizontalSpace = imageSize.width < scrollViewSize.width
      ? (scrollViewSize.width - imageSize.width) / 2
      : .zero
    let verticalSpace = imageSize.height < scrollViewSize.height
      ? (scrollViewSize.height - imageSize.height) / 2
      : .zero
    scrollView.contentInset = UIEdgeInsets(
      top: verticalSpace,
      left: horizontalSpace,
      bottom: verticalSpace,
      right: horizontalSpace)
  }
  
  @objc private func didTapClose() {
    dismiss(animated: true)
  }
  
  @objc private func didDoubleTapImageView(_ sender: UITapGestureRecognizer) {
    if scrollView.zoomScale == scrollView.minimumZoomScale {
      // Zoom in
      scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
      return
    }
    // Zoom out
    scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
  }
}

extension PhotoViewerViewController: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    imageView
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    // Implement dismiss
  }
}
