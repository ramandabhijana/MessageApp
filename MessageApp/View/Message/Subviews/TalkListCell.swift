//
//  TalkListCell.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 01/09/22.
//

import UIKit
import Nuke

class TalkListCell: UITableViewCell {
  static let reuseIdentifier = String(describing: TalkListCell.self)

  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var nicknameLabel: UILabel!
  @IBOutlet var messageLabel: UILabel!
  @IBOutlet weak var mainStackView: UIStackView!

  override func awakeFromNib() {
    super.awakeFromNib()
    DispatchQueue.main.async {
      self.profileImageView.layer.masksToBounds = true
      self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.width / 2
    }
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

  func configureView(with model: Model) {
    loadImage(withURL: URL(string: model.imageURLString ?? ""))
    nicknameLabel.text = model.nickname
    setMessageLabelText(model.message)
  }
  
  private func loadImage(withURL url: URL?) {
    let request = ImageRequest(url: url, processors: ProfileFeedCell.resizedImageProcessors)
    ImagePipeline.shared.loadImage(with: request) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure:
        self.profileImageView.image = defaultImage
        self.profileImageView.contentMode = .scaleAspectFit
      case .success(let response):
        self.profileImageView.image = response.image
        self.profileImageView.contentMode = .scaleAspectFill
      }
    }
  }
  
  private func setMessageLabelText(_ text: String?) {
    if let text = text {
      messageLabel.text = text
      return
    }
    messageLabel.text = "Let's start the conversation!"
    messageLabel.textColor = .placeholderText
  }
}

extension TalkListCell {
  struct Model {
    let imageURLString: String?
    let nickname: String
    let message: String?
  }
}
