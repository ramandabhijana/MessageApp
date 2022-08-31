//
//  FeedsToDetailTransitionAnimator.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 30/08/22.
//

import UIKit

class FeedsToDetailTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  let animationDuration = 0.5
  
  // the origin VC has to set this value
  var originFrame = CGRect.zero
  
  var operation: UINavigationController.Operation = .push
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return animationDuration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    if operation == .push {
      performPushTransition(context: transitionContext)
    } else if operation == .pop {
      performPopTransition(context: transitionContext)
    }
  }
  
  private func performPushTransition(context: UIViewControllerContextTransitioning) {
    guard let fromVC = context.viewController(forKey: .from) as? ProfileFeedViewController,
          let toVC = context.viewController(forKey: .to) as? ProfileDisplayViewController
    else {
      return
    }
    fromVC.navigationItem.title = ""
    fromVC.tabBarController?.tabBar.isHidden = true
    
    let finalFrame = context.finalFrame(for: toVC)
    let xScaleFactor = originFrame.width / finalFrame.width
    let yScaleFactor = originFrame.height / finalFrame.height
    let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
    
    toVC.view.transform = scaleTransform
    toVC.view.center = CGPoint(x: originFrame.midX, y: originFrame.midY)
    toVC.view.clipsToBounds = true
    
    context.containerView.addSubview(toVC.view)
    context.containerView.bringSubviewToFront(toVC.view)
    
    let fadeOutAnimation = CABasicAnimation(keyPath: "opacity")
    fadeOutAnimation.fromValue = 1.0
    fadeOutAnimation.toValue = 0.5
    fadeOutAnimation.duration = animationDuration
    fromVC.view.layer.add(fadeOutAnimation, forKey: nil)
    
    UIView.animate(
      withDuration: animationDuration,
      delay: 0.0,
      options: .curveEaseOut,
      animations: {
        toVC.view.transform = .identity
        toVC.view.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
      }, completion: { _ in
        context.completeTransition(true)
      })
  }
  
  private func performPopTransition(context: UIViewControllerContextTransitioning) {
    guard let fromVC = context.viewController(forKey: .from) as? ProfileDisplayViewController,
          let toVC = context.viewController(forKey: .to) as? ProfileFeedViewController
    else {
      return
    }
    toVC.navigationItem.title = APP_NAME
    fromVC.prepareForDismiss()
    
    let initialFrame = fromVC.view.frame
    let finalFrame = originFrame
    let xScaleFactor = finalFrame.width / initialFrame.width
    let yScaleFactor = finalFrame.height / initialFrame.height
    let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
    
    context.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
    
    let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
    fadeInAnimation.fromValue = 0.5
    fadeInAnimation.toValue = 1.0
    fadeInAnimation.duration = animationDuration
    toVC.view.layer.add(fadeInAnimation, forKey: nil)
    
    UIView.animate(
      withDuration: animationDuration,
      delay: 0.0,
      options: .curveEaseOut,
      animations: {
        fromVC.view.alpha = 0.5
        fromVC.view.transform = scaleTransform
        fromVC.view.center = CGPoint(x: self.originFrame.midX, y: self.originFrame.midY)
      }, completion: { _ in
        context.completeTransition(true)
      })
  }
}
