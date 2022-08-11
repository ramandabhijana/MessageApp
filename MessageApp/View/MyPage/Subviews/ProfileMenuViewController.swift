//
//  ProfileMenuViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 09/08/22.
//

import UIKit

protocol ProfileMenuViewControllerDelegate: AnyObject {
  func didSelectDisplayEmail()
  func didSelectDisplayPassword()
  func didSelectTermCondition()
  func didSelectDeleteAccount()
}

class ProfileMenuViewController: UITableViewController {
  
  weak var delegate: ProfileMenuViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    switch indexPath.section {
    case 0:
      if indexPath.row == 0 {
        delegate?.didSelectDisplayEmail()
      } else if indexPath.row == 1 {
        delegate?.didSelectDisplayPassword()
      }
    case 1:
      if indexPath.row == 0 {
        delegate?.didSelectTermCondition()
      } else if indexPath.row == 1 {
        delegate?.didSelectDeleteAccount()
      }
    default:
      break
    }
  }
}
