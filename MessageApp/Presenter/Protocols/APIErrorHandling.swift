//
//  APIErrorHandling.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 04/08/22.
//

import Foundation

protocol APIErrorHandling: AnyObject {
  func getErrorTitleAndMessage(forError error: APIError) -> (title: String, message: String?)
}

extension APIErrorHandling {
  func getErrorTitleAndMessage(forError error: APIError) -> (title: String, message: String?) {
    let title: String
    let message: String?
    switch error {
    case .requestFailed(let statusCode):
      title = "Error \(statusCode)"
      message = nil
      break
    case .postProcessingFailed(let error):
      print(error.localizedDescription)
      title = "Internal Error"
      message = "Something went wrong please contact the developer."
    case .noData:
      title = "No Data"
      message = "Seems there is an error with our server."
    case .badResponse(let errorResponse):
      title = errorResponse.titleOrDefault
      message = errorResponse.messageOrDefault
    }
    return (title, message)
  }
}
