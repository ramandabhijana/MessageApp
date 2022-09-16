//
//  BaseBubbleReceivedCell.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 14/09/22.
//

import UIKit

open class BaseBubbleReceivedCell: UITableViewCell {
  let bubbleImageView: UIImageView = {
    let view = UIImageView(frame: .zero)
    view.contentMode = .scaleToFill
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  let partnerProfileImageView: UIImageView = {
    let view = UIImageView(frame: .zero)
    view.backgroundColor = .darkGray
    view.isUserInteractionEnabled = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  let timeLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.textColor = .black
    label.font = .preferredFont(forTextStyle: .caption1)
    label.numberOfLines = 1
    label.text = "09:40"
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  var profileItem: ProfileFeedItem? = nil
  var onTapProfilePicture: ((ProfileFeedItem) -> Void)? = nil
  
  public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayout()
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupLayout() {
    contentView.addSubview(bubbleImageView)
    contentView.addSubview(partnerProfileImageView)
    contentView.addSubview(timeLabel)
    maskPartnerImageViewCircle()
    setupBubbleImageView()
    
    NSLayoutConstraint.activate([
      bubbleImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
      bubbleImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
      bubbleImageView.leadingAnchor.constraint(equalTo: partnerProfileImageView.trailingAnchor, constant: 4),
      bubbleImageView.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -4),
      contentView.trailingAnchor.constraint(greaterThanOrEqualTo: timeLabel.trailingAnchor, constant: 16),
      timeLabel.bottomAnchor.constraint(equalTo: bubbleImageView.bottomAnchor, constant: -8),
      partnerProfileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      partnerProfileImageView.bottomAnchor.constraint(equalTo: bubbleImageView.bottomAnchor, constant: 8),
      partnerProfileImageView.heightAnchor.constraint(equalToConstant: 40),
      partnerProfileImageView.widthAnchor.constraint(equalTo: partnerProfileImageView.heightAnchor, multiplier: 1.0/1.0)
    ])
    
    let tapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(didTapPartnerImageView))
    partnerProfileImageView.addGestureRecognizer(tapGesture)
  }
  
  private func maskPartnerImageViewCircle() {
    DispatchQueue.main.async {
      self.partnerProfileImageView.layer.masksToBounds = true
      self.partnerProfileImageView.layer.cornerRadius = self.partnerProfileImageView.bounds.size.width / 2
    }
  }
  
  private func setupBubbleImageView() {
    let insets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 15)
    let image = UIImage(named: BUBBLE_LEFT_IMAGE_NAME)!
      .imageFlippedForRightToLeftLayoutDirection()
    bubbleImageView.contentMode = .scaleToFill
    bubbleImageView.image = image.resizableImage(
      withCapInsets: insets, resizingMode: .stretch)
  }
  
  @objc private func didTapPartnerImageView() {
    guard let profileItem = profileItem,
          let onTapProfilePicture = onTapProfilePicture else {
      return
    }
    onTapProfilePicture(profileItem)
  }
}
