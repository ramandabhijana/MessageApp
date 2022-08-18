//
//  EditProfileDataSource.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 16/08/22.
//

import Foundation

struct EditProfileDataSource {
  private(set) var selectionListData: [ProfileListItem] = []
  
  var nickname: String {
    didSet {
      editedProfile.nickname = nickname
    }
  }
  var birthday: String? = nil {
    didSet {
      editedProfile.birthday = birthday
    }
  }
  var gender: [Int: ProfileListItem]? = nil {
    didSet {
      editedProfile.gender = gender?.values.first?.id
    }
  }
  var job: [Int: ProfileListItem]? = nil {
    didSet {
      editedProfile.job = job?.values.first?.id
    }
  }
  var residence: [Int: ProfileListItem]? = nil {
    didSet {
      editedProfile.residence = residence?.values.first?.name
    }
  }
  var hobbies: [Int: ProfileListItem]? = nil {
    didSet {
      editedProfile.hobby = allHobbiesString
    }
  }
  var personality: [Int: ProfileListItem]? = nil {
    didSet {
      editedProfile.personality = personality?.values.first?.id
    }
  }
  var aboutMe: String? = nil {
    didSet {
      editedProfile.aboutMe = aboutMe
    }
  }
  
  var allHobbiesString: String {
    hobbies?.values.map(\.name).joined(separator: HOBBY_SEPARATOR) ?? "--"
  }
  
  private let initialProfile: ProfileResponse
  private(set) var editedProfile: ProfileResponse
  
  mutating func loadSelectionListData(type: SelectionListType) {
    selectionListData = SelectionDataSource.fetchProfileList(forType: type)
  }
  
  init(profile: ProfileResponse) {
    self.initialProfile = profile
    self.editedProfile = profile
    
    self.nickname = profile.nickname ?? ""
    self.birthday = profile.birthday
    
    if let genderId = profile.gender {
      self.gender = SelectionDataSource.selectedItem(ofType: GenderList.self, for: genderId)
    }
    if let jobId = profile.job {
      self.job = SelectionDataSource.selectedItem(ofType: OccupationList.self, for: jobId)
    }
    if let residence = profile.residence,
       !residence.isEmpty
    {
      self.residence = SelectionDataSource.selectedItems(ofType: AreaList.self, for: [.init(item: residence)])
    }
    
    let hobbies = Self.hobbies(for: profile.hobby ?? "")
    self.hobbies = SelectionDataSource.selectedItems(ofType: HobbyList.self, for: hobbies)
    
    if let personalityId = profile.personality {
      self.personality = SelectionDataSource.selectedItem(ofType: CharacterList.self, for: personalityId)
    }
    
    self.aboutMe = profile.aboutMe
  }
  
  func checkHasMadeChanges() -> Bool {
    editedProfile != initialProfile
  }
  
  static func hobbies(for hobby: String) -> [ProfileListItem] {
    guard !hobby.isEmpty else { return [] }
    let separator = Character(HOBBY_SEPARATOR)
    let hobbies = hobby.split(separator: separator)
    return hobbies.map { ProfileListItem(item: String($0)) }
  }
  
}
