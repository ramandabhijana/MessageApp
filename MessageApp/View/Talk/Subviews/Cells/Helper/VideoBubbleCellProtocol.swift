//
//  VideoBubbleCellProtocol.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 15/09/22.
//

import UIKit

protocol VideoBubbleCellProtocol: MediaBubbleCellProtocol {
  var playImageView: UIImageView { get }
  
  func setupPlayImageView()
  func createPlayImageView() -> UIImageView
}

extension VideoBubbleCellProtocol {
  func createPlayImageView() -> UIImageView {
    let view = UIImageView()
    view.image = UIImage(systemName: "play.circle.fill")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration.init(paletteColors: [.white, .white, .darkGray]))
    view.backgroundColor = .black
    return view
  }
  
  func setupPlayImageView() {
    containerView.addSubview(playImageView)
    playImageView.translatesAutoresizingMaskIntoConstraints = false
    playImageView.isUserInteractionEnabled = true
    NSLayoutConstraint.activate([
      playImageView.widthAnchor.constraint(equalToConstant: 80),
      playImageView.heightAnchor.constraint(equalTo: playImageView.widthAnchor, multiplier: 1.0/1.0),
      playImageView.centerXAnchor.constraint(equalTo: mediaImageView.centerXAnchor),
      playImageView.centerYAnchor.constraint(equalTo: mediaImageView.centerYAnchor)
    ])
    DispatchQueue.main.async {
      self.playImageView.layer.masksToBounds = true
      self.playImageView.layer.cornerRadius = self.playImageView.bounds.size.width / 2
    }
  }
}
