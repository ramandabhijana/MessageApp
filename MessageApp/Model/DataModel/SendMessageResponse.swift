//
//  SendMessageResponse.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 01/09/22.
//

import Foundation

struct SendMessageResponse: Decodable {
  let status: Int
  let messageId: Int
  let error: ErrorResponse?
}
