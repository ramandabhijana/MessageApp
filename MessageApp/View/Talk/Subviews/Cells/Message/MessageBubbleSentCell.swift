//
//  MessageBubbleSentCell.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 14/09/22.
//

import UIKit

class MessageBubbleSentCell: BaseBubbleSentCell, MessageBubbleCellProtocol {
  static let reuseIdentifier = String(describing: MessageBubbleSentCell.self)
  
  let messageLabel: UILabel = {
    let label = UILabel()
    label.font = .preferredFont(forTextStyle: .subheadline)
    label.textColor = .white
    label.numberOfLines = 0
    return label
  }()
  var bubbleView: UIView! { super.bubbleImageView }
  var containerView: UIView { contentView }
  
  override func setupLayout() {
    super.setupLayout()
    layoutMessageLabel(spacing: (top: -10.0, leading: -15.0, bottom: 10.0, trailing: 20.0))
  }
}
