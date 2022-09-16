//
//  MessageBubbleReceivedCell.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 14/09/22.
//

import UIKit

class MessageBubbleReceivedCell: BaseBubbleReceivedCell, MessageBubbleCellProtocol {
  static let reuseIdentifier = String(describing: MessageBubbleReceivedCell.self)
  
  private(set) var messageLabel: UILabel = {
    let label = UILabel()
    label.font = .preferredFont(forTextStyle: .subheadline)
    label.textColor = .black
    label.numberOfLines = 0
    return label
  }()
  var bubbleView: UIView! { super.bubbleImageView }
  var containerView: UIView { contentView }
  
  override func setupLayout() {
    super.setupLayout()
    layoutMessageLabel(spacing: (top: -10.0, leading: -20.0, bottom: 10.0, trailing: 15.0))
  }
}
