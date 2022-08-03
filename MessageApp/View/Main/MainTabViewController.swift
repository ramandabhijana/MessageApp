//
//  MainTabViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 02/08/22.
//

import UIKit

class MainTabViewController: UITabBarController {
  static func createFromStoryboard() -> MainTabViewController {
    let name = String(describing: MainTabViewController.self)
    let storyboard = UIStoryboard(name: name, bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: name) as! MainTabViewController
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  
}
