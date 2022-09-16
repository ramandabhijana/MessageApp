//
//  UIImageUtils.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 14/09/22.
//

import UIKit
import Nuke
import AVFoundation

func loadImage(withURL url: URL?,
               imageView: UIImageView,
               failureImage: UIImage?,
               onSuccess: ((UIImage?) -> Void)? = nil) {
  let request = ImageRequest(url: url, processors: ProfileFeedCell.resizedImageProcessors)
  ImagePipeline.shared.loadImage(with: request) { result in
    switch result {
    case .failure:
      imageView.image = failureImage
      imageView.contentMode = .scaleAspectFit
    case .success(let response):
      imageView.image = response.image
      imageView.contentMode = .scaleAspectFill
      onSuccess?(response.image)
    }
  }
}

func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping (UIImage?) ->Void) {
  DispatchQueue.global().async {
    let asset = AVAsset(url: url)
    let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
    avAssetImageGenerator.appliesPreferredTrackTransform = true
    let thumnailTime = CMTimeMake(value: 2, timescale: 1)
    do {
      let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
      let thumbNailImage = UIImage(cgImage: cgThumbImage)
      DispatchQueue.main.async {
        completion(thumbNailImage)
      }
    } catch {
      print(error.localizedDescription)
      DispatchQueue.main.async {
        completion(nil)
      }
    }
  }
}
