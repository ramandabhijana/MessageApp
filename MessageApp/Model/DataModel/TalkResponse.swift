//
//  TalkResponse.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 07/09/22.
//

import Foundation
import Differentiator

struct TalkResponse: Decodable {
  let status: Int
  let items: [TalkItem]?
  let error: ErrorResponse?
}

struct TalkItem: Decodable, Equatable {
  let talkId: Int
  let messageId: Int
  let userId: Int
  let nickname: String
  let imageId: Int
  let imageSize: String?
  let imageUrl: String?
  let message: String?
  let mediaId: Int?
  let mediaSize: String?
  let mediaUrl: String?
  let mediaType: Int?
  let time: String
  let messageKind: Int
  
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd"
    return formatter
  }()
  
  var timeSent: String {
    // yyyy/MM/dd HH:mm:ss.ffffff
    let time = time.split(separator: " ").last ?? ""
    let hhmm = (time.split(separator: ".").first ?? "").prefix(5)
    return String(hhmm)
  }
  
  var dateString: String {
    return String(time.prefix(10))
  }
  
  func isSentByMe(myUserId: Int) -> Bool {
    return userId == myUserId
  }
  
  func toProfileFeedItem() -> ProfileFeedItem {
    .init(userId: userId, nickname: nickname, aboutMe: "", imageId: imageId, imageSize: imageSize, imageUrl: imageUrl, residence: "", age: 0)
  }
  
  static func initWithEntity(_ entity: TalkItemEntity) -> TalkItem {
    return TalkItem(
      talkId: entity.talkId,
      messageId: entity.messageId,
      userId: entity.userId,
      nickname: entity.nickname,
      imageId: entity.imageId,
      imageSize: entity.imageSize,
      imageUrl: entity.imageUrl,
      message: entity.message,
      mediaId: entity.mediaId.value,
      mediaSize: entity.mediaSize,
      mediaUrl: entity.mediaUrl,
      mediaType: entity.mediaType.value,
      time: entity.time,
      messageKind: entity.messageKind)
  }
}

extension TalkItem: IdentifiableType {
  typealias Identity = Int
  
  var identity: Int { talkId }
}
