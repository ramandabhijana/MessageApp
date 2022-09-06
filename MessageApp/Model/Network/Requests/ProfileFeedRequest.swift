//
//  ProfileFeedRequest.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 23/08/22.
//

import Foundation

struct ProfileFeedRequest: APIRequest {
  typealias Response = ProfileFeedResponse
  
  let accessToken: String
  let lastLoginTime: String?
  
  init(accessToken: String, lastLoginTime: String?) {
    self.accessToken = accessToken
    self.lastLoginTime = lastLoginTime
  }
  
  init(accessToken: String, lastLoginTime: Date?) {
    self.accessToken = accessToken
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = API_DATE_FORMAT
    self.lastLoginTime = lastLoginTime == nil ? nil : dateFormatter.string(from: lastLoginTime!)
  }
  
  var method: HTTPMethod { .GET }
  var path: String { "/app/api/ProfileFeedCtrl/ProfileFeed" }
  var body: Data? { nil }
  var contentType: String { "application/json" }
  var additionalHeaders: [String : String] { [:] }
  var params: [URLQueryItem] {
    [URLQueryItem(name: "access_token", value: accessToken),
     URLQueryItem(name: "last_login_time", value: lastLoginTime)]
  }
  
  func decode(data: Data) throws -> ProfileFeedResponse {
    let decodedData = try JSONDecoder().decode(Response.self, from: data)
    guard decodedData.status == SUCCESS_STATUS_CODE else {
      throw APIError.badResponse(decodedData.error!)
    }
    return decodedData
  }
}
