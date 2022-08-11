//
//  ImageUploadResponse.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 11/08/22.
//

import Foundation

struct ImageUploadResponse: Decodable {
  let status: Int
  let imageId: Int
  let error: ErrorResponse?
}
