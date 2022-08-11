//
//  ProfileHeaderViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 08/08/22.
//

import UIKit
import SDWebImage

protocol ProfileHeaderViewControllerDelegate: AnyObject {
  func didTapProfileImage()
  func didTapEditProfileButton()
}

class ProfileHeaderViewController: UIViewController {
  
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var editProfileButton: UIButton!
  
  weak var delegate: ProfileHeaderViewControllerDelegate?
  
  private static let defaultProfileImage = UIImage(systemName: "person.fill")?.withTintColor(.placeholderText)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    DispatchQueue.main.async {
      self.profileImageView.layer.masksToBounds = true
      self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.width / 2
    }
    
    editProfileButton.layer.borderWidth = 1.5
    editProfileButton.layer.borderColor = UIColor.black.cgColor
    editProfileButton.layer.cornerRadius = 4
    
    registerProfileImageViewTapGestureRecognizer()
  }
  
  private func registerProfileImageViewTapGestureRecognizer() {
    let tapGesture = UITapGestureRecognizer(target: self,
                                     action: #selector(didTapProfileImageView(_:)))
    profileImageView.isUserInteractionEnabled = true
    profileImageView.addGestureRecognizer(tapGesture)
  }
  
  @objc private func didTapProfileImageView(_ sender: UITapGestureRecognizer) {
    delegate?.didTapProfileImage()
  }
  
  @IBAction func didTapEditProfileButton(_ sender: UIButton) {
    delegate?.didTapEditProfileButton()
  }
  
  func setProfileImage(withURL imageUrl: URL?) {
    profileImageView.sd_setImage(
      with: imageUrl,
      placeholderImage: Self.defaultProfileImage)
  }
}
