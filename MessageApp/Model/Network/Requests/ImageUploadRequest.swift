//
//  ImageUploadRequest.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 11/08/22.
//

import Foundation

enum ImageUploadLocation: String {
  case talk = "Talk"
  case profile = "Profile"
  
  func createFileName(withId id: Int) -> String {
    return self.rawValue + "_\(id).jpg"
  }
}

struct ImageUploadRequest: APIRequest {
  typealias Response = ImageUploadResponse
  
  private let boundary = UUID().uuidString
  private let accessToken: String
  private let location: String
  private let imageData: Data
  
  init(accessToken: String, location: ImageUploadLocation, imageFileName: String, imageFileURLPath: URL, imageData: Data) {
    self.accessToken = accessToken
    self.location = location.rawValue
    self.imageData = imageData.toFormData(
      boundary: boundary,
      fileName: imageFileName,
      mimeType: mimeType(for: imageFileURLPath))
  }
  
  init(accessToken: String, location: ImageUploadLocation, imageData: Data, fileId: Int) {
    self.accessToken = accessToken
    self.location = location.rawValue
    self.imageData = imageData.toFormData(
      boundary: boundary,
      fileName: location.createFileName(withId: fileId),
      mimeType: "image/jpeg")
  }
  
  var method: HTTPMethod { .POST }
  var path: String { "/app/api/MediaCtrl/ImageUpload" }
  var body: Data? { imageData }
  var contentType: String { "multipart/form-data; boundary=\(boundary)" }
  var additionalHeaders: [String : String] {
    return ["Content-Length": "\(imageData.count)"]
  }
  var params: [URLQueryItem] {
    [URLQueryItem(name: "access_token", value: accessToken),
     URLQueryItem(name: "location", value: location)]
  }
  
  func decode(data: Data) throws -> ImageUploadResponse {
    let decodedData = try JSONDecoder().decode(ImageUploadResponse.self, from: data)
    guard decodedData.status == SUCCESS_STATUS_CODE else {
      throw APIError.badResponse(decodedData.error!)
    }
    return decodedData
  }  
}
