//
//  WebViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 09/08/22.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
  private var webView: WKWebView!
  
  private let url: URL
  
  init(url: URL) {
    self.url = url
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    super.loadView()
    webView = WKWebView()
    webView.navigationDelegate = self
    view = webView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCloseButton()
    webView.load(URLRequest(url: url))
    webView.allowsBackForwardNavigationGestures = true
  }
  
  private func setupCloseButton() {
    let button = UIBarButtonItem(
      barButtonSystemItem: .close,
      target: self,
      action: #selector(didTapClose))
    button.tintColor = COLOR_APP_GREEN
    navigationItem.leftBarButtonItem = button
  }
  
  @objc private func didTapClose() {
    dismiss(animated: true)
  }
}
