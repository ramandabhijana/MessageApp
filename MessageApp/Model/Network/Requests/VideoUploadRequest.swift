//
//  VideoUploadRequest.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 07/09/22.
//

import Foundation

struct VideoUploadRequest: APIRequest {
  typealias Response = VideoUploadResponse
  
  private let boundary = UUID().uuidString
  private let accessToken: String
  private let videoData: Data
  
  init(accessToken: String, videoData: Data, fileURL: URL) {
    self.accessToken = accessToken
    self.videoData = videoData.toFormData(
      boundary: boundary,
      fileName: boundary + ".mp4",
      mimeType: mimeType(for: fileURL))
  }
  
  var method: HTTPMethod { .POST }
  var path: String { "/app/api/MediaCtrl/VideoUpload" }
  var body: Data? { videoData }
  var contentType: String { "multipart/form-data; boundary=\(boundary)" }
  var additionalHeaders: [String : String] { [:] }
  var params: [URLQueryItem] {
    [URLQueryItem(name: "access_token", value: accessToken)]
  }
  
  func decode(data: Data) throws -> VideoUploadResponse {
    let decodedData = try JSONDecoder().decode(VideoUploadResponse.self, from: data)
    guard decodedData.status == SUCCESS_STATUS_CODE else {
      throw APIError.badResponse(decodedData.error!)
    }
    return decodedData
  }
}
