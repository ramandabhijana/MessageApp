//
//  DeleteTalkListRequest.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 01/09/22.
//

import Foundation

struct DeleteTalkListRequest: APIRequest {
  typealias Response = StatusResponse
  
  let accessToken: String
  let talkIds: String
  
  init(accessToken: String, talkIds: [Int]) {
    self.accessToken = accessToken
    self.talkIds = talkIds.map(String.init).joined(separator: ",")
  }
  
  var method: HTTPMethod { .GET }
  var path: String { "/app/api/TalkCtrl/Delete" }
  var body: Data? { nil }
  var contentType: String { "application/json" }
  var additionalHeaders: [String : String] { [:] }
  var params: [URLQueryItem] {
    [URLQueryItem(name: "access_token", value: accessToken),
     URLQueryItem(name: "talk_ids", value: talkIds)]
  }
  
  func decode(data: Data) throws -> Response {
    let decodedData = try JSONDecoder().decode(Response.self, from: data)
    guard decodedData.status == SUCCESS_STATUS_CODE else {
      throw APIError.badResponse(decodedData.error!)
    }
    return decodedData
  }
}
