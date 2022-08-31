//
//  APIError.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 22/08/22.
//

import Foundation

enum APIError: CustomError {
  case requestFailed(statusCode: Int)
  case postProcessingFailed(Error)
  case noData
  case badResponse(ErrorResponse)
  
  var title: String {
    switch self {
    case .requestFailed(let statusCode):
      return "Error \(statusCode)"
    case .postProcessingFailed(_):
      return "Internal Error"
    case .noData:
      return "No Data"
    case .badResponse(let errorResponse):
      return errorResponse.titleOrDefault
    }
  }
  
  var message: String? {
    switch self {
    case .requestFailed(_):
      // TODO: switch status code
      return "Request couldn't be completed"
    case .postProcessingFailed(_):
      return "Something went wrong please contact the developer."
    case .noData:
      return "Seems there is an error with our server."
    case .badResponse(let errorResponse):
      return errorResponse.messageOrDefault
    }
  }
}
