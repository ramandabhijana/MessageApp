//
//  ProfileList.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 16/08/22.
//

import Foundation

struct OccupationList: Decodable, ProfileListItemConvertible {
  let occupation: [String]
  var list: [String] { occupation }
}

struct GenderList: Decodable, ProfileListItemConvertible {
  let gender: [String]
  var list: [String] { gender }
}

struct AreaList: Decodable, ProfileListItemConvertible {
  let area: [String]
  var list: [String] { area }
}

struct HobbyList: Decodable, ProfileListItemConvertible {
  let hobby: [String]
  var list: [String] { hobby }
}

struct CharacterList: Decodable, ProfileListItemConvertible {
  let character: [String]
  var list: [String] { character }
}
