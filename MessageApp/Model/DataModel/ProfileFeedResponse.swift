//
//  ProfileFeedResponse.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 23/08/22.
//

import Foundation
import CoreGraphics

struct ProfileFeedResponse: Decodable {
  let status: Int
  let lastLoginTime: String
  let items: [ProfileFeedItem]
  let error: ErrorResponse?
}

struct ProfileFeedItem: Decodable {
  let userId: Int
  let nickname: String
  let aboutMe: String
  let imageId: Int
  let imageSize: String?
  let imageUrl: String?
  let residence: String
  let age: Int
  
  var imageURL: URL? {
    if let imageUrl = imageUrl {
      return URL(string: imageUrl)
    }
    return nil
  }
  
  var imageSizeValue: CGSize? {
    if let imageSize = imageSize {
      let whSeparated = imageSize.split(separator: "x")
      guard whSeparated.count == 2,
            let width = Int(whSeparated[0]),
            let height = Int(whSeparated[1])
      else { return nil }
      return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
    return nil
  }
}
