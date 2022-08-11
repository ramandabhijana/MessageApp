//
//  StatusResponse.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 09/08/22.
//

import Foundation

struct StatusResponse: Decodable {
  let status: Int
  let error: ErrorResponse?
}
