//
//  PhotoCell.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 09/08/22.
//

import UIKit

class PhotoCell: UICollectionViewCell {
  @IBOutlet weak var previewImageView: UIImageView!
  
  static let reuseIdentifier = String(describing: PhotoCell.self)
  
  var assetIdentifier: String!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    previewImageView.image = nil
  }
  
  func selected() {
    previewImageView.layer.borderWidth = 0
    setNeedsDisplay()
    UIView.animate(withDuration: 0.5, animations: { [weak self] in
      self?.previewImageView.layer.borderColor = COLOR_APP_GREEN.cgColor
      self?.previewImageView.layer.borderWidth = 8
    })
  }
  
  func deselected() {
    UIView.animate(withDuration: 0.5, animations: { [weak self] in
      self?.previewImageView.layer.borderWidth = 0
    })
  }
}
