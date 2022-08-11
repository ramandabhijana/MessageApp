//
//  MyPageViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 03/08/22.
//

import UIKit
import Photos

class MyPageViewController: UIViewController {
  @IBOutlet var navigationBarTitleView: UIView!
  @IBOutlet weak var nickNameLabel: UILabel!
  @IBOutlet weak var userIDLabel: UILabel!
  
  static func createFromStoryboard(presenter: MyPagePresenterProtocol = MyPagePresenter(dataSource: MyPageDataSource())) -> MyPageViewController {
    let name = String(describing: MyPageViewController.self)
    let storyboard = UIStoryboard(name: name, bundle: nil)
    return storyboard.instantiateViewController(identifier: name) { coder in
      MyPageViewController(coder: coder, presenter: presenter)
    }
  }
  
  private static let LOGOUT_BTN_TITLE = "Logout"
  private static let SEGUE_ID_PROFILE_HEADER = "EmbedProfileHeader"
  private static let SEGUE_ID_PROFILE_MENU = "EmbedProfileMenu"
  
  private var presenter: MyPagePresenterProtocol
  private var headerViewControllerIndex: Int!
  
  init?(coder: NSCoder, presenter: MyPagePresenterProtocol) {
    self.presenter = presenter
    super.init(coder: coder)
    self.presenter.viewController = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.titleView = navigationBarTitleView
    setupLogoutButton()
    setHeaderViewControllerIndex()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    presenter.fetchData()
  }
  
  private func setupLogoutButton() {
    let button = UIBarButtonItem(
      title: Self.LOGOUT_BTN_TITLE,
      style: .plain,
      target: self,
      action: #selector(didTapLogout))
    button.tintColor = COLOR_APP_GREEN
    navigationItem.rightBarButtonItem = button
  }
  
  @objc private func didTapLogout() {
    let actions = [
      UIAlertAction(title: "Cancel", style: .cancel),
      UIAlertAction(title: "Continue", style: .destructive, handler: { [weak self] _ in
        self?.presenter.logout()
      })
    ]
    showAlert(title: "Log out",
              message: "You are about to log out. Continue?",
              actions: actions)
  }
  
  private func setHeaderViewControllerIndex() {
    guard let index = (children.enumerated()
      .filter { $0.element is ProfileHeaderViewController }
      .first
      .map(\.offset))
    else { return }
    headerViewControllerIndex = index
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Self.SEGUE_ID_PROFILE_HEADER {
      let headerViewController = segue.destination as! ProfileHeaderViewController
      headerViewController.delegate = self
    } else if segue.identifier == Self.SEGUE_ID_PROFILE_MENU {
      let menuViewController = segue.destination as! ProfileMenuViewController
      menuViewController.delegate = self
    }
  }
  
  func applyLoadingState() {
    nickNameLabel.backgroundColor = .placeholderText
    nickNameLabel.text = "User's Nick Name"
    nickNameLabel.textColor = .clear
    userIDLabel.backgroundColor = .placeholderText
    userIDLabel.text = "User ID"
    userIDLabel.textColor = .clear
  }
  
  func applyNormalState() {
    nickNameLabel.backgroundColor = .clear
    nickNameLabel.textColor = .label
    userIDLabel.backgroundColor = .clear
    userIDLabel.textColor = .label
  }
  
  func fetchLibraryAuthStatus(completion: @escaping (Bool) -> Void) {
    PHPhotoLibrary.fetchAuthorizationStatus(completion: completion)
  }
}


extension MyPageViewController: ProfileMenuViewControllerDelegate {
  func didSelectDisplayEmail() {
    presenter.displayEmailInfo()
  }
  
  func didSelectDisplayPassword() {
    presenter.displayPassword()
  }
  
  func didSelectTermCondition() {
    presenter.presentTermCondition()
  }
  
  func didSelectDeleteAccount() {
    presenter.presentDeleteAccountConfirmation()
  }
}

extension MyPageViewController: ProfileHeaderViewControllerDelegate {
  func didTapProfileImage() {
    presenter.presentMediaManageViewController(forceShow: false)
  }
  
  func didTapEditProfileButton() {
    presenter.pushEditProfileViewController()
  }
  
  func profileImageUrlFetched(_ url: URL?) {
    (children[headerViewControllerIndex] as! ProfileHeaderViewController)
      .setProfileImage(withURL: url)
  }
}

extension MyPageViewController: ReplaceDeleteProfileImageViewControllerDelegate {
  func didTapSelectImageButton() {
    presenter.presentMediaManageViewController(forceShow: true)
  }
  
  func didTapDeleteButton() {
    presenter.deleteProfileImage()
  }
}

