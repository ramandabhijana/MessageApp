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
  let nickname: String
  let imageId: Int
  let imageSize: String?
  let imageUrl: String?
  let gender: Int?
  let age: Int?
  let job: Int?
  let residence: String?
  let personality: Int?
  let hobby: String?
  let aboutMe: String?
  let userStatus: Int
  let email: String?
  let password: String?
  let error: ErrorResponse?
  
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
}
