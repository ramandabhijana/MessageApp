//
//  LoginRequest.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 04/08/22.
//

import Foundation

struct LoginRequest: APIRequest {
  
  typealias Response = RegistryResponse
  
  let email: String
  let password: String
  let language: String = "en"
  
  var method: HTTPMethod { .GET }
  var path: String { "/app/api/LoginCtrl/Login" }
  var body: Data? { nil }
  var contentType: String { "application/json" }
  var additionalHeaders: [String : String] { [:] }
  var params: [URLQueryItem] {
    [URLQueryItem(name: "login_id", value: email),
     URLQueryItem(name: "password", value: password),
     URLQueryItem(name: "language", value: language)]
  }
  
  func decode(data: Data) throws -> RegistryResponse {
    let decodedData = try JSONDecoder().decode(Response.self, from: data)
    guard decodedData.status == SUCCESS_STATUS_CODE else {
      throw APIError.badResponse(decodedData.error!)
    }
    guard decodedData.accessToken != nil else {
      throw APIError.noData
    }
    return decodedData
  }
}
