//
//  TalkListResponse.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 01/09/22.
//

import Foundation
import Differentiator

struct TalkListResponse: Decodable {
  let status: Int
  let items: [TalkListItem]?
  let error: ErrorResponse?
}

struct TalkListItem: Decodable, Equatable {
  let talkId: Int
  let toUserId: Int
  let messageId: Int
  let userId: Int
  let nickname: String
  let imageId: Int
  let imageSize: String?
  let imageUrl: String?
  let message: String
  let mediaType: Int?
  let time: String
  let lastUpdateTime: String
  
  static func initWithEntity(_ entity: TalkListItemEntity) -> TalkListItem {
    return TalkListItem(talkId: entity.talkId, toUserId: entity.toUserId, messageId: entity.messageId, userId: entity.userId, nickname: entity.nickname, imageId: entity.imageId, imageSize: entity.imageSize, imageUrl: entity.imageUrl, message: entity.message, mediaType: entity.mediaType.value, time: entity.time, lastUpdateTime: entity.lastUpdateTime)
  }
  
  static func ==(lhs: TalkListItem, rhs: TalkListItem) -> Bool {
    return lhs.talkId == rhs.talkId
    && lhs.toUserId == rhs.toUserId
    && lhs.messageId == rhs.messageId
    && lhs.userId == rhs.userId
    && lhs.nickname == rhs.nickname
    && lhs.imageId == rhs.imageId
    && lhs.imageSize == rhs.imageSize
    && lhs.imageUrl == rhs.imageUrl
    && lhs.message == rhs.message
    && lhs.mediaType == rhs.mediaType
    && lhs.time == rhs.time
    && lhs.lastUpdateTime == rhs.lastUpdateTime
  }
}

extension TalkListItem: IdentifiableType {
  typealias Identity = Int
  
  var identity: Int { talkId }
}
