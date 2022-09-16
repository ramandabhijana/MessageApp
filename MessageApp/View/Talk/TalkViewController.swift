//
//  TalkViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 07/09/22.
//

import UIKit
import Photos
import RxSwift
import RxDataSources

class TalkViewController: UIViewController {
  private static let MAX_LINE_INPUT_TEXT = 3
  
  static func createFromStoryboard(presenter: TalkPresenterProtocol) -> TalkViewController {
    let name = String(describing: TalkViewController.self)
    let storyboard = UIStoryboard(name: name, bundle: nil)
    return storyboard.instantiateViewController(identifier: name) { coder in
      TalkViewController(coder: coder, presenter: presenter)
    }
  }
  
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat.pi))
      tableView.allowsSelection = false
      tableView.showsVerticalScrollIndicator = false
      tableView.separatorStyle = .none
      tableView.rowHeight = UITableView.automaticDimension
      tableView.register(
        MessageBubbleSentCell.self,
        forCellReuseIdentifier: MessageBubbleSentCell.reuseIdentifier)
      tableView.register(
        MessageBubbleReceivedCell.self,
        forCellReuseIdentifier: MessageBubbleReceivedCell.reuseIdentifier)
      tableView.register(
        VideoBubbleSentCell.self,
        forCellReuseIdentifier: VideoBubbleSentCell.reuseIdentifier)
      tableView.register(
        VideoBubbleReceivedCell.self,
        forCellReuseIdentifier: VideoBubbleReceivedCell.reuseIdentifier)
      tableView.register(
        PhotoBubbleSentCell.self,
        forCellReuseIdentifier: PhotoBubbleSentCell.reuseIdentifier)
      tableView.register(
        PhotoBubbleReceivedCell.self,
        forCellReuseIdentifier: PhotoBubbleReceivedCell.reuseIdentifier)
      tableView.register(TalkDateHeaderView.self, forHeaderFooterViewReuseIdentifier: TalkDateHeaderView.reuseIdentifier)
      tableView.contentInset.top = 50
    }
  }
  
  @IBOutlet private var inputAreaBottomView: UIView!
  @IBOutlet weak var inputTextView: UITextView!
  @IBOutlet weak var sendButton: UIButton!
  
  let infiniteScrollIndicator = UIActivityIndicatorView(style: .medium)
  private var inputAreaBottomConstraint: NSLayoutConstraint? = nil
  private let inputTextPlaceholderLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Type in your message"
    label.textColor = .placeholderText
    label.font = .preferredFont(forTextStyle: .caption1)
    return label
  }()
  private let keyboardResponder = KeyboardResponder()
  private let disposeBag = DisposeBag()
  private var presenter: TalkPresenterProtocol
  private var inputTextViewShouldScrollSubscription: Disposable?
  private let globalScheduler = ConcurrentDispatchQueueScheduler(queue: .global())
  private let videoThumbnailCache = NSCache<NSString, UIImage>()
  private lazy var tableViewDataSource = RxTableViewSectionedReloadDataSource<SectionOfTalkItem>(
    configureCell: { [unowned self] _, tableView, indexPath, talk in
      var cell: UITableViewCell
      if talk.isSentByMe(myUserId: presenter.currentUserId) {
        cell = bubbleSentCell(for: talk, tableView: tableView, indexPath: indexPath)
      } else {
        cell = bubbleReceivedCell(for: talk, tableView: tableView, indexPath: indexPath)
      }
      cell.transform = CGAffineTransform(rotationAngle: .pi)
      return cell
    })
  
  init?(coder: NSCoder, presenter: TalkPresenterProtocol) {
    self.presenter = presenter
    super.init(coder: coder)
    presenter.viewController = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupInputAreaBottomView()
    setupInputTextViewShouldEnableScroll()
    setupTableView()
    setupKeyboardInterruptionHandler()
    presenter.loadTalkWithOtherUser()
  }
  
  private func setupTableView() {
    let talkItemSections = presenter.talkItemSections.asObservable().skip(1).share()
    bindDataSourceToTableView(talkItemSections: talkItemSections)
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    
    let tapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(dismissEditing))
    tableView.isUserInteractionEnabled = true
    tableView.addGestureRecognizer(tapGesture)
  }
  
  private func setupKeyboardInterruptionHandler() {
    keyboardResponder.keyboardHeight
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] height in
        guard let self = self else { return }
        
        // To lift up the input area
        let adjustedHeight = height - KeyboardResponder.SOME_ADDITIONAL_PADDING - self.view.safeAreaInsets.bottom
        self.inputAreaBottomConstraint?.constant = -max(0, adjustedHeight)
        UIView.animate(withDuration: 0.5) {
          self.view.layoutIfNeeded()
        }
        
        // Since the tableview is upside down, we set the top content inset
        self.tableView.contentInset.top = (height + 50)
        
        // Scroll to bottom
        if !self.presenter.talkItemSections.value.isEmpty {
          let indexPath = IndexPath(row: 0, section: 0)
          self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func setupInputTextViewShouldEnableScroll() {
    inputTextView.rx.text
      .orEmpty
      .do(onNext: { [weak self] text in
        guard let self = self else { return }
        // Side effect to determine:
        //  whether to show the placeholder or not
        //  whether to enable the send button or not
        self.inputTextPlaceholderLabel.isHidden = text.count > 0
        self.sendButton.isEnabled = text.count > 0
      })
      .map { [unowned self] text -> Int in
        let attributedText = NSAttributedString(
          string: text,
          attributes: [.font: inputTextView.font as Any])
        let rect = attributedText.boundingRect(
          with: CGSize(width: inputTextView.bounds.width,
                       height: .greatestFiniteMagnitude),
          options: .usesLineFragmentOrigin,
          context: nil)
        return Int(rect.height / (inputTextView.font?.lineHeight ?? 1.0))
      }
      .subscribeOn(globalScheduler)
      .map { noOfLines -> Bool in
        return noOfLines > Self.MAX_LINE_INPUT_TEXT
      }
      .distinctUntilChanged()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] scrollEnabled in
        self?.inputTextView.isScrollEnabled = scrollEnabled
      })
      .disposed(by: disposeBag)
  }
  
  private func bindDataSourceToTableView(talkItemSections: Observable<[SectionOfTalkItem]>) {
    talkItemSections
      .bind(to: tableView.rx.items(dataSource: tableViewDataSource))
      .disposed(by: disposeBag)
  }
  
  func fetchLibraryAuthStatus(completion: @escaping (Bool) -> Void) {
    PHPhotoLibrary.fetchAuthorizationStatus(completion: completion)
  }
  
  @IBAction func didTapMediaButton(_ sender: UIButton) {
    presenter.presentMediaManage()
  }
  
  @IBAction func didTapSendButton(_ sender: UIButton) {
    dismissEditing()
    presenter.sendTextMessage(text: inputTextView.text)
  }
  
  @objc private func dismissEditing() {
    inputTextView.endEditing(true)
  }
}

extension TalkViewController {
  private func setupInputAreaBottomView() {
    inputTextView.layer.cornerRadius = 4
    inputTextView.layer.borderWidth = 1
    inputTextView.layer.borderColor = UIColor.separator.cgColor
    inputAreaBottomView.translatesAutoresizingMaskIntoConstraints = false
    inputTextView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(inputAreaBottomView)
    inputTextView.addSubview(inputTextPlaceholderLabel)
    
    inputAreaBottomConstraint = inputAreaBottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    
    NSLayoutConstraint.activate([
      inputAreaBottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      inputAreaBottomConstraint!,
      inputAreaBottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      inputTextPlaceholderLabel.centerYAnchor.constraint(equalTo: inputTextView.centerYAnchor),
      inputTextPlaceholderLabel.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor, constant: 8)
    ])
  }
}

extension TalkViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: TalkDateHeaderView.reuseIdentifier) as! TalkDateHeaderView
    let talkSection = presenter.talkItemSections.value[section]
    view.setText(talkSection.date)
    view.transform = CGAffineTransform(rotationAngle: .pi)
    return view
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 50.0
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let lastSection = presenter.talkItemSections.value.count - 1
    let lastIndexInLastSection = presenter.talkItemSections.value[lastSection].items.count - 1
    if indexPath == [lastSection, lastIndexInLastSection]  {
      infiniteScrollIndicator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44.0)
      tableView.tableFooterView = infiniteScrollIndicator
      tableView.tableFooterView?.isHidden = false
      let talk = presenter.talkItemSections.value[lastSection].items[lastIndexInLastSection]
      presenter.loadPastTalkPriorToTalk(withMessageId: talk.messageId)
    }
  }
}

extension TalkViewController {
  func bubbleSentCell(for talk: TalkItem, tableView: UITableView, indexPath: IndexPath) -> BaseBubbleSentCell {
    var cell: BaseBubbleSentCell
    guard let mediaType = talk.mediaType else { fatalError() }
    switch mediaType {
    case IMAGE_MEDIA_TYPE:
      cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PhotoBubbleSentCell.reuseIdentifier), for: indexPath) as! PhotoBubbleSentCell
      (cell as! PhotoBubbleSentCell).mediaTapResponder = MediaBubbleTapResponder(
        mediaURL: URL(string: talk.mediaUrl!),
        didTapMedia: presenter.presentPhotoViewer)
    case MOVIE_MEDIA_TYPE:
      cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VideoBubbleSentCell.reuseIdentifier), for: indexPath) as! VideoBubbleSentCell
      (cell as! VideoBubbleSentCell).mediaTapResponder = MediaBubbleTapResponder(
        mediaURL: URL(string: talk.mediaUrl!),
        didTapMedia: presenter.presentVideoViewer)
      if let cachedThumbnail = videoThumbnailCache.object(forKey: talk.mediaUrl! as NSString) {
        (cell as! VideoBubbleSentCell).mediaImageView.image = cachedThumbnail
      } else {
        getThumbnailImageFromVideoUrl(url: URL(string: talk.mediaUrl!)!) { [weak self] image in
          guard let image = image else { return }
          self?.videoThumbnailCache.setObject(image, forKey: talk.mediaUrl! as NSString)
          (cell as! VideoBubbleSentCell).mediaImageView.image = image
        }
      }
    default:
      cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MessageBubbleSentCell.reuseIdentifier), for: indexPath) as! MessageBubbleSentCell
      (cell as! MessageBubbleSentCell).messageLabel.text = talk.message
    }
    cell.timeLabel.text = talk.timeSent
    return cell
  }
  
  func bubbleReceivedCell(for talk: TalkItem, tableView: UITableView, indexPath: IndexPath) -> BaseBubbleReceivedCell {
    guard let mediaType = talk.mediaType else { fatalError() }
    var cell: BaseBubbleReceivedCell
    switch mediaType {
    case IMAGE_MEDIA_TYPE:
      cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PhotoBubbleReceivedCell.reuseIdentifier), for: indexPath) as! PhotoBubbleReceivedCell
      (cell as! PhotoBubbleReceivedCell).mediaTapResponder = MediaBubbleTapResponder(
        mediaURL: URL(string: talk.mediaUrl!),
        didTapMedia: presenter.presentPhotoViewer)
    case MOVIE_MEDIA_TYPE:
      cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VideoBubbleReceivedCell.reuseIdentifier), for: indexPath) as! VideoBubbleReceivedCell
      (cell as! VideoBubbleReceivedCell).mediaTapResponder = MediaBubbleTapResponder(
        mediaURL: URL(string: talk.mediaUrl!),
        didTapMedia: presenter.presentVideoViewer)
      if let cachedThumbnail = videoThumbnailCache.object(forKey: talk.mediaUrl! as NSString) {
        (cell as! VideoBubbleReceivedCell).mediaImageView.image = cachedThumbnail
      } else {
        getThumbnailImageFromVideoUrl(url: URL(string: talk.mediaUrl!)!) { [weak self] image in
          guard let image = image else { return }
          self?.videoThumbnailCache.setObject(image, forKey: talk.mediaUrl! as NSString)
          (cell as! VideoBubbleReceivedCell).mediaImageView.image = image
        }
      }
    default:
      cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MessageBubbleReceivedCell.reuseIdentifier), for: indexPath) as! MessageBubbleReceivedCell
      (cell as! MessageBubbleReceivedCell).messageLabel.text = talk.message
    }
    cell.timeLabel.text = talk.timeSent
    cell.profileItem = talk.toProfileFeedItem()
    cell.onTapProfilePicture = presenter.presentProfileDisplay
    loadImage(
      withURL: URL(string: talk.imageUrl!),
      imageView: cell.partnerProfileImageView,
      failureImage: defaultImage)
    return cell
  }
}
