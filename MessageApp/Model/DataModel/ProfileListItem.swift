//
//  ProfileListItem.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 16/08/22.
//

import Foundation

protocol ProfileListItemConvertible {
  var list: [String] { get }
  var asProfileList: [ProfileListItem] { get }
}

extension ProfileListItemConvertible {
  var asProfileList: [ProfileListItem] {
    list.map(ProfileListItem.init(item:))
  }
}

struct ProfileListItem: Decodable, Equatable {
  var item: String
  
  init(item: String) {
    self.item = item
  }
  
//  init(id: Int) {
//
//  }
  
  var id: Int? {
    if let idString = item.components(separatedBy: "_").last,
       let id = Int(idString) {
      return id
    }
    return nil
  }
  
  var name: String {
    item.components(separatedBy: "_")[0]
  }
  
  static func ==(lhs: ProfileListItem, rhs: ProfileListItem) -> Bool {
    return lhs.name == rhs.name
  }
}
