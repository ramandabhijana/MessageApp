//
//  ProfileFeedPresenter.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 23/08/22.
//

import Foundation
import RxSwift
import RxRelay

protocol ProfileFeedPresenterProtocol: AnyObject {
  var viewController: ProfileFeedViewController? { get set }
  var items: [ProfileFeedItem] { get }
  var loading: Bool { get }
  var showingInfiniteScrollIndicator: Bool { get }
  
  func loadInitialList()
  func loadMoreFeeds()
  func refreshFeedList()
}

class ProfileFeedPresenter: ProfileFeedPresenterProtocol {
  
  weak var viewController: ProfileFeedViewController?
  
  private let dataSource = ProfileFeedDataSource()
  private let disposeBag = DisposeBag()
  
  var items: [ProfileFeedItem] { dataSource.items }
  var loading: Bool = false {
    didSet {
      loading
        ? viewController?.showLoadingView()
        : viewController?.removeLoadingView()
    }
  }
  var showingInfiniteScrollIndicator: Bool = false {
    didSet {
      let indicator = viewController?.infiniteScrollIndicator?.loadingView
      showingInfiniteScrollIndicator
        ? indicator?.startAnimating()
        : indicator?.stopAnimating()
    }
  }
  
  func loadInitialList() {
    loading = true
    dataSource.fetchProfileFeeds()
      .subscribeOn(MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] _ in
          guard let self = self else { return }
          if self.items.isEmpty {
            self.viewController?.showEmptyView()
          } else {
            self.viewController?.feedsCollectionView.reloadData()
          }
        },
        onError: { [weak self] error in
          var errorMessage = error.localizedDescription
          if let error = error as? APIError {
            errorMessage = error.message ?? "Unknown Error"
          }
          self?.viewController?.showErrorView(withMessage: errorMessage)
        },
        onDisposed: { [weak self] in
          self?.loading = false
        }
      )
      .disposed(by: disposeBag)
  }
  
  func loadMoreFeeds() {
    guard dataSource.canLoadMore else { return }
    showingInfiniteScrollIndicator = true
    let currentFeedItemsEndIndex = items.endIndex
    dataSource.fetchProfileFeeds(shouldUseLastLoginTime: true)
      .subscribe(
        onNext: { [weak self] _ in
          guard let self = self else { return }
          let newFeedItemsLastIndex = self.items.count - 1
          let needReloadIndexRange = currentFeedItemsEndIndex...newFeedItemsLastIndex
          let indexPaths = needReloadIndexRange.map { IndexPath(item: $0, section: 0) }
          self.viewController?.feedsCollectionView.insertItems(at: indexPaths)
        },
        onError: { [weak self] error in
          self?.viewController?.showError(error)
        },
        onDisposed: { [weak self] in
          self?.showingInfiniteScrollIndicator = false
        }
      )
      .disposed(by: disposeBag)
  }
  
  func refreshFeedList() {
    dataSource.fetchProfileFeeds(shouldAppendFetchedResults: false)
      .subscribeOn(MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] _ in
          guard let self = self else { return }
          self.viewController?.removeErrorView() // if any
          self.viewController?.removeEmptyView() // if any
          if self.items.isEmpty {
            self.viewController?.showEmptyView()
          }
          self.viewController?.feedsCollectionView.reloadData()
        },
        onError: { [weak self] error in
          self?.viewController?.showError(error)
        },
        onDisposed: {
          self.viewController?.refreshControl.endRefreshing()
        }
      )
      .disposed(by: disposeBag)
  }
}
