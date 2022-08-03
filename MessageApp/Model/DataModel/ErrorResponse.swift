//
//  ErrorResponse.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 02/08/22.
//

import Foundation

struct ErrorResponse: Decodable {
  let errorCode: Int
  let errorTitle: String?
  let errorMessage: String?
  
  var titleOrDefault: String {
    errorTitle ?? "Bad Response"
  }
  var messageOrDefault: String {
    errorMessage ?? "Please try again later."
  }
}
