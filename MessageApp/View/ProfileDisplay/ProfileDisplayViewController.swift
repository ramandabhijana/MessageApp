//
//  ProfileDisplayViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 23/08/22.
//

import UIKit

class ProfileDisplayViewController: UIViewController {
  static func createFromStoryboard() -> ProfileDisplayViewController {
    let name = String(describing: ProfileDisplayViewController.self)
    let storyboard = UIStoryboard(name: name, bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: name) as! ProfileDisplayViewController
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
