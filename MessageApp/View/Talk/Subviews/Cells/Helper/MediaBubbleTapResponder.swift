//
//  VideoBubbleTapResponder.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 15/09/22.
//

import UIKit

class MediaBubbleTapResponder: NSObject {
  private(set) var mediaURL: URL?
  private let didTapMedia: (URL?) -> Void
  
  init(mediaURL: URL?, didTapMedia: @escaping (URL?) -> Void) {
    self.mediaURL = mediaURL
    self.didTapMedia = didTapMedia
  }
  
  func createTapGestureRecognizer() -> UITapGestureRecognizer {
    .init(target: self, action: #selector(didTapMediaHandler))
  }
  
  @objc func didTapMediaHandler() {
    didTapMedia(mediaURL)
  }
}
