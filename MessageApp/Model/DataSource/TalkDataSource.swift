//
//  TalkDataSource.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 08/09/22.
//

import Foundation
import RxSwift
import RealmSwift

struct TalkDataSource {
  let otherUserId: Int
  
  func fetchTalks() -> Observable<TalkResponse> {
    return fetchSavedTalk()
      .flatMap { entity -> Observable<TalkResponse> in
        guard let items = entity?.items, !items.isEmpty else {
          return Observable.empty()
        }
        print("From realm: \(items)")
        return Observable.just(TalkResponse(
          status: SUCCESS_STATUS_CODE,
          items: items.map(TalkItem.initWithEntity(_:)),
          error: nil))
      }
      .ifEmpty(switchTo: fetchNewTalks())
  }
  
  func fetchNewTalks() -> Observable<TalkResponse> {
    guard let token = try? AuthManager.accessToken.get() else {
      return Observable.error(AuthError.missingCreddential)
    }
    let request = TalkRequest(accessToken: token, toUserId: otherUserId)
    return TerrarestaAPIClient.performRequest(request)
      .do(onNext: { talkResponse in
        storeTalk(talkResponse)
      })
  }
  
  func sendMessage(_ message: String) -> Observable<SendMessageResponse> {
    guard let token = try? AuthManager.accessToken.get() else {
      return Observable.error(AuthError.missingCreddential)
    }
    let request = SendMessageRequest(accessToken: token, toUserId: otherUserId, message: message)
    return TerrarestaAPIClient.performRequest(request)
  }
  
  func sendPhoto(withId photoId: Int) -> Observable<SendMessageResponse> {
    guard let token = try? AuthManager.accessToken.get() else {
      return Observable.error(AuthError.missingCreddential)
    }
    let request = SendMessageRequest(accessToken: token, toUserId: otherUserId, imageId: photoId)
    return TerrarestaAPIClient.performRequest(request)
  }
  
  func sendVideo(withId videoId: Int) -> Observable<SendMessageResponse> {
    guard let token = try? AuthManager.accessToken.get() else {
      return Observable.error(AuthError.missingCreddential)
    }
    let request = SendMessageRequest(accessToken: token, toUserId: otherUserId, videoId: videoId)
    return TerrarestaAPIClient.performRequest(request)
  }
  
  func fetchLatestTalk(lastSentMessageId: Int) -> Observable<TalkResponse> {
    guard let token = try? AuthManager.accessToken.get() else {
      return Observable.error(AuthError.missingCreddential)
    }
    let request = TalkRequest(accessToken: token, toUserId: otherUserId, borderMessageId: lastSentMessageId)
    return TerrarestaAPIClient.performRequest(request)
      .do(onNext: { talkResponse in
        insertTalkItemsToFront(talk: talkResponse)
      })
  }
  
  func fetchPastTalk(beforeMessageWithId messageId: Int) -> Observable<TalkResponse> {
    guard let token = try? AuthManager.accessToken.get() else {
      return Observable.error(AuthError.missingCreddential)
    }
    let request = TalkRequest(accessToken: token, toUserId: otherUserId, borderMessageId: messageId, requestMethod: .pastData)
    return TerrarestaAPIClient.performRequest(request)
      .do(onNext: { talkResponse in
        appendTalkItems(talk: talkResponse)
      })
  }
}

extension TalkDataSource {
  private func fetchSavedTalk() -> Observable<TalkEntity?> {
    let realm = try! Realm()
    let talkList = realm.object(
      ofType: TalkEntity.self,
      forPrimaryKey: otherUserId)
    return Observable.just(talkList).single()
  }
  
  private func storeTalk(_ talk: TalkResponse) {
    let newTalkItems = List<TalkItemEntity>()
    let mappedItems = (talk.items ?? [])
      .map { item -> TalkItemEntity in
        let entity = TalkItemEntity()
        entity.setFieldsCopyingValue(item: item)
        return entity
      }
    guard !mappedItems.isEmpty else { return }
    newTalkItems.append(objectsIn: mappedItems)
    let realm = try! Realm()
    try! realm.write {
      let talkEntity = TalkEntity(value: [
        "otherUserId": otherUserId,
        "items": mappedItems])
      realm.add(talkEntity, update: .modified)
    }
  }
  
  func insertTalkItemsToFront(talk: TalkResponse) {
    guard let talkItems = talk.items, !talkItems.isEmpty else { return }
    let realm = try! Realm()
    if let talkList = realm.object(ofType: TalkEntity.self, forPrimaryKey: otherUserId) {
      let newTalkEntities = talkItems.map { item -> TalkItemEntity in
        let entity = TalkItemEntity()
        entity.setFieldsCopyingValue(item: item)
        return entity
      }
      try! realm.write {
        talkList.items.insert(contentsOf: newTalkEntities, at: 0)
      }
    } else {
      // Since object doesnt exist, create a new one
      storeTalk(talk)
    }
  }
  
  func appendTalkItems(talk: TalkResponse) {
    guard let talkItems = talk.items, !talkItems.isEmpty else { return }
    let realm = try! Realm()
    if let talkList = realm.object(ofType: TalkEntity.self, forPrimaryKey: otherUserId) {
      let talkEntities = talkItems.map { item -> TalkItemEntity in
        let entity = TalkItemEntity()
        entity.setFieldsCopyingValue(item: item)
        return entity
      }
      try! realm.write {
        talkList.items.append(objectsIn: talkEntities)
      }
    }
  }
  
  func removeTalk() {
    let realm = try! Realm()
    if let talk = realm.object(ofType: TalkEntity.self, forPrimaryKey: otherUserId) {
      try! realm.write { realm.delete(talk) }
    }
  }
}
