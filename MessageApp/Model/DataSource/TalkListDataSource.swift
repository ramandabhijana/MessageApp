//
//  TalkListDataSource.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 01/09/22.
//

import Foundation
import RealmSwift
import RxSwift

class TalkListDataSource {
  private static let TALK_LIST_PARENT_ID: Int = 010922
  
  private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = API_DATE_FORMAT
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    return dateFormatter
  }()
  
  func fetchTalkList() -> Observable<TalkListResponse> {
    return fetchSavedTalkList()
      .flatMap { entity -> Observable<TalkListResponse> in
        guard let items = entity?.items else {
          return Observable.empty()
        }
        print("From realm: \(items)")
        return Observable.just(TalkListResponse(
          status: SUCCESS_STATUS_CODE,
          items: items.map(TalkListItem.initWithEntity(_:)),
          error: nil))
      }
      .ifEmpty(switchTo: fetchNewTalkList())
  }
  
  func deleteTalks(_ talks: [TalkListItem]) -> Observable<Void> {
    switch AuthManager.accessToken {
    case .failure(let error):
      return Observable.error(error)
    case .success(let token):
      let talkIds = talks.map(\.talkId)
      let request = DeleteTalkListRequest(accessToken: token, talkIds: talkIds)
      return TerrarestaAPIClient.performRequest(request)
        .do(onNext: { [weak self] _ in
          self?.removeStoredTalkList(withIds: talkIds)
        })
        .map { _ in () }
    }
  }
  
  private func fetchSavedTalkList() -> Observable<TalkListEntity?> {
    let realm = try! Realm()
    let talkList = realm.object(
      ofType: TalkListEntity.self,
      forPrimaryKey: Self.TALK_LIST_PARENT_ID)
    return Observable.just(talkList).single()
  }
  
  func fetchNewTalkList() -> Observable<TalkListResponse> {
    switch AuthManager.accessToken {
    case .failure(let error):
      return Observable.error(error)
    case .success(let token):
      // Somehow the server always responds with no data when lastUpdateTime
      // is specified (that's what the nil for).
      /*
      let realm = try! Realm()
      let lastUpdate = realm.objects(TalkListEntity.self).first?.lastUpdateTime
      */
      let request = TalkListRequest(accessToken: token, lastUpdateTime: nil)
      return TerrarestaAPIClient.performRequest(request)
        .do(onNext: { [weak self] talkList in
          guard let self = self else { return }
          let date = self.dateFormatter.string(from: .now)
          self.storeTalkList(talkList, updateOnDate: date)
        })
    }
  }
  
  private func storeTalkList(_ list: TalkListResponse, updateOnDate date: String?) {
    let newListItemEntity = List<TalkListItemEntity>()
    let mappedListItems = (list.items ?? [])
      .map { item -> TalkListItemEntity in
        let entity = TalkListItemEntity()
        entity.setFieldsCopyingValue(item: item)
        return entity
      }
    newListItemEntity.append(objectsIn: mappedListItems)
    
    let realm = try! Realm()
    
    try! realm.write {
      let talkListEntity = TalkListEntity(value: [
        "id": Self.TALK_LIST_PARENT_ID,
        "lastUpdateTime": date as Any,
        "items": newListItemEntity])
      realm.add(talkListEntity, update: .modified)
    }
  }
  
  private func removeStoredTalkList(withIds ids: [Int]) {
    let realm = try! Realm()
    guard let parentListObject = realm.object(ofType: TalkListEntity.self, forPrimaryKey: Self.TALK_LIST_PARENT_ID) else {
      return
    }
    var talkIds = ids
    let shouldDeleteTalkWithId: (Int) -> Bool = { id in
      if talkIds.contains(id) {
        talkIds.removeAll(where: { $0 == id })
        return true
      }
      return false
    }
    let listItems = parentListObject.items.filter { shouldDeleteTalkWithId($0.talkId) }
    try! realm.write { realm.delete(listItems) }
  }
}
