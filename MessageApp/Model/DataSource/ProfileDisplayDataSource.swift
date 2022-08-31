//
//  ProfileDisplayDataSource.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 29/08/22.
//

import Foundation
import RxSwift

class ProfileDisplayDataSource {
  private var profile: ProfileResponse!
  private(set) var age: Int?
  private(set) var sex: ProfileListItem?
  private(set) var occupancy: ProfileListItem?
  private(set) var area: String?
  private(set) var hobby: String?
  private(set) var character: ProfileListItem?
  
  func fetchProfileForUser(with userId: Int) -> Observable<Void> {
    switch AuthManager.accessToken {
    case .failure(let error):
      return Observable.error(error)
    case .success(let token):
      let request = ProfileDisplayRequest(accessToken: token, userId: userId)
      return TerrarestaAPIClient.performRequest(request)
        .do(onNext: { [weak self] response in
          self?.setAttributes(with: response)
        })
        .map { _ in () }
    }
  }
  
  private func setAttributes(with response: ProfileResponse) {
    profile = response
    
    if let age = response.age, let _ = response.birthday {
      self.age = age
    } else {
      self.age = nil
    }
    
    if let gender = response.gender,
       gender != UNSELECTED_INDEX,
       let sex = SelectionDataSource.itemForItemId(gender, type: GenderList.self) {
      self.sex = sex
    } else {
      self.sex = nil
    }
    
    if let job = response.job,
       job != UNSELECTED_INDEX,
       let occupancy = SelectionDataSource.itemForItemId(job, type: OccupationList.self) {
      self.occupancy = occupancy
    } else {
      self.occupancy = nil
    }
    
    if let area = response.residence, !area.isEmpty {
      self.area = area
    } else {
      self.area = nil
    }
    
    if let hobby = response.hobby, !hobby.isEmpty {
      self.hobby = hobby
    } else {
      self.hobby = nil
    }
    
    if let personality = response.personality,
       personality != UNSELECTED_INDEX,
       let character = SelectionDataSource.itemForItemId(personality, type: CharacterList.self) {
      self.character = character
    } else {
      self.character = nil
    }
  }
}
