//
//  DeleteProfilePictureRequest.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 11/08/22.
//

import Foundation

struct DeleteProfilePictureRequest: APIRequest {
  typealias Response = StatusResponse
  
  let accessToken: String
  let imageId: Int
  
  var method: HTTPMethod { .POST }
  var path: String { "/app/api/ProfileCtrl/ProfileEdit" }
  var body: Data? { "image_id=\(imageId)".data(using: .utf8) }
  var contentType: String { "application/x-www-form-urlencoded" }
  var additionalHeaders: [String : String] { ["Accept": "application/json"] }
  var params: [URLQueryItem] {
    [URLQueryItem(name: "access_token", value: accessToken)]
  }
  
  func decode(data: Data) throws -> StatusResponse {
    let decodedData = try JSONDecoder().decode(Response.self, from: data)
    guard decodedData.status == SUCCESS_STATUS_CODE else {
      throw APIError.badResponse(decodedData.error!)
    }
    return decodedData
  }
}
