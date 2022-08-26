//
//  StateViews.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 24/08/22.
//

import UIKit

enum StateViews: Int {
  case loading = 1111
  case error = 4444
  case empty = 0101
}

var loadingView: UIStackView {
  let activityIndicator = UIActivityIndicatorView(style: .medium)
  activityIndicator.color = .label
  activityIndicator.startAnimating()
  let label = UILabel()
  label.text = "Loading data. Please wait..."
  label.textColor = .label
  label.font = .preferredFont(forTextStyle: .body)
  let loadingView = stateStackView(arrangedSubviews: [activityIndicator, label])
  loadingView.tag = StateViews.loading.rawValue
  return loadingView
}

func makeErrorView(withMessage message: String) -> UIView {
  let errorSymbol = UIImageView(image: UIImage(systemName: "exclamationmark.octagon", withConfiguration: UIImage.SymbolConfiguration(textStyle: .title1))?.withTintColor(.systemRed, renderingMode: .alwaysOriginal))
  let label = UILabel()
  label.numberOfLines = 0
  label.text = message
  label.font = .preferredFont(forTextStyle: .body)
  label.textColor = .systemRed
  let errorView = stateStackView(arrangedSubviews: [errorSymbol, label])
  errorView.tag = StateViews.error.rawValue
  return errorView
}

var emptyView: UIView {
  let symbol = UIImageView(image: UIImage(systemName: "rectangle.portrait.on.rectangle.portrait.slash", withConfiguration: UIImage.SymbolConfiguration(textStyle: .largeTitle))?.withTintColor(.placeholderText, renderingMode: .alwaysOriginal))
  let label = UILabel()
  label.numberOfLines = 0
  label.text = "No Data"
  label.font = .preferredFont(forTextStyle: .body)
  label.textColor = .placeholderText
  let emptyView = stateStackView(arrangedSubviews: [symbol, label])
  emptyView.tag = StateViews.empty.rawValue
  return emptyView
}

private func stateStackView(arrangedSubviews: [UIView]) -> UIStackView {
  let view = UIStackView(arrangedSubviews: arrangedSubviews)
  view.axis = .vertical
  view.alignment = .center
  view.distribution = .fill
  view.spacing = 8
  return view
}

extension UIView {
  func centeredConstraints(in view: UIView) -> [NSLayoutConstraint] {
    return [
      centerXAnchor.constraint(equalTo: view.centerXAnchor),
      leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),
      centerYAnchor.constraint(equalTo: view.centerYAnchor),
      topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
      trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
      bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
    ]
  }
}

extension UIViewController {
  func showLoadingView() {
    let loadingView = loadingView
    loadingView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(loadingView)
    NSLayoutConstraint.activate(loadingView.centeredConstraints(in: self.view))
  }
  
  func showErrorView(withMessage message: String) {
    let errorView = makeErrorView(withMessage: message)
    errorView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(errorView)
    NSLayoutConstraint.activate(errorView.centeredConstraints(in: self.view))
  }
  
  func showEmptyView() {
    let emptyView = emptyView
    emptyView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(emptyView)
    NSLayoutConstraint.activate(emptyView.centeredConstraints(in: self.view))
  }
  
  func removeLoadingView() {
    removeView(with: StateViews.loading.rawValue)
  }
  
  func removeErrorView() {
    removeView(with: StateViews.error.rawValue)
  }
  
  func removeEmptyView() {
    removeView(with: StateViews.empty.rawValue)
  }
  
  private func removeView(with tag: Int) {
    guard let targetView = view.viewWithTag(tag) else {
      return
    }
    targetView.removeFromSuperview()
  }
}
