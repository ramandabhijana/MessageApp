//
//  SelectionDataSource.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 16/08/22.
//

import Foundation

enum SelectionListType {
  case occupation
  case gender
  case area
  case hobby
  case character
}

struct SelectionDataSource {
  private static let FILE_NAME = "ProfileList"
  
  private let allowMultipleSelection: Bool
  
  var list: [ProfileListItem] = []
  
  private var selectedItems: [Int: ProfileListItem] {
    willSet {
      let hasItemSelected = !newValue.isEmpty
      if !allowMultipleSelection && hasItemSelected { return }
    }
  }
  
  init(type: SelectionListType,
       allowMultipleSelection: Bool,
       selectedItems: [Int: ProfileListItem] = [:]) {
    self.allowMultipleSelection = allowMultipleSelection
    self.selectedItems = selectedItems
    loadList(forType: type)
  }
  
  mutating func loadList(forType type: SelectionListType) {
    list = Self.fetchProfileList(forType: type)
  }
  
  static func fetchProfileList(forType type: SelectionListType) -> [ProfileListItem] {
    switch type {
    case .occupation:
      let occupations: OccupationList = Self.decodePlistFile()
      return occupations.asProfileList
    case .gender:
      let genders: GenderList = Self.decodePlistFile()
      return genders.asProfileList
    case .area:
      let areas: AreaList = Self.decodePlistFile()
      return areas.asProfileList
    case .hobby:
      let hobbies: HobbyList = Self.decodePlistFile()
      return hobbies.asProfileList
    case .character:
      let characters: CharacterList = Self.decodePlistFile()
      return characters.asProfileList
    }
  }
  
  private static func decodePlistFile<T: Decodable & ProfileListItemConvertible>() -> T {
    let url = Bundle.main.url(forResource: FILE_NAME, withExtension:"plist")!
    do {
      let data = try Data(contentsOf: url)
      let profileList = try PropertyListDecoder().decode(T.self, from: data)
      return profileList
    } catch {
      fatalError("fetchProfileList error: \(error)")
    }
  }
  
  mutating func selected(at index: Int) {
    guard index != UNSELECTED_INDEX else {
      selectedItems.removeAll()
      selectedItems[UNSELECTED_INDEX] = list[UNSELECTED_INDEX]
      return
    }
    selectedItems.removeValue(forKey: UNSELECTED_INDEX)
    if selectedItems[index] == nil {
      selectedItems[index] = list[index]
    } else {
      selectedItems[index] = nil
    }
  }
  
  func getSelectedItems() -> [Int: ProfileListItem] {
    guard selectedItems[UNSELECTED_INDEX] == nil else { return [:] }
    return selectedItems
  }
}

extension SelectionDataSource {
  init(type: SelectionListType, allowMultipleSelection: Bool, selectedItemIndices: [Int]) {
    self.init(type: type, allowMultipleSelection: allowMultipleSelection)
    selectedItemIndices.forEach { index in
      selectedItems[index] = self.list[index]
    }
  }
  
  static func selectedItems<T: Decodable & ProfileListItemConvertible>(ofType: T.Type, for profileListItems: [ProfileListItem]) -> [Int: ProfileListItem] {
    let decodedList: T = decodePlistFile()
    let listItems = decodedList.asProfileList
    var result: [Int: ProfileListItem] = [:]
    profileListItems.forEach { item in
      let index = listItems.firstIndex(of: item)!
      result[index] = item
    }
    return result
  }
  
  static func selectedItem<T: Decodable & ProfileListItemConvertible>(ofType: T.Type, for itemID: Int) -> [Int: ProfileListItem] {
    let decodedList: T = decodePlistFile()
    let listItems = decodedList.asProfileList
    return [itemID: listItems[itemID]]
  }
  
  static func itemForItemId<T: Decodable & ProfileListItemConvertible>(_ itemId: Int, type: T.Type) -> ProfileListItem? {
    let decodedList: T = decodePlistFile()
    let listItems = decodedList.asProfileList
    return listItems.first { $0.id == itemId }
  }
}
