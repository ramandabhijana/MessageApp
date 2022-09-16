//
//  VideoBubbleReceivedCell.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 15/09/22.
//

import UIKit

class VideoBubbleReceivedCell: BaseBubbleReceivedCell, VideoBubbleCellProtocol {
  static let reuseIdentifier = String(describing: VideoBubbleReceivedCell.self)
  
  private let thumbnailImageView: UIImageView = {
    let view = UIImageView()
    view.clipsToBounds = true
    view.contentMode = .scaleAspectFill
    return view
  }()
  lazy var playImageView: UIImageView = createPlayImageView()
  
  var mediaTapResponder: MediaBubbleTapResponder? {
    didSet {
      guard let tapResponder = mediaTapResponder else {
        return
      }
      playImageView.addGestureRecognizer(tapResponder.createTapGestureRecognizer())
    }
  }
  
  var mediaImageView: UIImageView { thumbnailImageView }
  var bubbleView: UIView! { super.bubbleImageView }
  var containerView: UIView { contentView }
  
  override func setupLayout() {
    super.setupLayout()
    layoutMediaImageView()
    setupPlayImageView()
  }
}
