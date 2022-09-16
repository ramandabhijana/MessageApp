//
//  PhotoBubbleReceivedCell.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 15/09/22.
//

import UIKit

class PhotoBubbleReceivedCell: BaseBubbleReceivedCell, MediaBubbleCellProtocol {
  static let reuseIdentifier = String(describing: PhotoBubbleReceivedCell.self)
  
  let mediaImageView: UIImageView = {
    let view = UIImageView()
    view.isUserInteractionEnabled = true
    return view
  }()
  var bubbleView: UIView! { super.bubbleImageView }
  var containerView: UIView { contentView }
  
  var mediaTapResponder: MediaBubbleTapResponder? {
    didSet {
      guard let tapResponder = mediaTapResponder else {
        return
      }
      loadImage(withURL: mediaTapResponder?.mediaURL,
                imageView: mediaImageView,
                failureImage: failureImage)
      mediaImageView.addGestureRecognizer(tapResponder.createTapGestureRecognizer())
    }
  }
  
  override func setupLayout() {
    super.setupLayout()
    layoutMediaImageView()
  }
}
