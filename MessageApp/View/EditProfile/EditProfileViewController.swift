//
//  EditProfileViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 09/08/22.
//

import UIKit
import RxSwift
import RxCocoa

class EditProfileViewController: UIViewController {
  
  private enum FocusedField {
    case birthday, gender, occupation, area, character, freeword
  }

  private static let NAVIGATION_TITLE = "Profile Edit"
  private static let NO_OF_PICKER_COMPONENTS = 1
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var nickNameFieldLabel: UILabel! {
    didSet {
      let labelText = NSMutableAttributedString(string: "Nickname*")
      let fieldNameAttribute: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.label,
        .font: UIFont.preferredFont(forTextStyle: .body)
      ]
      let asteriskAttribute: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.systemRed,
        .font: UIFont.preferredFont(forTextStyle: .title3)
      ]
      labelText.addAttributes(fieldNameAttribute, range: NSRange(location: 0, length: labelText.length-1))
      labelText.addAttributes(asteriskAttribute, range: NSRange(location: labelText.length-1, length: 1))
      nickNameFieldLabel.attributedText = labelText
    }
  }
  @IBOutlet weak var nicknameTextField: UITextField! {
    didSet {
      nicknameTextField.text = presenter.nickName
    }
  }
  @IBOutlet weak var birthdayTextField: UITextField! {
    didSet {
      birthdayTextField.text = presenter.birthday
      birthdayTextField.inputAccessoryView = toolbar
      birthdayTextField.inputView = datePicker
    }
  }
  @IBOutlet weak var genderTextField: UITextField! {
    didSet {
      genderTextField.text = presenter.gender
      genderTextField.inputAccessoryView = toolbar
      genderTextField.inputView = pickerView
    }
  }
  @IBOutlet weak var occupationTextField: UITextField! {
    didSet {
      occupationTextField.text = presenter.occupation
      occupationTextField.inputAccessoryView = toolbar
      occupationTextField.inputView = pickerView
    }
  }
  @IBOutlet weak var areaTextField: UITextField! {
    didSet {
      areaTextField.text = presenter.area
      areaTextField.inputAccessoryView = toolbar
      areaTextField.inputView = pickerView
    }
  }
  @IBOutlet weak var hobbyLabel: UILabel! {
    didSet {
      hobbyLabel.text = presenter.hobby
    }
  }
  @IBOutlet weak var characterTextField: UITextField! {
    didSet {
      characterTextField.text = presenter.character
      characterTextField.inputAccessoryView = toolbar
      characterTextField.inputView = pickerView
    }
  }
  @IBOutlet weak var freewordTextView: UITextView! {
    didSet {
      setupFreewordCharacterCount()
      freewordTextView.text = presenter.freeword
      freewordTextView.inputAccessoryView = toolbar
    }
  }
  @IBOutlet weak var freewordCharacterCounterLabel: UILabel!
  
  private let freewordPlaceholderLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Write up to 200 characters"
    label.textColor = .placeholderText
    label.font = .preferredFont(forTextStyle: .caption1)
    return label
  }()
  private let datePicker: UIDatePicker = {
    let picker = UIDatePicker()
    picker.datePickerMode = .date
    picker.maximumDate = .now
    picker.preferredDatePickerStyle = .wheels
    picker.backgroundColor = .systemBackground
    return picker
  }()
  private lazy var toolbar: UIToolbar = {
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    let cancelButton = UIBarButtonItem(title: "Cancel",
                                       style: .plain,
                                       target: self,
                                       action: #selector(didTapCancelToolbar))
    let resetButton = UIBarButtonItem(title: "Reset",
                                      style: .plain,
                                      target: self,
                                      action: #selector(didTapResetToolbar))
    let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                      target: nil,
                                      action: nil)
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                     target: nil,
                                     action: #selector(didTapDoneToolbar))
    toolbar.setItems([cancelButton, resetButton, spaceButton, doneButton], animated: true)
    return toolbar
  }()
  lazy var pickerView: UIPickerView = {
    let picker = UIPickerView()
    picker.backgroundColor = .systemBackground
    picker.autoresizingMask = .flexibleWidth
    picker.contentMode = .center
    picker.dataSource = self
    picker.delegate = self
    return picker
  }()
  lazy var saveButton: UIBarButtonItem = {
    let button = UIBarButtonItem(
      title: SAVE_BTN_TITLE,
      style: .done,
      target: self,
      action: #selector(didTapSave))
    button.tintColor = COLOR_APP_GREEN
    return button
  }()
  lazy var backButton: UIBarButtonItem = {
    let button = UIBarButtonItem(
      image: UIImage(systemName: BACK_BTN_IMG_NAME,
                     withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
      style: .plain,
      target: self,
      action: #selector(didTapBack))
    return button
  }()
  private let progressIndicator: UIBarButtonItem = {
    let indicator = UIActivityIndicatorView()
    indicator.hidesWhenStopped = true
    return UIBarButtonItem(customView: indicator)
  }()
  
  private var presenter: EditProfilePresenterProtocol
  private var focusedPicker: BehaviorRelay<FocusedField?> = BehaviorRelay(value: nil)
  private let keyboardResponder = KeyboardResponder()
  private let disposeBag = DisposeBag()
  
  static func createFromStoryboard(presenter: EditProfilePresenterProtocol) -> EditProfileViewController {
    let name = String(describing: EditProfileViewController.self)
    let storyboard = UIStoryboard(name: name, bundle: nil)
    return storyboard.instantiateViewController(identifier: name) { coder in
      EditProfileViewController(coder: coder, presenter: presenter)
    }
  }
  
  init?(coder: NSCoder, presenter: EditProfilePresenterProtocol) {
    self.presenter = presenter
    super.init(coder: coder)
    self.presenter.viewController = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    navigationItem.hidesBackButton = true
    navigationItem.leftBarButtonItem = backButton
    navigationItem.title = Self.NAVIGATION_TITLE
    navigationItem.rightBarButtonItem = saveButton
    
    setupKeyboardInterruptionHandler()
    setupNameTextFieldValidation()
    setupFocusedField()
    registerTapGestureForHobbyLabel()
    setupFreewordPlaceholder()
    setupFocusedFieldListener()
  }
  
  @objc private func didTapSave() {
    presenter.submitEditedData()
  }
  
  @objc private func didTapBack() {
    presenter.dismissViewController()
  }
  
  func applyLoadingAppearance() {
    backButton.isEnabled = false
    navigationItem.title = "Saving changes..."
    navigationItem.rightBarButtonItem = progressIndicator
    (progressIndicator.customView as? UIActivityIndicatorView)?.startAnimating()
  }
  
  func applyNormalAppearance() {
    backButton.isEnabled = true
    navigationItem.title = Self.NAVIGATION_TITLE
    navigationItem.rightBarButtonItem = saveButton
    (progressIndicator.customView as? UIActivityIndicatorView)?.stopAnimating()
  }

  private func setupFreewordPlaceholder() {
    freewordTextView.addSubview(freewordPlaceholderLabel)
    NSLayoutConstraint.activate([
      freewordPlaceholderLabel.centerYAnchor.constraint(equalTo: freewordTextView.centerYAnchor),
      freewordPlaceholderLabel.leadingAnchor.constraint(equalTo: freewordTextView.leadingAnchor, constant: 8)
    ])
  }
  
  private func setupNameTextFieldValidation() {
    nicknameTextField.rx.text.orEmpty
      .map { String($0.prefix(MAX_CHARACTER_COUNT_FOR_NAME)) }
      .do(onNext: { [unowned self] text in
        saveButton.isEnabled = !text.isEmpty
        presenter.setNickname(name: text)
      })
      .bind(to: nicknameTextField.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func setupKeyboardInterruptionHandler() {
    keyboardResponder.keyboardHeight
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] height in
        self?.scrollView.contentInset.bottom = height
      }
      .disposed(by: disposeBag)
  }
  
  private func setupFocusedFieldListener() {
    focusedPicker
      .compactMap { $0 }
      .subscribe(onNext: { [unowned self] field in
        var selectedRow: Int = UNSELECTED_INDEX
        switch field {
        case .birthday:
          if let birthdayDate = EditProfilePresenter.birthdayDateFormatter.date(from: presenter.birthday) {
            datePicker.setDate(birthdayDate, animated: false)
          }
          return
        case .gender:
          presenter.loadSelectionListData(type: .gender)
          if let gender = presenter.dataSource.gender, let row = gender.keys.first {
            selectedRow = row
          }
        case .occupation:
          presenter.loadSelectionListData(type: .occupation)
          if let occupation = presenter.dataSource.job, let row = occupation.keys.first {
            selectedRow = row
          }
        case .area:
          presenter.loadSelectionListData(type: .area)
          if let area = presenter.dataSource.residence, let row = area.keys.first {
            selectedRow = row
          }
        case .character:
          presenter.loadSelectionListData(type: .character)
          if let character = presenter.dataSource.personality, let row = character.keys.first {
            selectedRow = row
          }
        case .freeword: break
        }
        pickerView.selectRow(selectedRow, inComponent: .zero, animated: false)
      })
      .disposed(by: disposeBag)
  }
}

extension EditProfileViewController {
  private func setupFocusedField() {
    let birthday = birthdayTextField.rx.controlEvent(.editingDidBegin)
      .map { FocusedField.birthday }
    let gender = genderTextField.rx.controlEvent(.editingDidBegin)
      .map { FocusedField.gender }
    let occupation = occupationTextField.rx.controlEvent(.editingDidBegin)
      .map { FocusedField.occupation }
    let area = areaTextField.rx.controlEvent(.editingDidBegin)
      .map { FocusedField.area }
    let character = characterTextField.rx.controlEvent(.editingDidBegin)
      .map { FocusedField.character }
    let freeword = freewordTextView.rx.didBeginEditing
      .map { FocusedField.freeword }
    Observable.of(birthday, gender, occupation, area, character, freeword).merge()
      .bind(to: focusedPicker)
      .disposed(by: disposeBag)
  }
  
  private func registerTapGestureForHobbyLabel() {
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapHobbyLabel(_:)))
    hobbyLabel.addGestureRecognizer(tapGestureRecognizer)
  }
  
  @objc private func didTapHobbyLabel(_ sender: UITapGestureRecognizer) {
    presenter.presentHobbySelectionViewController()
  }
  
  func updateHobbyLabelText(hobbies: String) {
    guard !hobbies.isEmpty else {
      hobbyLabel.text = "--"
      return
    }
    hobbyLabel.text = hobbies
  }
  
  private func setupFreewordCharacterCount() {
    freewordTextView.rx.text.orEmpty
      .map { String($0.prefix(MAX_FREEWORD_COUNT)) }
      .do(onNext: { [unowned self] text in
        freewordTextView.text = text
      })
      .map(\.count)
      .do(onNext: { [unowned self] count in
        freewordPlaceholderLabel.isHidden = count > 0
      })
      .subscribe(onNext: updateFreewordCharacterCounterLabel(count:))
      .disposed(by: disposeBag)
  }
  
  private func updateFreewordCharacterCounterLabel(count: Int) {
    freewordCharacterCounterLabel.text = "\(count)/\(MAX_FREEWORD_COUNT)"
  }
  
  @objc private func didTapCancelToolbar() {
    view.endEditing(true)
    guard let lastFocusedPicker = focusedPicker.value else { return }
    switch lastFocusedPicker {
    case .birthday:
      birthdayTextField.text = presenter.birthday
    case .gender:
      genderTextField.text = presenter.gender
    case .occupation:
      occupationTextField.text = presenter.occupation
    case .area:
      areaTextField.text = presenter.area
    case .character:
      characterTextField.text = presenter.character
    case .freeword:
      freewordTextView.text = presenter.freeword
    }
  }
  
  @objc private func didTapResetToolbar() {
    view.endEditing(true)
    guard let lastFocusedPicker = focusedPicker.value else { return }
    
    if lastFocusedPicker == .birthday {
      presenter.setBirthdayDate(date: nil)
      return
    }
    
    if lastFocusedPicker == .freeword {
      presenter.setFreeword(text: "")
      return
    }
    
    let selectedItem = presenter.selectionListData[UNSELECTED_INDEX]
    let itemDict = [UNSELECTED_INDEX: selectedItem]
    
    switch lastFocusedPicker {
    case .birthday, .freeword:
      break
    case .gender:
      presenter.setGender(itemDict: itemDict)
    case .occupation:
      presenter.setOccupation(itemDict: itemDict)
    case .area:
      presenter.setArea(itemDict: itemDict)
    case .character:
      presenter.setPersonality(itemDict: itemDict)
    }
  }
  
  @objc private func didTapDoneToolbar() {
    view.endEditing(true)
    
    guard let lastFocusedPicker = focusedPicker.value else { return }
    
    if lastFocusedPicker == .birthday {
      let selectedDate = datePicker.date
      presenter.setBirthdayDate(date: selectedDate)
      return
    }
    
    if lastFocusedPicker == .freeword {
      presenter.setFreeword(text: freewordTextView.text)
      return
    }
    
    let selectedRow = pickerView.selectedRow(inComponent: .zero)
    let selectedItem = presenter.selectionListData[selectedRow]
    let itemDict = [selectedRow: selectedItem]
    
    switch lastFocusedPicker {
    case .birthday, .freeword:
      break
    case .gender:
      presenter.setGender(itemDict: itemDict)
    case .occupation:
      presenter.setOccupation(itemDict: itemDict)
    case .area:
      presenter.setArea(itemDict: itemDict)
    case .character:
      presenter.setPersonality(itemDict: itemDict)
    }
  }
}

// MARK: - Picker view data source
extension EditProfileViewController: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    EditProfileViewController.NO_OF_PICKER_COMPONENTS
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    presenter.selectionListData.count
  }
}

extension EditProfileViewController: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    presenter.selectionListData[row].name
  }
}
