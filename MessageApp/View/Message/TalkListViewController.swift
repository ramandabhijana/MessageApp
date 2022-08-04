//
//  TalkListViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 03/08/22.
//

import UIKit

class TalkListViewController: UIViewController {
  static func createFromStoryboard() -> TalkListViewController {
    let name = String(describing: TalkListViewController.self)
    let storyboard = UIStoryboard(name: name, bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: name) as! TalkListViewController
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
}
