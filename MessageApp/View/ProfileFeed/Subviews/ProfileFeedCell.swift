//
//  ProfileFeedCell.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 23/08/22.
//

import UIKit
import Nuke

class ProfileFeedCell: UICollectionViewCell {
  static let reuseIdentifier = String(describing: ProfileFeedCell.self)
  private static let CORNER_RADIUS: CGFloat = 8.0
  private static let DEFAULT_IMAGE_HEIGHT = 180.0
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet var freewordLabel: UILabel!
  @IBOutlet weak var nicknameLabel: UILabel!
  @IBOutlet weak var ageLabel: UILabel!
  @IBOutlet var residenceLabel: UILabel!
  @IBOutlet var ageResidenceDividerLabel: UILabel!
  @IBOutlet weak var ageResidenceStackView: UIStackView!

  private static let defaultImage = UIImage(systemName: "person.circle.fill")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(hierarchicalColor: .white))
  private static let failureImage = UIImage(systemName: "xmark.seal")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(hierarchicalColor: .white))

  private static let imageLoadingOptions = ImageLoadingOptions(
    placeholder: defaultImage,
    failureImage: failureImage,
    contentModes: ImageLoadingOptions.ContentModes(
      success: UIView.ContentMode.scaleAspectFill,
      failure: UIView.ContentMode.scaleAspectFit,
      placeholder: UIView.ContentMode.scaleAspectFit))
  
  var pixelSize: CGFloat { Self.DEFAULT_IMAGE_HEIGHT * UIScreen.main.scale }
  
  var resizedImageProcessors: [ImageProcessing] {
    let imageSize = CGSize(width: pixelSize, height: pixelSize)
    return [ImageProcessors.Resize(size: imageSize, contentMode: .aspectFill)]
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    contentView.layer.cornerRadius = Self.CORNER_RADIUS
    contentView.layer.masksToBounds = true
    
    layer.cornerRadius = Self.CORNER_RADIUS
    layer.masksToBounds = false
    layer.shadowRadius = 5.0
    layer.shadowOpacity = 0.25
    layer.shadowColor = UIColor.black.cgColor
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: Self.CORNER_RADIUS).cgPath
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    contentView.addSubview(freewordLabel)
    setupFreewordLabelConstraints()
    ageResidenceStackView.addArrangedSubview(ageResidenceDividerLabel)
    ageResidenceStackView.addArrangedSubview(residenceLabel)
  }
  
  private func setupFreewordLabelConstraints() {
    freewordLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      freewordLabel.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor),
      freewordLabel.trailingAnchor.constraint(equalTo: nicknameLabel.trailingAnchor),
      freewordLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
      nicknameLabel.topAnchor.constraint(greaterThanOrEqualTo: freewordLabel.bottomAnchor, constant: 16)
    ])
  }
  
  func setupCell(data feedItem: ProfileFeedItem) {
    loadImage(withURL: feedItem.imageURL)
    setFreewordLabelText(feedItem.aboutMe)
    nicknameLabel.text = feedItem.nickname
    setAgeLabelText(feedItem.age)
    setResidenceLabelText(feedItem.residence)
  }
  
  private func loadImage(withURL url: URL?) {
    let request = ImageRequest(url: url, processors: resizedImageProcessors)
    
    imageView.image = Self.imageLoadingOptions.placeholder
    imageView.contentMode = .scaleAspectFit
    
    // The pipeline is setup with custom cache. Check SceneDelegate.swift
    ImagePipeline.shared.loadImage(with: request) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure:
        self.imageView.image = Self.imageLoadingOptions.placeholder
        self.imageView.contentMode = .scaleAspectFit
      case .success(let response):
        self.imageView.image = response.image
        self.imageView.contentMode = .scaleAspectFill
      }
    }
  }
  
  private func setFreewordLabelText(_ aboutMeText: String) {
    guard !aboutMeText.isEmpty else {
      freewordLabel.removeFromSuperview()
      return
    }
    freewordLabel.text = aboutMeText
  }
  
  private func setAgeLabelText(_ age: Int) {
    ageLabel.text = "\(age) y.o."
  }
  
  private func setResidenceLabelText(_ residence: String) {
    if residence.isEmpty {
      ageResidenceDividerLabel.removeFromSuperview()
      residenceLabel.removeFromSuperview()
      return
    }
    residenceLabel.text = residence
  }
}
