//
//  VideoUploadResponse.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 07/09/22.
//

import Foundation

struct VideoUploadResponse: Decodable {
  let status: Int
  let videoId: Int
  let error: ErrorResponse?
}
