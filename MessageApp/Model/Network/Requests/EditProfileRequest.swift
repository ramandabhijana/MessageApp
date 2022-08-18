//
//  EditProfileRequest.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 18/08/22.
//

import Foundation

struct EditProfileRequest: APIRequest {
  typealias Response = StatusResponse
  
  let accessToken: String
  let nickname: String
  let birthday: String?
  let residence: String
  let gender: Int
  let job: Int
  let personality: Int
  let hobby: String
  let aboutMe: String
  
  var method: HTTPMethod { .POST }
  var path: String { "/app/api/ProfileCtrl/ProfileEdit" }
  var body: Data? {
    var components = URLComponents()
    components.queryItems = [
      URLQueryItem(name: "nickname", value: nickname),
      URLQueryItem(name: "birthday", value: birthday),
      URLQueryItem(name: "residence", value: residence),
      URLQueryItem(name: "gender", value: String(gender)),
      URLQueryItem(name: "job", value: String(job)),
      URLQueryItem(name: "personality", value: String(personality)),
      URLQueryItem(name: "hobby", value: hobby),
      URLQueryItem(name: "about_me", value: aboutMe)
    ]
    return components.query?.data(using: .utf8)
  }
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
