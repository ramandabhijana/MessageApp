//
//  MediaBubbleCellProtocol.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 15/09/22.
//

import UIKit

protocol MediaBubbleCellProtocol: AnyObject {
  var mediaImageView: UIImageView { get }
  var bubbleView: UIView! { get }
  var mediaTapResponder: MediaBubbleTapResponder? { get set }
  var containerView: UIView { get }
  
  func layoutMediaImageView()
}

extension MediaBubbleCellProtocol {
  func layoutMediaImageView() {
    containerView.addSubview(mediaImageView)
    DispatchQueue.main.async {
      self.mediaImageView.layer.masksToBounds = true
      self.mediaImageView.layer.cornerRadius = 10
    }
    mediaImageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      mediaImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5),
      mediaImageView.heightAnchor.constraint(equalTo: mediaImageView.widthAnchor, multiplier: 1.0/1.0),
      mediaImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -20),
      mediaImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 20),
      mediaImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 15),
      mediaImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -15)
    ])
  }
}
