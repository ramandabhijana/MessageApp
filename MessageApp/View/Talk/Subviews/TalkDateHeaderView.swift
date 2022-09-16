//
//  TalkDateHeaderView.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 08/09/22.
//

import UIKit

class TalkDateHeaderView: UITableViewHeaderFooterView {
  static let reuseIdentifier = String(describing: TalkDateHeaderView.self)
  
  private let textView: UITextView = {
    let view = UITextView(frame: .zero)
    view.textColor = .white
    view.backgroundColor = .lightGray
    view.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
    view.textAlignment = .center
    view.textContainerInset = UIEdgeInsets(top: 5, left: 50, bottom: 5, right: 50)
    view.layer.cornerRadius = 15
    view.isEditable = false
    view.isSelectable = false
    view.isScrollEnabled = false
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setText(_ text: String) {
    textView.text = text
  }
  
  private func setupView() {
    contentView.backgroundColor = .clear
    contentView.addSubview(textView)
    NSLayoutConstraint.activate([
      textView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      textView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
  }
}
