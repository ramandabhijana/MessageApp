//
//  RegistryResponse.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 02/08/22.
//

import Foundation

struct RegistryResponse: Decodable {
  let status: Int
  let accessToken: String?
  let userId: Int
  let error: ErrorResponse?
}

