//
//  EditProfilePresenter.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 16/08/22.
//

import Foundation
import RxSwift

protocol EditProfilePresenterProtocol {
  var viewController: EditProfileViewController? { get set }
  var dataSource: EditProfileDataSource { get }
  var selectionListData: [ProfileListItem] { get }
  var nickName: String { get }
  var birthday: String { get }
  var gender: String { get }
  var occupation: String { get }
  var area: String { get }
  var hobby: String { get }
  var character: String { get }
  var freeword: String { get }
  
  func loadSelectionListData(type: SelectionListType)
  func setNickname(name: String)
  func setBirthdayDate(date: Date?)
  func setGender(itemDict: [Int: ProfileListItem]?)
  func setOccupation(itemDict: [Int: ProfileListItem]?)
  func setArea(itemDict: [Int: ProfileListItem]?)
  func setPersonality(itemDict: [Int: ProfileListItem]?)
  func setFreeword(text: String)
  func presentHobbySelectionViewController()
  func submitEditedData()
  func dismissViewController()
}

class EditProfilePresenter: EditProfilePresenterProtocol {
  weak var viewController: EditProfileViewController?
  
  var dataSource: EditProfileDataSource
  
  var selectionListData: [ProfileListItem] { dataSource.selectionListData }
  
  var nickName: String {
    dataSource.nickname
  }
  var birthday: String {
    dataSource.birthday ?? ""
  }
  var gender: String {
    guard let gender = dataSource.gender,
          !gender.keys.contains(UNSELECTED_INDEX) else {
      return "--"
    }
    return gender.values.first!.name
  }
  var occupation: String {
    guard let occupation = dataSource.job,
          !occupation.keys.contains(UNSELECTED_INDEX) else {
      return "--"
    }
    return occupation.values.first!.name
  }
  var area: String {
    guard let area = dataSource.residence,
          !area.keys.contains(UNSELECTED_INDEX) else {
      return "--"
    }
    return area.values.first!.name
  }
  var hobby: String {
    let hobbies = dataSource.allHobbiesString
    return hobbies.isEmpty ? "--" : hobbies
  }
  var character: String {
    guard let character = dataSource.personality,
          !character.keys.contains(UNSELECTED_INDEX) else {
      return "--"
    }
    return character.values.first!.name
  }
  var freeword: String {
    dataSource.aboutMe ?? ""
  }
  
  private let disposeBag = DisposeBag()
  
  private var loading: Bool = false {
    didSet {
      loading ? viewController?.applyLoadingAppearance() : viewController?.applyNormalAppearance()
    }
  }
  
  static let birthdayDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy/MM/dd"
    return dateFormatter
  }()
  
  init(dataSource: EditProfileDataSource) {
    self.dataSource = dataSource
  }
  
  func loadSelectionListData(type: SelectionListType) {
    dataSource.loadSelectionListData(type: type)
    viewController?.pickerView.reloadAllComponents()
  }
  
  func setNickname(name: String) {
    dataSource.nickname = name
    viewController?.saveButton.isEnabled = !name.isEmpty
  }
  
  func setBirthdayDate(date: Date?) {
    if let date = date {
      let birthday = Self.birthdayDateFormatter.string(from: date)
      dataSource.birthday = birthday
    } else {
      dataSource.birthday = nil
    }
    viewController?.birthdayTextField.text = birthday
  }
  
  func setGender(itemDict: [Int : ProfileListItem]?) {
    dataSource.gender = itemDict
    viewController?.genderTextField.text = gender
  }
  
  func setOccupation(itemDict: [Int : ProfileListItem]?) {
    dataSource.job = itemDict
    viewController?.occupationTextField.text = occupation
  }
  
  func setArea(itemDict: [Int : ProfileListItem]?) {
    dataSource.residence = itemDict
    viewController?.areaTextField.text = area
  }
  
  func setPersonality(itemDict: [Int : ProfileListItem]?) {
    dataSource.personality = itemDict
    viewController?.characterTextField.text = character
  }
  
  func setFreeword(text: String) {
    dataSource.aboutMe = text
    viewController?.freewordTextView.text = text
  }
  
  func presentHobbySelectionViewController() {
    let dataSource = SelectionDataSource(type: .hobby, allowMultipleSelection: true, selectedItems: dataSource.hobbies ?? [:])
    let hobbyViewController = SelectionViewController.createFromStoryboard(
      dataSource: dataSource,
      didSaveSelections: { [weak self] selections in
        self?.dataSource.hobbies = selections
        self?.viewController?.updateHobbyLabelText(hobbies: selections.values.map(\.name).joined(separator: HOBBY_SEPARATOR))
      })
    hobbyViewController.modalPresentationStyle = .fullScreen
    self.viewController?.present(hobbyViewController, animated: true)
  }
  
  func submitEditedData() {
    guard dataSource.checkHasMadeChanges() else {
      viewController?.showAlert(title: "No changes", message: "You have to make some changes to your profile data")
      return
    }
    loading = true
    
    let token = AuthManager.accessToken
    if case .failure(let error) = token {
      viewController?.showError(error)
    }
    guard case .success(let accessToken) = token else { return }
    
    let editRequest = EditProfileRequest(
      accessToken: accessToken,
      nickname: dataSource.nickname,
      birthday: dataSource.birthday,
      residence: dataSource.residence?.values.first?.name ?? "",
      gender: dataSource.gender?.values.first?.id ?? UNSELECTED_INDEX,
      job: dataSource.job?.values.first?.id ?? UNSELECTED_INDEX,
      personality: dataSource.personality?.values.first?.id ?? UNSELECTED_INDEX,
      hobby: dataSource.editedProfile.hobby ?? "",
      aboutMe: dataSource.aboutMe ?? "")
    TerrarestaAPIClient.performRequest(editRequest)
      .subscribe(
        onNext: { [weak self] response in
          guard response.status == SUCCESS_STATUS_CODE else { return }
          self?.viewController?.applyNormalAppearance()
          self?.viewController?.showAlert(
            title: "Data Saved",
            message: "Your profile edit data was saved successfully",
            actions: [
              UIAlertAction(title: "Dismiss", style: .default) { _ in
                self?.viewController?.navigationController?.popViewController(animated: true)
              }
            ])
        },
        onError: { [weak self] error in
          self?.viewController?.applyNormalAppearance()
          self?.viewController?.showError(error)
        }
      )
      .disposed(by: disposeBag)
  }
  
  func dismissViewController() {
    let madeChanges = dataSource.checkHasMadeChanges()
    guard madeChanges else {
      viewController?.navigationController?.popViewController(animated: true)
      return
    }
    viewController?.showAlert(
      title: "Data is not saved",
      message: "Do you want to discard the corrected data?",
      actions: [
        UIAlertAction(title: "No", style: .cancel),
        UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
          self?.viewController?.navigationController?.popViewController(animated: true)
        }
      ])
  }
}
