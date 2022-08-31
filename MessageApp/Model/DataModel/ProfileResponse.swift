//
//  ProfileResponse.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 09/08/22.
//

import Foundation

struct ProfileResponse: Decodable {
  let status: Int
  let userId: Int
  var nickname: String?
  let imageId: Int
  let imageSize: String?
  let imageUrl: String?
  var gender: Int?
  let age: Int?
  var job: Int?
  var residence: String?
  var personality: Int?
  var hobby: String?
  var aboutMe: String?
  let userStatus: Int
  let email: String?
  let password: String?
  let error: ErrorResponse?
  var birthday: String?
  
  var userStatusDescription: String {
    switch userStatus {
    case 0: return "In Use"
    case 1: return "Withdrawal"
    default: return ""
    }
  }
  
  var hasProfileImage: Bool {
    imageId != 0
  }
  
  var imageURL: URL? {
    if let imageUrl = imageUrl { return URL(string: imageUrl) }
    return nil
  }
}

extension ProfileResponse: Equatable {
  static func == (lhs: ProfileResponse, rhs: ProfileResponse) -> Bool {
    lhs.userId == rhs.userId
    && lhs.nickname == rhs.nickname
    && lhs.birthday == rhs.birthday
    && lhs.gender == rhs.gender
    && lhs.job == rhs.job
    && lhs.residence == rhs.residence
    && lhs.hobby == rhs.hobby
    && lhs.personality == rhs.personality
    && lhs.aboutMe == rhs.aboutMe
  }
}
