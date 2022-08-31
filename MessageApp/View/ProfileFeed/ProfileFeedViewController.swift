//
//  ProfileFeedViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 03/08/22.
//

import UIKit
import RxSwift
import RxCocoa
import CHTCollectionViewWaterfallLayout

class ProfileFeedViewController: UIViewController {
  static func createFromStoryboard(presenter: ProfileFeedPresenterProtocol = ProfileFeedPresenter()) -> ProfileFeedViewController {
    let name = String(describing: ProfileFeedViewController.self)
    let storyboard = UIStoryboard(name: name, bundle: nil)
    return storyboard.instantiateViewController(identifier: name) { coder in
      ProfileFeedViewController(coder: coder, presenter: presenter)
    }
  }
  
  @IBOutlet weak var feedsCollectionView: UICollectionView! {
    didSet {
      feedsCollectionView.dataSource = self
      feedsCollectionView.delegate = self
      feedsCollectionView.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
      feedsCollectionView.alwaysBounceVertical = true
      feedsCollectionView.alwaysBounceHorizontal = false
      feedsCollectionView.collectionViewLayout = waterfallLayout
      feedsCollectionView.refreshControl = refreshControl
      feedsCollectionView.register(
        UINib(nibName: String(describing: ProfileFeedCell.self), bundle: nil),
        forCellWithReuseIdentifier: ProfileFeedCell.reuseIdentifier)
      feedsCollectionView.register(
        UINib(nibName: String(describing: LoadingCollectionReusableView.self), bundle: nil),
        forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
        withReuseIdentifier: LoadingCollectionReusableView.reuseIdentifier)
    }
  }
  
  private var presenter: ProfileFeedPresenterProtocol
  private let disposeBag = DisposeBag()
  private let transition = FeedsToDetailTransitionAnimator()
  private(set) var infiniteScrollIndicator: LoadingCollectionReusableView?
  private(set) var refreshControl = UIRefreshControl()
  
  private lazy var waterfallLayout: CHTCollectionViewWaterfallLayout = {
    let layout = CHTCollectionViewWaterfallLayout()
    layout.minimumColumnSpacing = 16.0
    layout.minimumInteritemSpacing = 16.0
    layout.columnCount = 2
    layout.footerHeight = INFINITE_SCROLL_INDICATOR_HEIGHT
    layout.itemRenderDirection = .shortestFirst
    return layout
  }()
  
  init?(coder: NSCoder, presenter: ProfileFeedPresenterProtocol) {
    self.presenter = presenter
    super.init(coder: coder)
    self.presenter.viewController = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = APP_NAME
    navigationController?.delegate = self
    presenter.loadInitialList()
    refreshControl.rx.controlEvent(.valueChanged)
      .subscribe { [weak self]  _ in
        self?.presenter.refreshFeedList()
      }
      .disposed(by: disposeBag)
  }
}

extension ProfileFeedViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    presenter.items.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileFeedCell.reuseIdentifier, for: indexPath) as! ProfileFeedCell
    cell.setupCell(data: presenter.items[indexPath.item])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard kind == UICollectionView.elementKindSectionFooter else {
      return UICollectionReusableView()
    }
    let infiniteScrollIndicator = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      withReuseIdentifier: LoadingCollectionReusableView.reuseIdentifier,
      for: indexPath) as! LoadingCollectionReusableView
    self.infiniteScrollIndicator = infiniteScrollIndicator
    return infiniteScrollIndicator
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if indexPath.row == presenter.items.count - 1
        && !presenter.showingInfiniteScrollIndicator {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
        self?.presenter.loadMoreFeeds()
      }
    }
  }
}

extension ProfileFeedViewController: CHTCollectionViewDelegateWaterfallLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cell = Bundle.main.loadNibNamed(String(describing: ProfileFeedCell.self), owner: self, options: nil)?.first as! ProfileFeedCell
    
    cell.setupCell(data: presenter.items[indexPath.item])
    cell.setNeedsLayout()
    cell.layoutIfNeeded()
    
    let width = (collectionView.frame.size.width / 2) - collectionView.contentInset.left - collectionView.contentInset.right
    let height = cell.systemLayoutSizeFitting(
      CGSize(width: width, height: .zero),
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel).height
    return CGSize(width: width, height: height)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let item = presenter.items[indexPath.item]
    let presenter = ProfileDisplayPresenter(feedItem: item)
    navigationController?.pushViewController(
      ProfileDisplayViewController.createFromStoryboard(presenter: presenter),
      animated: true)
  }
}

extension ProfileFeedViewController: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController,
                            animationControllerFor operation: UINavigationController.Operation,
                            from fromVC: UIViewController,
                            to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    if operation == .push {
      guard
        let selectedItemIndexPath = feedsCollectionView.indexPathsForSelectedItems?.last,
        let selectedCell = feedsCollectionView.cellForItem(at: selectedItemIndexPath) as? ProfileFeedCell,
        let selectedCellSuperview = selectedCell.superview
      else {
        return nil
      }

      transition.originFrame = selectedCellSuperview.convert(selectedCell.frame, to: nil)
      transition.originFrame = CGRect(
        x: transition.originFrame.origin.x,
        y: transition.originFrame.origin.y,
        width: transition.originFrame.size.width,
        height: transition.originFrame.size.height)
    }
    
    transition.operation = operation
    
    return transition
  }
}
