//
//  ProfileDisplayRequest.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 09/08/22.
//

import Foundation

struct ProfileDisplayRequest: APIRequest {
  typealias Response = ProfileResponse
  
  let accessToken: String
  let userId: Int
  
  var method: HTTPMethod { .GET }
  var path: String { "/app/api/ProfileCtrl/ProfileDisplay" }
  var body: Data? { nil }
  var contentType: String { "application/json" }
  var additionalHeaders: [String : String] { [:] }
  var params: [URLQueryItem] {
    [URLQueryItem(name: "access_token", value: accessToken),
     URLQueryItem(name: "user_id", value: String(userId))]
  }
  
  func decode(data: Data) throws -> ProfileResponse {
    let decodedData = try JSONDecoder().decode(Response.self, from: data)
    guard decodedData.status == SUCCESS_STATUS_CODE else {
      throw APIError.badResponse(decodedData.error!)
    }
    return decodedData
  }
}
