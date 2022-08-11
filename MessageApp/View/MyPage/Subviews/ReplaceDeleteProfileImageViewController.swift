//
//  ReplaceDeleteProfileImageViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 08/08/22.
//

import UIKit
import RxCocoa
import RxSwift

protocol ReplaceDeleteProfileImageViewControllerDelegate: AnyObject {
  func didTapSelectImageButton()
  func didTapDeleteButton()
}

class ReplaceDeleteProfileImageViewController: UIViewController {
  @IBOutlet weak var selectImageButton: UIButton!
  @IBOutlet weak var deleteButton: UIButton!
  
  static func createFromStoryboard() -> ReplaceDeleteProfileImageViewController {
    let name = String(describing: ReplaceDeleteProfileImageViewController.self)
    let storyboard = UIStoryboard(name: name, bundle: nil)
    return storyboard.instantiateViewController(identifier: name) { coder in
      return ReplaceDeleteProfileImageViewController(coder: coder)
    }
  }
  
  weak var delegate: ReplaceDeleteProfileImageViewControllerDelegate?
  
  private let disposeBag = DisposeBag()
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureButtonAppearance(forButton: selectImageButton)
    configureButtonAppearance(forButton: deleteButton)
    
    selectImageButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.dismiss(animated: true)
        self?.delegate?.didTapSelectImageButton()
      })
      .disposed(by: disposeBag)
    
    deleteButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.dismiss(animated: true)
        self?.delegate?.didTapDeleteButton()
      })
      .disposed(by: disposeBag)
    
  }
  
  private func configureButtonAppearance(forButton button: UIButton) {
    button.layer.borderWidth = 1.5
    button.layer.borderColor = UIColor.black.cgColor
    button.layer.cornerRadius = 4
  }
}
