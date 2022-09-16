//
//  TalkRequest.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 07/09/22.
//

import Foundation
 

struct TalkRequest: APIRequest {
  typealias Response = TalkResponse
  
  private let accessToken: String
  private let toUserId: Int
  private let borderMessageId: Int
  private let howToRequest: Int
  
  init(accessToken: String, toUserId: Int, borderMessageId: Int = 0, requestMethod: RequestMethod = .notSet) {
    self.accessToken = accessToken
    self.toUserId = toUserId
    self.borderMessageId = borderMessageId
    self.howToRequest = requestMethod.rawValue
  }
  
  var method: HTTPMethod { .GET }
  var path: String { "/app/api/TalkCtrl/Talk" }
  var body: Data? { nil }
  var contentType: String { "application/json" }
  var additionalHeaders: [String : String] { [:] }
  var params: [URLQueryItem] {
    [URLQueryItem(name: "access_token", value: accessToken),
     URLQueryItem(name: "to_user_id", value: String(toUserId)),
     URLQueryItem(name: "border_message_id", value: String(borderMessageId)),
     URLQueryItem(name: "how_to_request", value: String(howToRequest))]
  }
  
  func decode(data: Data) throws -> TalkResponse {
    let decodedData = try JSONDecoder().decode(Response.self, from: data)
    guard decodedData.status == SUCCESS_STATUS_CODE else {
      throw APIError.badResponse(decodedData.error!)
    }
    return decodedData
  }
}

extension TalkRequest {
  enum RequestMethod: Int {
    case notSet = 0
    case pastData = 1
  }
}
