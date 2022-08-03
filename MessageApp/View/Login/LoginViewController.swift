//
//  LoginViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 01/08/22.
//

import UIKit

class LoginViewController: UIViewController {
  
  private let infoLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 32, weight: .light)
    label.numberOfLines = 0
    label.textAlignment = .center
    label.text = "Hello👋🏼,\nLoginViewController"
    return label
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Login"
    view.addSubview(infoLabel)
    view.backgroundColor = .systemBackground
    setupLabelConstraints()
  }
  
  private func setupLabelConstraints() {
    infoLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
  
  
}
