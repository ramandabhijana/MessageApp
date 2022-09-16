//
//  TalkEntity.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 15/09/22.
//

import Foundation
import RealmSwift

class TalkEntity: Object {
  @objc dynamic var otherUserId: Int = 0
  var items = List<TalkItemEntity>()
  
  override class func primaryKey() -> String? { "otherUserId" }
}

class TalkItemEntity: Object {
  @objc dynamic var talkId: Int = 0
  @objc dynamic var messageId: Int = 0
  @objc dynamic var userId: Int = 0
  @objc dynamic var nickname: String = ""
  @objc dynamic var imageId: Int = 0
  @objc dynamic var imageSize: String = ""
  @objc dynamic var imageUrl: String = ""
  @objc dynamic var message: String = ""
  let mediaId = RealmOptional<Int>()
  @objc dynamic var mediaSize: String = ""
  @objc dynamic var mediaUrl: String = ""
  let mediaType = RealmOptional<Int>()
  @objc dynamic var time: String = ""
  @objc dynamic var messageKind: Int = 0
  
  func setFieldsCopyingValue(item: TalkItem) {
    talkId = item.talkId
    messageId = item.messageId
    userId = item.userId
    nickname = item.nickname
    imageId = item.imageId
    imageSize = item.imageSize ?? ""
    imageUrl = item.imageUrl ?? ""
    message = item.message ?? ""
    mediaId.value = item.mediaId
    mediaSize = item.mediaSize ?? ""
    mediaUrl = item.mediaUrl ?? ""
    mediaType.value = item.mediaType
    time = item.time
    messageKind = item.messageKind
  }
}
