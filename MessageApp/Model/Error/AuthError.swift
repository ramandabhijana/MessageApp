//
//  AuthError.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 22/08/22.
//

import Foundation

enum AuthError: CustomError {
  case missingCreddential
  
  var title: String {
    switch self {
    case .missingCreddential:
      return "Missing Credential"
    }
  }
  
  var message: String? {
    switch self {
    case .missingCreddential:
      return "Please log out then log in again"
    }
  }
}
