//
//  FormSubmitButton.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 02/08/22.
//

import UIKit

class FormSubmitButton: UIButton {
  private(set) var buttonState: FormSubmitButtonState! {
    didSet {
      switch buttonState {
      case .disabled:
        configuration?.baseBackgroundColor = COLOR_DISABLED
        isUserInteractionEnabled = false
      case .enabled:
        if let buttonTitleText = buttonTitleText {
          configuration?.title = buttonTitleText
        }
        configuration?.baseBackgroundColor = COLOR_APP_ORANGE
        isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
      case .loading:
        buttonTitleText = configuration?.title
        configuration?.title = " "
        configuration?.baseBackgroundColor = COLOR_DISABLED
        isUserInteractionEnabled = false
        activityIndicator.startAnimating()
      case .none:
        break
      }
    }
  }
  
  private var buttonTitleText: String? = nil
  private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  func enable() {
    buttonState = .enabled
  }
  
  func disable() {
    buttonState = .disabled
  }
  
  func showLoading() {
    buttonState = .loading
  }
  
  private func setupView() {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = COLOR_APP_ORANGE
    configuration = config
    activityIndicator = UIActivityIndicatorView()
    activityIndicator.hidesWhenStopped = true
    activityIndicator.color = .white
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    addSubview(activityIndicator)
    activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    activityIndicator.stopAnimating()
  }
}

enum FormSubmitButtonState {
  case enabled
  case disabled
  case loading
}

