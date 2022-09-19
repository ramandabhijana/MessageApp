//
//  TalkPresenter.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 08/09/22.
//

import Foundation
import RxSwift
import RxRelay
import RxDataSources
import AVFoundation
import AVKit

protocol TalkPresenterProtocol: AnyObject {
  var viewController: TalkViewController? { get set }
  var currentUserId: Int { get }
  var talkItemSections: BehaviorRelay<[SectionOfTalkItem]> { get }
  
  var shouldRefreshTalkListOnBack: Bool { get }
  
  init(currentUserId: Int, otherUserId: Int, shouldRefreshBlock: @escaping (Bool) -> Void)
  
  func loadTalkWithOtherUser()
  func presentProfileDisplay(with profile: ProfileFeedItem)
  func presentMediaManage()
  func sendTextMessage(text: String)
  func presentPhotoViewer(imageURL: URL?)
  func presentVideoViewer(videoURL: URL?)
  func loadPastTalkPriorToTalk(withMessageId messageId: Int)
  func didTapBackButton()
}

class TalkPresenter: TalkPresenterProtocol {
  weak var viewController: TalkViewController?
  
  private(set) var talkItemSections: BehaviorRelay<[SectionOfTalkItem]> = BehaviorRelay(value: [])
  
  private static let sectionHeaderDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM yyyy"
    return formatter
  }()
  
  private let shouldRefreshBlock: (Bool) -> Void
  private(set) var shouldRefreshTalkListOnBack: Bool = false
  private(set) var currentUserId: Int
  private let otherUserId: Int
  private var sectionDateIndexLookupTable: [String: Int] = [:]
  private let dataSource: TalkDataSource
  private let disposeBag = DisposeBag()
  
  required init(currentUserId: Int, otherUserId: Int, shouldRefreshBlock: @escaping (Bool) -> Void) {
    self.shouldRefreshBlock = shouldRefreshBlock
    self.currentUserId = currentUserId
    self.otherUserId = otherUserId
    self.dataSource = TalkDataSource(otherUserId: otherUserId)
  }
  
  func didTapBackButton() {
    shouldRefreshBlock(shouldRefreshTalkListOnBack)
  }
  
  func loadTalkWithOtherUser() {
    viewController?.showLoadingView()
    dataSource.fetchTalks()
      .map(\.items)
      .catchError { [weak self] error in
        self?.viewController?.showError(error)
        return Observable.just([])
      }
      .observeOn(MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] talkItems in
          guard let self = self, let talkItems = talkItems else { return }
          self.appendToSections(talkItems)
        },
        onDisposed: { [weak self] in
          self?.viewController?.removeLoadingView()
        }
      )
      .disposed(by: disposeBag)
  }
  
  func loadPastTalkPriorToTalk(withMessageId messageId: Int) {
    viewController?.infiniteScrollIndicator.startAnimating()
    dataSource.fetchPastTalk(beforeMessageWithId: messageId)
      .map(\.items)
      .observeOn(MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] talkItems in
          guard let talkItems = talkItems else { return }
          self?.appendToSections(talkItems)
        },
        onError: { [weak self] error in
          self?.viewController?.showError(error)
        },
        onDisposed: { [weak self] in
          self?.viewController?.infiniteScrollIndicator.stopAnimating()
          self?.viewController?.tableView.tableFooterView?.isHidden = true
        })
      .disposed(by: disposeBag)
  }
  
  private func sectionDateString(for dateString: String) -> String {
    let date = TalkItem.dateFormatter.date(from: dateString)!
    if Calendar.current.isDateInToday(date) {
      return "Today"
    } else if Calendar.current.isDateInYesterday(date) {
      return "Yesterday"
    }
    return Self.sectionHeaderDateFormatter.string(from: date)
  }
  
  private func appendToSections(_ talkItems: [TalkItem]) {
    var talkItemSections: [SectionOfTalkItem] = self.talkItemSections.value
    for item in talkItems {
      let dateTimeSent = sectionDateString(for: item.dateString)
      if let sectionIndex = sectionDateIndexLookupTable[dateTimeSent] {
        talkItemSections[sectionIndex].items.append(item)
      } else {
        let newTalkItem = SectionOfTalkItem(date: dateTimeSent, items: [item])
        talkItemSections.append(newTalkItem)
        sectionDateIndexLookupTable[dateTimeSent] = talkItemSections.count-1
      }
    }
    self.talkItemSections.accept(talkItemSections)
  }
  
  private func insertFrontToTalkSections(talkItems: [TalkItem]) {
    var talkItemSections: [SectionOfTalkItem] = self.talkItemSections.value
    for item in talkItems {
      let dateTimeSent = sectionDateString(for: item.dateString)
      if let sectionIndex = sectionDateIndexLookupTable[dateTimeSent] {
        talkItemSections[sectionIndex].items.insert(item, at: 0)
      } else {
        let newTalkItem = SectionOfTalkItem(date: dateTimeSent, items: [item])
        talkItemSections.insert(newTalkItem, at: 0)
        sectionDateIndexLookupTable[dateTimeSent] = talkItemSections.count-1
      }
    }
    self.talkItemSections.accept(talkItemSections)
  }
}

// MARK: - TableView data source type
struct SectionOfTalkItem: SectionModelType {
  typealias Identity = String
  typealias Item = TalkItem
  
  var date: String
  var items: [TalkItem]
  
  var identity: String { date }
  
  init(date: String, items: [TalkItem]) {
    self.date = date
    self.items = items
  }
  
  init(original: SectionOfTalkItem, items: [TalkItem]) {
    self = original
    self.items = items
  }
}

// MARK: - Presentation
extension TalkPresenter {
  func presentProfileDisplay(with profile: ProfileFeedItem) {
    let presenter = ProfileDisplayPresenter(feedItem: profile, shouldIncludeSendMessageButton: false)
    let viewController = ProfileDisplayViewController.createFromStoryboard(
      presenter: presenter,
      shouldAnimateOnAppear: false)
    let navigationController = UINavigationController(rootViewController: viewController)
    let closeButton = UIBarButtonItem(
      image: UIImage(systemName: CLOSE_BTN_IMG_NAME),
      style: .plain,
      target: self,
      action: #selector(didTapClose))
    navigationController.modalPresentationStyle = .fullScreen
    viewController.navigationItem.leftBarButtonItem = closeButton
    self.viewController?.present(navigationController, animated: true)
  }
  
  @objc private func didTapClose() {
    viewController?.presentedViewController?.dismiss(animated: true)
  }
  
  func presentMediaManage() {
    viewController?.fetchLibraryAuthStatus(completion: { authorized in
      DispatchQueue.main.async { [weak self] in
        guard let self = self, let viewController = self.viewController else { return }
        guard authorized else {
          self.viewController?.showAlert(
            title: GALLERY_PERMISSION_DENIED,
            message: PERMISSION_DENIED_MESSAGE,
            actions: [viewController.openSettingsAction()])
          return
        }
        let presenter = MediaManagePresenter(allowsVideoAsset: true)
        let mediaViewController = MediaManageViewController.createFromStoryboard(presenter: presenter)
        mediaViewController.onSuccessUploadAsset = { [weak self] assetId, assetType in
          guard let self = self else { return }
          switch assetType {
          case .video:
            self.sendVideoMessage(videoId: assetId)
          case .image:
            self.sendPhotoMessage(photoId: assetId)
          default:
            return
          }
        }
        let navigationController = UINavigationController(rootViewController: mediaViewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.viewController?.present(navigationController, animated: true)
      }
    })
  }
  
  func presentPhotoViewer(imageURL: URL?) {
    guard let imageURL = imageURL else { return }
    let viewController = UINavigationController(rootViewController: PhotoViewerViewController.createFromStoryboard(imageURL: imageURL))
    viewController.modalPresentationStyle = .fullScreen
    self.viewController?.present(viewController, animated: true)
  }
  
  func presentVideoViewer(videoURL: URL?) {
    guard let videoURL = videoURL else {
      viewController?.showAlert(title: "Cannot play video", message: nil)
      return
    }
    let videoPlayerViewController = AVPlayerViewController()
    videoPlayerViewController.player = AVPlayer(url: videoURL)
    self.viewController?.present(videoPlayerViewController, animated: true) { videoPlayerViewController.player?.play() }
  }
}

// MARK: - Send Message
extension TalkPresenter {
  private func sendPhotoMessage(photoId: Int) {
    let sendMessageResponse = dataSource.sendPhoto(withId: photoId)
    handleSendMessageResponse(sendMessageResponse)
  }
  
  private func sendVideoMessage(videoId: Int) {
    let sendMessageResponse = dataSource.sendVideo(withId: videoId)
    handleSendMessageResponse(sendMessageResponse)
  }
  
  func sendTextMessage(text: String) {
    let sendMessageResponse = dataSource.sendMessage(text)
    handleSendMessageResponse(sendMessageResponse)
  }
  
  private func handleSendMessageResponse(_ sendMessageResponse: Observable<SendMessageResponse>) {
    var latestSentMessageId: Int? = nil
    if let latestTalkItemSection = talkItemSections.value.first,
       let latestTalkItem = latestTalkItemSection.items.first {
      latestSentMessageId = latestTalkItem.messageId
    }
    sendMessageResponse
      .flatMap { [weak self] response -> Observable<TalkResponse> in
        guard let self = self else { fatalError() }
        if let latestSentMessageId = latestSentMessageId {
          return self.dataSource.fetchLatestTalk(lastSentMessageId: latestSentMessageId)
        }
        return self.dataSource.fetchNewTalks()
      }
      .map(\.items)
      .observeOn(MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] talkItems in
          self?.shouldRefreshTalkListOnBack = true
          self?.viewController?.inputTextView.isScrollEnabled = false
          self?.viewController?.inputTextView.text = String()
          
          guard let talkItems = talkItems else { return }
          self?.insertFrontToTalkSections(talkItems: talkItems)
        },
        onError: { [weak self] error in
          self?.viewController?.showError(error)
        })
      .disposed(by: disposeBag)
  }
}
