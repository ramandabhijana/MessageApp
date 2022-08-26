//
//  LoadingCollectionReusableView.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 25/08/22.
//

import UIKit

class LoadingCollectionReusableView: UICollectionReusableView {
  static let reuseIdentifier = String(describing: LoadingCollectionReusableView.self)
  
  @IBOutlet weak var loadingView: UIActivityIndicatorView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
}
