//
//  TalkListViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 03/08/22.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class TalkListViewController: UIViewController {
  static func createFromStoryboard(presenter: TalkListPresenterProtocol = TalkListPresenter()) -> TalkListViewController {
    let name = String(describing: TalkListViewController.self)
    let storyboard = UIStoryboard(name: name, bundle: nil)
    return storyboard.instantiateViewController(identifier: name) { coder in
      TalkListViewController(coder: coder, presenter: presenter)
    }
  }
  
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.refreshControl = refreshControl
      tableView.allowsMultipleSelectionDuringEditing = true
      tableView.register(
        UINib(nibName: String(describing: TalkListCell.self),
              bundle: nil),
        forCellReuseIdentifier: TalkListCell.reuseIdentifier)
    }
  }
  @IBOutlet var deleteButton: FormSubmitButton!
  
  lazy var cancelButtonItem: UIBarButtonItem = {
    let button = UIBarButtonItem.init(
      barButtonSystemItem: UIBarButtonItem.SystemItem.cancel,
      target: self,
      action: #selector(didTapCancelEdit))
    button.tintColor = COLOR_APP_GREEN
    return button
  }()
  override var editButtonItem: UIBarButtonItem {
    let item = super.editButtonItem
    item.action = #selector(didTapEdit(_:))
    item.tintColor = COLOR_APP_GREEN
    return item
  }
  private lazy var tableViewDataSource = RxTableViewSectionedAnimatedDataSource<SectionOfTalkListItem>(
    configureCell: { [unowned self] _, tableView, indexPath, talkItem in
      let cell = tableView.dequeueReusableCell(
        withIdentifier: TalkListCell.reuseIdentifier,
        for: indexPath) as! TalkListCell
      cell.configureView(with: TalkListCell.Model(
        imageURLString: talkItem.imageUrl,
        nickname: talkItem.nickname,
        message: presenter.createTalkMessage(for: talkItem)))
      return cell
    },
    canEditRowAtIndexPath: { _, _ in
      return true
    })

  private let refreshControl = UIRefreshControl()
  private let disposeBag = DisposeBag()
  private var presenter: TalkListPresenterProtocol
  
  init?(coder: NSCoder, presenter: TalkListPresenterProtocol) {
    self.presenter = presenter
    super.init(coder: coder)
    presenter.viewController = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.rightBarButtonItem = editButtonItem
    deleteButton.configuration?.title = "Delete"
    deleteButton.removeFromSuperview()
    
    bindDataSourceToTableView()
    
    refreshControl.rx.controlEvent(.valueChanged)
      .subscribe { [unowned self] _ in
        presenter.refreshTalkList()
      }
      .disposed(by: disposeBag)
    
    tableView.rx.modelSelected(TalkListItem.self)
      .subscribe(onNext: presenter.addTalkToDeleteList)
      .disposed(by: disposeBag)
    
    tableView.rx.modelDeselected(TalkListItem.self)
      .subscribe(onNext: presenter.removeTalkFromDeleteList)
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .subscribe(onNext: { [unowned self] indexPath in
        guard !tableView.isEditing else { return }
        // Handle navigation
        if let talkItem: TalkListItem = try? tableView.rx.model(at: indexPath),
           let currentUserId = try? AuthManager.userId.get(),
           let otherUserId = [talkItem.userId, talkItem.toUserId].filter({ $0 != currentUserId }).first
        {
          presenter.presentTalkViewController(userId: currentUserId, otherUserId: otherUserId)
        }
        tableView.deselectRow(at: indexPath, animated: true)
      })
      .disposed(by: disposeBag)
    
    presenter.getTalkList()
  }
  
  private func bindDataSourceToTableView() {
    presenter.talkItemSections
      .skip(1)
      .bind(to: tableView.rx.items(dataSource: tableViewDataSource))
      .disposed(by: disposeBag)
  }
  
  @objc private func didTapEdit(_ sender: UIBarButtonItem) {
    presenter.beginEditing()
  }
  
  @objc private func didTapCancelEdit() {
    presenter.endEditing()
  }
  
  @IBAction func didTapDeleteButton(_ sender: UIButton) {
    let noOfTalks = presenter.getSelectedTalksValue()!.count
    showAlert(
      title: "Warning",
      message: "You are about to delete \(noOfTalks) talk\(noOfTalks > 1 ? "s" : "")",
      actions: [
        UIAlertAction(title: "Cancel", style: .cancel),
        UIAlertAction(title: "Continue", style: .destructive, handler: { [weak self] _ in
          self?.presenter.deleteSelectedTalks()
        })
      ])
  }
  
  func bindToButton(deleteEnabledObservable: Observable<Bool>) {
    deleteEnabledObservable
      .map { canDelete in
        return canDelete
          ? FormSubmitButtonState.enabled
          : .disabled
      }
      .bind(to: deleteButton.rx.buttonState)
      .disposed(by: disposeBag)
  }
  
  func beginRefreshing() {
    refreshControl.beginRefreshing()
  }
  
  func endRefreshing() {
    refreshControl.endRefreshing()
  }
  
  func applyEditingAppearance() {
    UIView.animate(withDuration: 0.5,
                   animations: { [self] in
      view.backgroundColor = .systemBackground
      tableView.backgroundColor = .systemBackground
    }, completion: nil)
  }
  
  func applyNormalAppearance() {
    UIView.animate(withDuration: 0.5,
                   animations: { [self] in
      view.backgroundColor = .systemGroupedBackground
      tableView.backgroundColor = .systemGroupedBackground
    }, completion: nil)
  }
  
  func addDeleteButtonToSubviews() {
    UIView.transition(
      with: deleteButton,
      duration: 0.5,
      options: .transitionCrossDissolve,
      animations: { [self] in
        view.addSubview(deleteButton)
        NSLayoutConstraint.activate([
          deleteButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
          deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
          deleteButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
          deleteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
      },
      completion: nil)
  }
  
  func removeDeleteButtonFromSubviews() {
    UIView.transition(
      with: deleteButton,
      duration: 0.5,
      options: .transitionCrossDissolve,
      animations: { [self] in
        deleteButton.removeFromSuperview()
      }, completion: nil)
  }
}
