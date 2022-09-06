//
//  TalkListEntity.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 01/09/22.
//

import Foundation
import RealmSwift

class TalkListEntity: Object {
  @objc dynamic var id: Int = 0
  dynamic var lastUpdateTime: String?
  var items = List<TalkListItemEntity>()
  
  override class func primaryKey() -> String? { "id" }
}

class TalkListItemEntity: Object {
  @objc dynamic var talkId: Int = 0
  @objc dynamic var toUserId: Int = 0
  @objc dynamic var messageId: Int = 0
  @objc dynamic var userId: Int = 0
  @objc dynamic var nickname: String = ""
  @objc dynamic var imageId: Int = 0
  @objc dynamic var imageSize: String = ""
  @objc dynamic var imageUrl: String = ""
  @objc dynamic var message: String = ""
  let mediaType = RealmOptional<Int>()
  @objc dynamic var time: String = ""
  @objc dynamic var lastUpdateTime: String = ""
  
  func setFieldsCopyingValue(item: TalkListItem) {
    talkId = item.talkId
    toUserId = item.toUserId
    messageId = item.messageId
    userId = item.userId
    nickname = item.nickname
    imageId = item.imageId
    imageSize = item.imageSize ?? ""
    imageUrl = item.imageUrl ?? ""
    message = item.message
    mediaType.value = item.mediaType
    time = item.time
    lastUpdateTime = item.lastUpdateTime
  }
}
