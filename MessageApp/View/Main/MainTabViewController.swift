//
//  MainTabViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 02/08/22.
//

import UIKit

class MainTabViewController: UITabBarController {
  static func createFromStoryboard() -> MainTabViewController {
    let name = String(describing: MainTabViewController.self)
    let storyboard = UIStoryboard(name: name, bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: name) as! MainTabViewController
  }
  
  private static let PROFILE_FEED_TAB_TITLE = "Feed"
  private static let TALK_LIST_TAB_TITLE = "Message"
  private static let MY_PAGE_TAB_TITLE = "My Page"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViewControllers()
  }
  
  private func setupViewControllers() {
    viewControllers = [
      createProfileFeedViewController(),
      createTalkListViewController(),
      createMyPageViewController()
    ]
  }
  
  private func createProfileFeedViewController() -> UIViewController {
    let viewController = UINavigationController(rootViewController: ProfileFeedViewController.createFromStoryboard())
    viewController.tabBarItem.title = Self.PROFILE_FEED_TAB_TITLE
    viewController.tabBarItem.image = FEED_SYMBOL
    return viewController
  }
  
  private func createTalkListViewController() -> UIViewController {
    let viewController = UINavigationController(rootViewController: TalkListViewController.createFromStoryboard())
    viewController.tabBarItem.title = Self.TALK_LIST_TAB_TITLE
    viewController.tabBarItem.image = MESSAGE_SYMBOL
    return viewController
  }
  
  private func createMyPageViewController() -> UIViewController {
    let viewController = UINavigationController(rootViewController: MyPageViewController.createFromStoryboard())
    viewController.tabBarItem.title = Self.MY_PAGE_TAB_TITLE
    viewController.tabBarItem.image = PAGE_SYMBOL
    return viewController
  }
  
}
