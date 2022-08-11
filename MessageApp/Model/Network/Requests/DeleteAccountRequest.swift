//
//  DeleteAccountRequest.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 09/08/22.
//

import Foundation

struct DeleteAccountRequest: APIRequest {
  typealias Response = StatusResponse
  
  let accessToken: String
  
  var method: HTTPMethod { .GET }
  var path: String { "/app/api/AccountCtrl/DeleteAccount" }
  var body: Data? { nil }
  var contentType: String { "application/json" }
  var additionalHeaders: [String : String] { [:] }
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
