//
//  InputField.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 01/08/22.
//

import UIKit

class InputField: UIView {
  @IBOutlet private var contentView: UIView!
  @IBOutlet weak var fieldLabel: UILabel!
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var errorMessageLabel: UILabel!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  func showError(with errorMessage: String) {
    UIView.animate(withDuration: 0.25, animations: { [errorMessageLabel] in
      errorMessageLabel?.isHidden = false
      errorMessageLabel?.text = errorMessage
    }, completion: nil)
  }
  
  func hideError() {
    UIView.animate(withDuration: 0.25, animations: { [self] in
      errorMessageLabel?.isHidden = true
      errorMessageLabel?.text = " "
    }, completion: nil)
  }
  
  private func setupView() {
    Bundle.main.loadNibNamed(String(describing: InputField.self), owner: self, options: nil)
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    contentView.translatesAutoresizingMaskIntoConstraints = true
    addSubview(contentView)
    hideError()
  }
  

}
