//
//  RegistryRequest.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 02/08/22.
//

import Foundation

struct RegistryRequest: APIRequest {
  
  typealias Response = RegistryResponse
  
  let email: String
  let password: String
  let nickname: String
  let language: String = "en"
  
  var method: HTTPMethod { return .GET }
  var path: String { return "/app/api/SignUpCtrl/SignUp" }
  var body: Data? { return nil }
  var contentType: String { return "application/json" }
  var additionalHeaders: [String : String] { return [:] }
  var params: [URLQueryItem] {
    [URLQueryItem(name: "login_id", value: email),
     URLQueryItem(name: "password", value: password),
     URLQueryItem(name: "nickname", value: nickname),
     URLQueryItem(name: "language", value: language)]
  }
  
  private static let SUCCESS_STATUS_CODE = 1
  private static let FAILED_STATUS_CODE = 0
  
  func decode(data: Data) throws -> RegistryResponse {
    let decodedData = try JSONDecoder().decode(Response.self, from: data)
    guard decodedData.status == Self.SUCCESS_STATUS_CODE else {
      throw APIError.badResponse(decodedData.error!)
    }
    guard decodedData.accessToken != nil else {
      throw APIError.noData
    }
    return decodedData
  }
}
