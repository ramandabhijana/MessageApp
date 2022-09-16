//
//  String+.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 02/08/22.
//

import Foundation
import UniformTypeIdentifiers

extension String {
  var isValidEmail: Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: self)
  }
  
  var isSecurePassword: Bool {
    let passwordRegEx = "^[A-Z0-9a-z]{5,9}$"
    let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
    return passwordPred.evaluate(with: self)
  }
}

func mimeType(for urlPath: URL) -> String {
  let pathExtension = urlPath.pathExtension
  if let type = UTType.init(filenameExtension: pathExtension),
     let mimeType = type.preferredMIMEType {
    return mimeType as String
  }
  return "application/octet-stream"
}
