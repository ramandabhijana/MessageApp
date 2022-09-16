//
//  BaseBubbleSentCell.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 14/09/22.
//

import UIKit

open class BaseBubbleSentCell: UITableViewCell {
  let bubbleImageView: UIImageView = {
    let view = UIImageView(frame: .zero)
    view.contentMode = .scaleToFill
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
  
  public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayout()
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupLayout() {
    contentView.addSubview(bubbleImageView)
    contentView.addSubview(timeLabel)
    setupBubbleImageView()
    
    NSLayoutConstraint.activate([
      bubbleImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
      bubbleImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
      bubbleImageView.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 4),
      contentView.trailingAnchor.constraint(equalTo: bubbleImageView.trailingAnchor, constant: 16),
      timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 16),
      timeLabel.bottomAnchor.constraint(equalTo: bubbleImageView.bottomAnchor, constant: -8)
    ])
  }
  
  private func setupBubbleImageView() {
    let insets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 20)
    let image = UIImage(named: BUBBLE_RIGHT_IMAGE_NAME)!
      .imageFlippedForRightToLeftLayoutDirection()
    bubbleImageView.contentMode = .scaleToFill
    bubbleImageView.image = image.resizableImage(
      withCapInsets: insets, resizingMode: .stretch)
  }
}
