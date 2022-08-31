//
//  PhotoScrollView.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 30/08/22.
//

import UIKit

@IBDesignable
class PhotoScrollView: UIScrollView {
  lazy var imageView: UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleAspectFit
    return view
  }()
  
  @IBInspectable
  private var imageName: String? {
    didSet {
      guard let imageName = imageName else { return }
      imageView.image = UIImage(named: imageName)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  private func setupView() {
    setupScrollView()
    setupImageView()
  }
  
  private func setupScrollView() {
    minimumZoomScale = 1
    maximumZoomScale = 3
    showsHorizontalScrollIndicator = false
    showsVerticalScrollIndicator = false
    delegate = self
  }
  
  private func setupImageView() {
    addSubview(imageView)
    NSLayoutConstraint.activate([
      imageView.widthAnchor.constraint(equalTo: widthAnchor),
      imageView.heightAnchor.constraint(equalTo: heightAnchor),
      imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
      imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }
}

extension PhotoScrollView: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }
}
