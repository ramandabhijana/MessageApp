//
//  ProfileFeedResponse.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 23/08/22.
//

import Foundation

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
}
