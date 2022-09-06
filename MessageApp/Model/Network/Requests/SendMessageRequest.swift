//
//  SendMessageRequest.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 01/09/22.
//

import Foundation

struct SendMessageRequest: APIRequest {
  typealias Response = SendMessageResponse
  
  let accessToken: String
  let toUserId: Int
  let message: String
  var imageId: String? = nil
  var videoId: String? = nil
  
  init(accessToken: String, toUserId: Int, message: String) {
    self.accessToken = accessToken
    self.toUserId = toUserId
    self.message = message
    self.imageId = nil
    self.videoId = nil
  }
  
  init(accessToken: String, toUserId: Int, message: String, imageId: Int) {
    self.accessToken = accessToken
    self.toUserId = toUserId
    self.message = message
    self.imageId = String(imageId)
    self.videoId = nil
  }
  
  init(accessToken: String, toUserId: Int, message: String, videoId: Int) {
    self.accessToken = accessToken
    self.toUserId = toUserId
    self.message = message
    self.imageId = nil
    self.videoId = String(videoId)
  }
  
  var method: HTTPMethod { .POST }
  var path: String { "/app/api/TalkCtrl/SendMessage" }
  var body: Data? {
    var components = URLComponents()
    components.queryItems = [
      URLQueryItem(name: "message", value: message)
    ]
    return components.query?.data(using: .utf8)
  }
  var contentType: String { "application/x-www-form-urlencoded" }
  var additionalHeaders: [String : String] { ["Accept": "application/json"] }
  var params: [URLQueryItem] {
    [URLQueryItem(name: "access_token", value: accessToken),
     URLQueryItem(name: "to_user_id", value: "\(toUserId)"),
     URLQueryItem(name: "image_id", value: imageId),
     URLQueryItem(name: "video_id", value: videoId)]
  }
  
  func decode(data: Data) throws -> Response {
    let decodedData = try JSONDecoder().decode(Response.self, from: data)
    guard decodedData.status == SUCCESS_STATUS_CODE else {
      throw APIError.badResponse(decodedData.error!)
    }
    return decodedData
  }
}
