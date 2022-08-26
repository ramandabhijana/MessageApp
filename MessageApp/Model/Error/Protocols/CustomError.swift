//
//  CustomError.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 22/08/22.
//

import Foundation

protocol CustomError: Error {
  var title: String { get }
  var message: String? { get }
}
