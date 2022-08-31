//
//  ProfileDisplayViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 23/08/22.
//

import UIKit
import RxSwift
import Nuke

class ProfileDisplayViewController: UIViewController {
  static func createFromStoryboard(presenter: ProfileDisplayPresenterProtocol) -> ProfileDisplayViewController {
    let name = String(describing: ProfileDisplayViewController.self)
    let storyboard = UIStoryboard(name: name, bundle: nil)
    return storyboard.instantiateViewController(identifier: name) { coder in
      ProfileDisplayViewController(coder: coder, presenter: presenter)
    }
  }
  
  @IBOutlet weak var contentView: UIView!
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet weak var profileItemsStackView: UIStackView!
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var freewordTextView: UITextView!
  @IBOutlet weak var nicknameStackView: UIStackView!
  @IBOutlet weak var nicknameLabel: UILabel!
  @IBOutlet weak var ageStackView: UIStackView!
  @IBOutlet weak var ageLabel: UILabel!
  @IBOutlet weak var sexStackView: UIStackView!
  @IBOutlet weak var sexLabel: UILabel!
  @IBOutlet weak var occupancyStackView: UIStackView!
  @IBOutlet weak var occupancyLabel: UILabel!
  @IBOutlet weak var areaStackView: UIStackView!
  @IBOutlet weak var areaLabel: UILabel!
  @IBOutlet weak var hobbyStackView: UIStackView!
  @IBOutlet weak var hobbyLabel: UILabel!
  @IBOutlet weak var characterStackView: UIStackView!
  @IBOutlet weak var characterLabel: UILabel!
  @IBOutlet weak var sendMessageButton: UIButton!
  @IBOutlet weak var imageViewHeightConstraints: NSLayoutConstraint!
  
  private var presenter: ProfileDisplayPresenterProtocol
  private var shouldAnimateOnAppear = true
  private let disposeBag = DisposeBag()
  
  private lazy var itemsLoadingView: UIView = {
    let view = loadingView
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  let transitionImageView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleAspectFit
    view.backgroundColor = .clear
    view.layer.cornerRadius = PROFILE_DISPLAY_INITIAL_CORNER_RADIUS
    view.layer.masksToBounds = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  init?(coder: NSCoder, presenter: ProfileDisplayPresenterProtocol) {
    self.presenter = presenter
    super.init(coder: coder)
    self.presenter.viewController = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if shouldAnimateOnAppear {
      profileImageView.layer.cornerRadius = PROFILE_DISPLAY_INITIAL_CORNER_RADIUS
      profileImageView.layer.masksToBounds = true
      view.layer.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.0).cgColor
      for view in contentView.subviews {
        if view == profileImageView { continue }
        view.alpha = 0
      }
      sendMessageButton.alpha = 0
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Profile Detail"
    
    setupProfileImageView()
    setFreewordText(presenter.feedItem.aboutMe)
    nicknameLabel.text = presenter.feedItem.nickname
    
    presenter.fetchProfileData()

    presenter.loadingItems
      .compactMap { $0 }
      .subscribe(onNext: { [weak self] isLoading in
        guard let self = self else { return }
        if isLoading {
          self.setArrangedProfileItemsHidden(true)
          self.profileItemsStackView.addSubview(self.itemsLoadingView)
          NSLayoutConstraint.activate(self.itemsLoadingView.centeredConstraints(in: self.profileItemsStackView))
        } else {
          self.setArrangedProfileItemsHidden(false)
          self.itemsLoadingView.removeFromSuperview()
        }
      })
      .disposed(by: disposeBag)
    
    presenter.error
      .compactMap { $0 }
      .subscribe(onNext: { [weak self] error in
        self?.profileItemsStackView.isHidden = true
        self?.showError(error)
      })
      .disposed(by: disposeBag)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if shouldAnimateOnAppear {
      self.view.layer.backgroundColor = UIColor.systemBackground.cgColor
      UIView.animate(
        withDuration: 0.5,
        animations: {
          self.profileImageView.layer.cornerRadius = 0.0
          self.contentView.subviews.forEach { $0.alpha = 1 }
        },
        completion: { _ in
          self.shouldAnimateOnAppear = false
        })
      UIView.animate(
        withDuration: 0.5,
        delay: 0.5,
        animations: {
          self.sendMessageButton.alpha = 1
        },
        completion: nil)
    }
  }
  
  func prepareForDismiss() {
    let image = profileImageView.image!
    removeAllSubviews()
    transitionImageView.image = image
    view.addSubview(transitionImageView)
    view.backgroundColor = .clear
    let ratio = image.size.height / image.size.width
    NSLayoutConstraint.activate([
      transitionImageView.topAnchor.constraint(equalTo: view.topAnchor),
      transitionImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
      transitionImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
      transitionImageView.heightAnchor.constraint(equalTo: transitionImageView.widthAnchor, multiplier: ratio)
    ])
  }
  
  func removeAllSubviews() {
    view.subviews.forEach { $0.removeFromSuperview() }
  }
  
  private func setupProfileImageView() {
    loadImage(fromUrl: presenter.feedItem.imageURL)
    if let size = presenter.feedItem.imageSizeValue {
      imageViewHeightConstraints.constant = imageHeight(for: size)
      view.layoutIfNeeded()
    }
    let tapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(didTapProfileImageView(_:)))
    profileImageView.isUserInteractionEnabled = true
    profileImageView.addGestureRecognizer(tapGesture)
  }
  
  private func loadImage(fromUrl url: URL?) {
    let request = ImageRequest(url: url, processors: ProfileFeedCell.resizedImageProcessors)
    ImagePipeline.shared.loadImage(with: request) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure:
        self.profileImageView.image = defaultImage
        self.profileImageView.contentMode = .scaleAspectFit
      case .success(let response):
        self.profileImageView.image = response.image
        self.profileImageView.contentMode = .scaleAspectFill
      }
    }
  }
  
  private func imageHeight(for size: CGSize) -> CGFloat {
    return profileImageView.frame.width * (size.height / size.width)
  }
  
  private func setFreewordText(_ text: String) {
    if !text.isEmpty {
      freewordTextView.text = text
      return
    }
    freewordTextView.removeFromSuperview()
  }
  
  private func setArrangedProfileItemsHidden(_ hidden: Bool) {
    profileItemsStackView.arrangedSubviews
      .forEach { $0.isHidden = hidden }
  }
  
  @IBAction func didTapSendMessage(_ sender: UIButton) {
    // Ask presenter to present talk view Controller
    
  }
  
  @objc private func didTapProfileImageView(_ sender: UITapGestureRecognizer) {
    guard presenter.profileImageWasSet else { return }
    presenter.presentPhotoViewer(with: profileImageView.image)
  }
}

extension ProfileDisplayViewController {
  func setAgeLabelText(_ text: String?) {
    if let text = text {
      ageLabel.text = text
      return
    }
    ageStackView.removeFromSuperview()
  }
  
  func setSexLabelText(_ text: String?) {
    if let text = text {
      sexLabel.text = text
      return
    }
    sexStackView.removeFromSuperview()
  }
  
  func setOccupancyLabelText(_ text: String?) {
    if let text = text {
      occupancyLabel.text = text
      return
    }
    occupancyStackView.removeFromSuperview()
  }
  
  func setAreaLabelText(_ text: String?) {
    if let text = text {
      areaLabel.text = text
      return
    }
    areaStackView.removeFromSuperview()
  }
  
  func setHobbyLabelText(_ text: String?) {
    if let text = text {
      hobbyLabel.text = text
      return
    }
    hobbyStackView.removeFromSuperview()
  }
  
  func setCharacterLabelText(_ text: String?) {
    if let text = text {
      characterLabel.text = text
      return
    }
    characterStackView.removeFromSuperview()
  }
}
