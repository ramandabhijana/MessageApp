//
//  ProfileDisplayPresenter.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 29/08/22.
//

import Foundation
import RxSwift
import RxRelay

protocol ProfileDisplayPresenterProtocol: AnyObject {
  var viewController: ProfileDisplayViewController? { get set }
  var shouldIncludeSendMessageButton: Bool { get }
  var feedItem: ProfileFeedItem { get }
  var profileImageWasSet: Bool { get }
  var loadingItems: BehaviorRelay<Bool?> { get }
  var error: BehaviorRelay<Error?> { get }
  
  func fetchProfileData()
  func presentPhotoViewer(with image: UIImage?)
  func presentTalkViewController()
}

class ProfileDisplayPresenter: ProfileDisplayPresenterProtocol {
  var viewController: ProfileDisplayViewController?
  
  var loadingItems: BehaviorRelay<Bool?> = BehaviorRelay(value: nil)
  var error: BehaviorRelay<Error?> = BehaviorRelay(value: nil)
  
  private(set) var shouldIncludeSendMessageButton: Bool
  private let dataSource = ProfileDisplayDataSource()
  private let disposeBag = DisposeBag()
  
  let feedItem: ProfileFeedItem
  var profileImageWasSet: Bool { feedItem.imageId != UNSELECTED_INDEX }
  
  init(feedItem: ProfileFeedItem, shouldIncludeSendMessageButton: Bool = true) {
    self.feedItem = feedItem
    self.shouldIncludeSendMessageButton = shouldIncludeSendMessageButton
  }
  
  func fetchProfileData() {
    loadingItems.accept(true)
    dataSource.fetchProfileForUser(with: feedItem.userId)
      .subscribeOn(MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] _ in
          guard let self = self else { return }
          self.viewController?.setFreewordText(self.dataSource.freeword)
          var ageString: String? = nil
          if let age = self.dataSource.age {
            ageString = "\(age) y.o."
          }
          self.viewController?.setAgeLabelText(ageString)
          self.viewController?.setSexLabelText(self.dataSource.sex?.name)
          self.viewController?.setOccupancyLabelText(self.dataSource.occupancy?.name)
          self.viewController?.setAreaLabelText(self.dataSource.area)
          self.viewController?.setHobbyLabelText(self.dataSource.hobby)
          self.viewController?.setCharacterLabelText(self.dataSource.character?.name)
        
          self.loadingItems.accept(false)
        },
        onError: { [weak self] error in
          self?.loadingItems.accept(false)
          self?.error.accept(error)
        }
      )
      .disposed(by: disposeBag)
  }
  
  func presentPhotoViewer(with image: UIImage?) {
    guard let image = image else { return }
    let viewController = UINavigationController(rootViewController: PhotoViewerViewController.createFromStoryboard(image: image))
    viewController.modalPresentationStyle = .fullScreen
    self.viewController?.present(viewController, animated: true)
  }
  
  func presentTalkViewController() {
    let currentUserId = try! AuthManager.userId.get()
    let presenter = TalkPresenter(
      currentUserId: currentUserId,
      otherUserId: feedItem.userId)
    let viewController = TalkViewController.createFromStoryboard(presenter: presenter)
    self.viewController?.navigationController?.pushViewController(viewController, animated: true)
  }
}
