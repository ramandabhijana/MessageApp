//
//  Data.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 11/08/22.
//

import Foundation

// https://stackoverflow.com/a/30953386

extension Data {
  func toFormData(boundary:String, fileName:String, mimeType: String) -> Data {
    let fullData = NSMutableData()
    
    // 1 - Boundary should start with --
    let lineOne = "--" + boundary + "\r\n"
    fullData.append(lineOne.data(using: .utf8, allowLossyConversion: false)!)
    
    // 2
    let lineTwo = "Content-Disposition: form-data; name=\"file\"; filename=\"" + fileName + "\"\r\n"
    fullData.append(lineTwo.data(using: .utf8, allowLossyConversion: false)!)
    
    // 3
    let lineThree = "Content-Type: " + mimeType + "\r\n\r\n"
    fullData.append(lineThree.data(using: String.Encoding.utf8,
                                   allowLossyConversion: false)!)
    
    // 4
    fullData.append(self)
    
    // 5
    let lineFive = "\r\n"
    fullData.append(lineFive.data(using: String.Encoding.utf8,
                                  allowLossyConversion: false)!)
    
    // 6 - The end. Notice -- at the start and at the end
    let lineSix = "--" + boundary + "--\r\n"
    fullData.append(lineSix.data(using: String.Encoding.utf8,
                                 allowLossyConversion: false)!)
    
    return fullData as Data
  }
}
