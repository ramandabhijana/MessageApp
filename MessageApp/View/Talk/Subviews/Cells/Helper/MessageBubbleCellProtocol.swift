//
//  MessageBubbleCellProtocol.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 14/09/22.
//

import UIKit

protocol MessageBubbleCellProtocol: AnyObject {
  var messageLabel: UILabel { get }
  var bubbleView: UIView! { get }
  
  // View that contains message label and bubble view
  var containerView: UIView { get }
  
  func layoutMessageLabel(spacing: (top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat))
  func setMessageLabelText(_ text: String)
}

extension MessageBubbleCellProtocol {
  func layoutMessageLabel(spacing: (top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat)) {
    containerView.addSubview(messageLabel)
    messageLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      bubbleView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: spacing.trailing),
      bubbleView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: spacing.leading),
      bubbleView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: spacing.top),
      bubbleView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: spacing.bottom)
    ])
  }
  
  func setMessageLabelText(_ text: String) {
    messageLabel.text = text
  }
}
