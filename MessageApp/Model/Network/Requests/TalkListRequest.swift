//
//  TalkListRequest.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 01/09/22.
//

import Foundation

struct TalkListRequest: APIRequest {
  typealias Response = TalkListResponse
  
  let accessToken: String
  let lastUpdateTime: String?
  
  init(accessToken: String, lastUpdateTime: Date?) {
    self.accessToken = accessToken
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = API_DATE_FORMAT
    self.lastUpdateTime = lastUpdateTime == nil ? nil : dateFormatter.string(from: lastUpdateTime!)
  }
  
  init(accessToken: String, lastUpdateTime: String) {
    self.accessToken = accessToken
    self.lastUpdateTime = lastUpdateTime
  }
  
  var method: HTTPMethod { .GET }
  var path: String { "/app/api/TalkCtrl/TalkList" }
  var body: Data? { nil }
  var contentType: String { "application/json" }
  var additionalHeaders: [String : String] { [:] }
  var params: [URLQueryItem] {
    [URLQueryItem(name: "access_token", value: accessToken),
     URLQueryItem(name: "last_update_time", value: lastUpdateTime)]
  }
  
  func decode(data: Data) throws -> TalkListResponse {
    let decodedData = try JSONDecoder().decode(Response.self, from: data)
    guard decodedData.status == SUCCESS_STATUS_CODE else {
      throw APIError.badResponse(decodedData.error!)
    }
    return decodedData
  }
}
