//
//  ProfileFeedViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 03/08/22.
//

import UIKit

class ProfileFeedViewController: UIViewController {
  static func createFromStoryboard() -> ProfileFeedViewController {
    let name = String(describing: ProfileFeedViewController.self)
    let storyboard = UIStoryboard(name: name, bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: name) as! ProfileFeedViewController
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
}
