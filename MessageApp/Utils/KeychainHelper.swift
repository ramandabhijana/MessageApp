//
//  KeychainHelper.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 02/08/22.
//

import Foundation

final class KeychainHelper {
  static let shared = KeychainHelper()
  
  static let ACCESS_TOKEN_SERVICE = "access-token"
  static let TERRARESTA_ACCOUNT = "MessageAppTerraresta"
  
  private init() {}
  
  func save(_ data: Data, service: String = ACCESS_TOKEN_SERVICE, account: String = TERRARESTA_ACCOUNT, completion: @escaping (Bool) -> Void) {
    let query = [
      kSecValueData: data,
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: account,
    ] as CFDictionary
    
    let status = SecItemAdd(query, nil)
    
    // check if exist, if yes update
    if status == errSecDuplicateItem {
      let query = [
        kSecAttrService: service,
        kSecAttrAccount: account,
        kSecClass: kSecClassGenericPassword,
      ] as CFDictionary
      let attributesToUpdate = [kSecValueData: data] as CFDictionary
      SecItemUpdate(query, attributesToUpdate)
    }
    
    guard status == errSecSuccess else {
      print("Error with status: \(status)")
      completion(false)
      return
    }
    
    completion(true)
  }
  
  func readMessageAppTerrarestaAccessToken() -> Data? {
    let query = [
      kSecAttrService: Self.ACCESS_TOKEN_SERVICE,
      kSecAttrAccount: Self.TERRARESTA_ACCOUNT,
      kSecClass: kSecClassGenericPassword,
      kSecReturnData: true
    ] as CFDictionary
    var result: AnyObject?
    SecItemCopyMatching(query, &result)
    return (result as? Data)
  }
  
  func deleteMessageAppTerrarestaAccessToken() {
    let query = [
      kSecAttrService: Self.ACCESS_TOKEN_SERVICE,
      kSecAttrAccount: Self.TERRARESTA_ACCOUNT,
      kSecClass: kSecClassGenericPassword,
    ] as CFDictionary
    SecItemDelete(query)
  }
}
