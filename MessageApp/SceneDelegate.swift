//
//  SceneDelegate.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 01/08/22.
//

import UIKit
import Nuke
import RealmSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    
    // [[NSFileManager defaultManager] removeItemAtURL:[RLMRealmConfiguration defaultConfiguration].fileURL error:nil];
    
//    try! FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
    
//    let realm = try! Realm()
//    try! realm.write({
//      realm.deleteAll()
//    })
    
    // Set up cache
    DataLoader.sharedUrlCache.diskCapacity = .zero
    
    let pipeline = ImagePipeline { config in
      let dataCache = try? DataCache(name: APP_NAME)
      dataCache?.sizeLimit = 200 * 1024 * 1024 // 200MB
      config.dataCache = dataCache
    }
    
    ImagePipeline.shared = pipeline
    
    // Setup initial view controller
    let rootViewController: UIViewController
    if AuthManager.userExist {
      rootViewController = MainTabViewController.createFromStoryboard()
    } else {
      rootViewController = TopViewController.createFromStoryboard()
    }
    window?.rootViewController = rootViewController
    window?.makeKeyAndVisible()
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }

  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }


}

