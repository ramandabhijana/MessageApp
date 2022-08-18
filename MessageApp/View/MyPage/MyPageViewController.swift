//
//  MyPageViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 03/08/22.
//

import UIKit
import Photos
import SDWebImage

class MyPageViewController: UITableViewController {
  @IBOutlet var navigationBarTitleView: UIView!
  @IBOutlet weak var nickNameLabel: UILabel!
  @IBOutlet weak var userIDLabel: UILabel!
  
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var editProfileButton: UIButton!
  
  static func createFromStoryboard(presenter: MyPagePresenterProtocol = MyPagePresenter(dataSource: MyPageDataSource())) -> MyPageViewController {
    let name = String(describing: MyPageViewController.self)
    let storyboard = UIStoryboard(name: name, bundle: nil)
    return storyboard.instantiateViewController(identifier: name) { coder in
      MyPageViewController(coder: coder, presenter: presenter)
    }
  }
  
  private static let LOGOUT_BTN_TITLE = "Logout"
  private static let defaultProfileImage = UIImage(systemName: "person.fill")?.withTintColor(.placeholderText)
  
  private var presenter: MyPagePresenterProtocol
  
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
    setupProfileImageView()
    setupEditProfileButton()
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
  
  private func setupProfileImageView() {
    DispatchQueue.main.async {
      self.profileImageView.layer.masksToBounds = true
      self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.width / 2
    }
    registerProfileImageViewTapGestureRecognizer()
  }
  
  private func setupEditProfileButton() {
    editProfileButton.layer.borderWidth = 1.5
    editProfileButton.layer.borderColor = UIColor.black.cgColor
    editProfileButton.layer.cornerRadius = 4
  }
  
  private func registerProfileImageViewTapGestureRecognizer() {
    let tapGesture = UITapGestureRecognizer(target: self,
                                     action: #selector(didTapProfileImageView(_:)))
    profileImageView.isUserInteractionEnabled = true
    profileImageView.addGestureRecognizer(tapGesture)
  }
  
  @objc private func didTapProfileImageView(_ sender: UITapGestureRecognizer) {
    presenter.presentMediaManageViewController(forceShow: false)
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
  
  func profileImageUrlFetched(_ url: URL?) {
    profileImageView.sd_setImage(with: url,
                                 placeholderImage: Self.defaultProfileImage)
  }
  
  @IBAction func didTapEditProfileButton(_ sender: Any) {
    presenter.pushEditProfileViewController()
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

extension MyPageViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    switch indexPath {
    case MyPageMenu.displayEmail.indexPath:
      presenter.displayEmailInfo()
    case MyPageMenu.displayPassword.indexPath:
      presenter.displayPassword()
    case MyPageMenu.termCondition.indexPath:
      presenter.presentTermCondition()
    case MyPageMenu.deleteAccount.indexPath:
      presenter.presentDeleteAccountConfirmation()
    default:
      break
    }
  }
}

enum MyPageMenu {
  case displayEmail
  case displayPassword
  case termCondition
  case deleteAccount
  
  var indexPath: IndexPath {
    switch self {
    case .displayEmail: return [1, 0]
    case .displayPassword: return [1, 1]
    case .termCondition: return [2, 0]
    case .deleteAccount: return [2, 1]
    }
  }
}
