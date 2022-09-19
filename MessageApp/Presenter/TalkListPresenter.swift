//
//  TalkListPresenter.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 01/09/22.
//

import Foundation
import RxSwift
import RxRelay
import RxDataSources

protocol TalkListPresenterProtocol: AnyObject {
  var viewController: TalkListViewController? { get set }
  var talkItemSections: BehaviorRelay<[SectionOfTalkListItem]> { get }
  var selectedTalks: BehaviorSubject<[TalkListItem]>! { get }
  
  func beginEditing()
  func endEditing()
  
  func loadTalkList()
  func refreshTalkList()
  
  func addTalkToDeleteList(_ talk: TalkListItem)
  func removeTalkFromDeleteList(_ talk: TalkListItem)
  func getSelectedTalksValue() -> [TalkListItem]?
  func deleteSelectedTalks()
  func presentTalkViewController(userId: Int, otherUserId: Int)
  func createTalkMessage(for item: TalkListItem) -> String
}

class TalkListPresenter: TalkListPresenterProtocol {
  weak var viewController: TalkListViewController?
  
  private(set) var talkItemSections = BehaviorRelay(value: [SectionOfTalkListItem(sectionNo: 0, items: [])])
  private(set) var selectedTalks: BehaviorSubject<[TalkListItem]>!
  
  private let dataSource = TalkListDataSource()
  private let disposeBag = DisposeBag()
  
  func beginEditing() {
    guard !talkItemSections.value[0].items.isEmpty else {
      viewController?.showAlert(title: "No Data.", message: nil)
      return
    }
    selectedTalks = BehaviorSubject(value: [])
    viewController?.navigationItem.rightBarButtonItem = viewController?.cancelButtonItem
    viewController?.tableView.setEditing(true, animated: true)
    viewController?.applyEditingAppearance()
    viewController?.addDeleteButtonToSubviews()
    
    let canEnable = selectedTalks
      .map { !$0.isEmpty }
      .distinctUntilChanged()
    viewController?.bindToButton(deleteEnabledObservable: canEnable)
  }
  
  func endEditing() {
    selectedTalks.onCompleted()
    viewController?.navigationItem.rightBarButtonItem = viewController?.editButtonItem
    viewController?.tableView.setEditing(false, animated: true)
    viewController?.applyNormalAppearance()
    viewController?.removeDeleteButtonFromSubviews()
  }
  
  func loadTalkList() {
    viewController?.showLoadingView()
    dataSource.fetchTalkList()
      .map(\.items)
      .compactMap { $0 }
      .catchError { [weak self] error in
        self?.viewController?.showError(error)
        return Observable.just([])
      }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] talks in
        guard let self = self else { return }
        self.viewController?.removeLoadingView()
        var updatedSections = self.talkItemSections.value
        updatedSections[0].items = talks
        self.talkItemSections.accept(updatedSections)
      })
      .disposed(by: disposeBag)
  }
  
  func refreshTalkList() {
    viewController?.beginRefreshing()
    guard let tableView = viewController?.tableView,
          !tableView.isEditing
    else {
      viewController?.endRefreshing()
      return
    }
    dataSource.fetchNewTalkList()
      .map(\.items)
      .catchErrorJustReturn(nil)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] newTalks in
        self?.viewController?.endRefreshing()
        guard let self = self, let newTalks = newTalks else { return }
        var updatedSections = self.talkItemSections.value
        updatedSections[0].items = newTalks
        self.talkItemSections.accept(updatedSections)
      })
      .disposed(by: disposeBag)
  }
  
  func addTalkToDeleteList(_ talk: TalkListItem) {
    guard var selectedTalksValue = getSelectedTalksValue() else { return }
    selectedTalksValue.append(talk)
    selectedTalks.onNext(selectedTalksValue)
  }
  
  func removeTalkFromDeleteList(_ talk: TalkListItem) {
    guard var selectedTalksValue = getSelectedTalksValue() else { return }
    selectedTalksValue.removeAll(where: { $0 == talk })
    selectedTalks.onNext(selectedTalksValue)
  }
  
  func getSelectedTalksValue() -> [TalkListItem]? {
    guard let viewController = viewController,
          viewController.tableView.isEditing else {
      return nil
    }
    return try? selectedTalks.value()
  }
  
  func deleteSelectedTalks() {
    guard let talks = getSelectedTalksValue() else { return }
    viewController?.cancelButtonItem.isEnabled = false
    viewController?.deleteButton.buttonState = .loading
    dataSource.deleteTalks(talks)
      .subscribe(
        onNext: { [weak self] _ in
          guard let self = self else { return }
          var updatedTalks = self.talkItemSections.value[0].items
          for talk in talks {
            updatedTalks.removeAll(where: { $0 == talk})
          }
          var updatedSection = self.talkItemSections.value
          updatedSection[0].items = updatedTalks
          self.talkItemSections.accept(updatedSection)
          
          talks.forEach {
            let otherUserId = [$0.userId, $0.toUserId]
              .filter({ $0 != (try! AuthManager.userId.get()) })
              .first!
            let talkDataSource = TalkDataSource(otherUserId: otherUserId)
            talkDataSource.removeTalk()
          }
          
          self.endEditing()
        },
        onError: { [weak self] error in
          self?.viewController?.showError(error)
        },
        onDisposed: { [weak self] in
          self?.viewController?.cancelButtonItem.isEnabled = true
          self?.viewController?.deleteButton.buttonState = .enabled
        }
      )
      .disposed(by: disposeBag)
  }
  
  func presentTalkViewController(userId: Int, otherUserId: Int) {
    let presenter = TalkPresenter(
      currentUserId: userId,
      otherUserId: otherUserId,
      shouldRefreshBlock: { [weak self] refresh in
        if refresh { self?.refreshTalkList() }
      })
    viewController?.navigationController?.pushViewController(
      TalkViewController.createFromStoryboard(presenter: presenter),
      animated: true)
  }
  
  func createTalkMessage(for item: TalkListItem) -> String {
    if let mediaType = item.mediaType,
       let currentUserId = try? AuthManager.userId.get()
    {
      let sender = item.userId == currentUserId ? "You" : item.nickname
      switch mediaType {
      case IMAGE_MEDIA_TYPE:
        return "\(sender) sent a photo."
      case MOVIE_MEDIA_TYPE:
        return "\(sender) sent a video."
      default:
        return item.message
      }
    }
    return item.message
  }
}

struct SectionOfTalkListItem: AnimatableSectionModelType {
  typealias Identity = Int
  typealias Item = TalkListItem
  
  var sectionNo: Int
  var items: [Item]
  
  var identity: Int { sectionNo }
  
  init(sectionNo: Int, items: [SectionOfTalkListItem.Item]) {
    self.sectionNo = sectionNo
    self.items = items
  }
  
  init(original: SectionOfTalkListItem, items: [SectionOfTalkListItem.Item]) {
    self = original
    self.items = items
  }
}
