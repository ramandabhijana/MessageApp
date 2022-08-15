//
//  InputTextField.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 04/08/22.
//

import UIKit

enum InputTextFieldState {
  case normal
  case error(message: String)
}

@IBDesignable
class InputTextField: UITextField {
  
  @IBInspectable
  private let label: UILabel = {
    let label = UILabel()
    label.text = "Field name"
    label.numberOfLines = 1
    label.font = .preferredFont(forTextStyle: .subheadline)
    return label
  }()
  
  private let errorLabel: UILabel = {
    let label = UILabel()
    label.text = "Error label"
    label.numberOfLines = 2
    label.font = .preferredFont(forTextStyle: .caption1)
    label.textColor = .systemRed
    return label
  }()
  
  private let textAreaRectLayer: CALayer = {
    let layer = CALayer()
    layer.cornerRadius = 4
    layer.borderWidth = 1.5
    layer.borderColor = UIColor.systemGray5.cgColor
    return layer
  }()
  
  private static let NAME_LABEL_HEIGHT: CGFloat = 20
  private static let TEXT_FIELD_HEIGHT: CGFloat = 44
  private static let HORIZONTAL_SPACE: CGFloat = 10
  
  private static let NORMAL_STATE_HEIGHT = NAME_LABEL_HEIGHT + TEXT_FIELD_HEIGHT
  private static let ERROR_LABEL_ANIMATION_DURATION: TimeInterval = 0.25
  
  var textFieldState: InputTextFieldState = .normal {
    didSet {
      switch textFieldState {
      case .normal:
        applyNormalAppearance()
      case .error(let message):
        applyErrorAppearance(withMessage: message)
      }
    }
  }
  
  override var intrinsicContentSize: CGSize {
    let height: CGFloat
    switch textFieldState {
    case .error(_):
      height = Self.NORMAL_STATE_HEIGHT + 15
    default:
      height = Self.NORMAL_STATE_HEIGHT
    }
    return CGSize(width: .greatestFiniteMagnitude, height: height)
  }
  
  @IBInspectable
  var fieldName: String = "" {
    didSet {
      self.label.text = fieldName
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    setupView()
  }
  
  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: textAreaInsets(bounds: bounds))
  }
  
  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: textAreaInsets(bounds: bounds))

  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if textAreaRectLayer.frame.width != layer.bounds.width {
      textAreaRectLayer.frame.size.width = layer.bounds.size.width
    }
  }
  
  private func textAreaInsets(bounds: CGRect) -> UIEdgeInsets {
    let textfieldWithLabelHeight = Self.NAME_LABEL_HEIGHT + Self.TEXT_FIELD_HEIGHT
    let topInset = (textfieldWithLabelHeight - bounds.size.height) / 2
    return UIEdgeInsets(top: topInset,
                        left: Self.HORIZONTAL_SPACE,
                        bottom: 0,
                        right: Self.HORIZONTAL_SPACE)
  }
  
  private func setupView() {
    borderStyle = .none
    autocorrectionType = .no
    
    DispatchQueue.main.async { [self] in
      
      var bounds = layer.bounds
      // Have to increase the height by 20 bcs we'll add padding along vertical axis by 20
      bounds.size.height += 20
      // After adding 20, the background layer height will shrink to 44 (Textfield's constant height) and its y coordinate is moved down by 20
      textAreaRectLayer.frame = bounds.insetBy(dx: 0, dy: 20)
      
      layer.addSublayer(textAreaRectLayer)

      addSubview(label)
      addSubview(errorLabel)
      errorLabel.alpha = 0
      
      label.translatesAutoresizingMaskIntoConstraints = false
      errorLabel.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Self.HORIZONTAL_SPACE),
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Self.HORIZONTAL_SPACE),
        label.bottomAnchor.constraint(equalTo: topAnchor, constant: 18),
        errorLabel.topAnchor.constraint(equalTo: bottomAnchor, constant: -15),
        errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Self.HORIZONTAL_SPACE),
        errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Self.HORIZONTAL_SPACE)
      ])
    }
  }
  
  private func applyErrorAppearance(withMessage errorMessage: String) {
    errorLabel.text = errorMessage
    invalidateIntrinsicContentSize()
    UIView.animate(withDuration: Self.ERROR_LABEL_ANIMATION_DURATION, animations: {
      self.textAreaRectLayer.borderColor = UIColor.systemRed.cgColor
      self.errorLabel.alpha = 1
    }, completion: nil)
  }
  
  private func applyNormalAppearance() {
    invalidateIntrinsicContentSize()
    UIView.animate(withDuration: Self.ERROR_LABEL_ANIMATION_DURATION, animations: {
      self.textAreaRectLayer.borderColor = UIColor.systemGray5.cgColor
      self.errorLabel.alpha = 0
    }, completion: nil)
  }
  
}

extension String {
  func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    
    return boundingBox.height
  }
}
