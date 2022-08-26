//
//  KeychainHelper.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 02/08/22.
//

import Foundation

final class KeychainHelper {
  static let shared = KeychainHelper()
  
  private init() {}
  
  func save<T>(_ data: T, service: String, account: String) where T : Codable {
    do {
      let encodedData = try JSONEncoder().encode(data)
      save(encodedData, service: service, account: account)
    } catch {
      assertionFailure("Fail to encode item for keychain: \(error)")
    }
  }
  
  func save(_ data: Data, service: String, account: String) {
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
  }
  
  func read<T>(service: String, account: String, type: T.Type) -> T? where T : Codable {
    guard let data = read(service: service, account: account) else {
      return nil
    }
    do {
      let item = try JSONDecoder().decode(type, from: data)
      return item
    } catch {
      assertionFailure("Fail to decode item for keychain: \(error)")
      return nil
    }
  }
  
  func read(service: String, account: String) -> Data? {
    let query = [
      kSecAttrService: service,
      kSecAttrAccount: account,
      kSecClass: kSecClassGenericPassword,
      kSecReturnData: true
    ] as CFDictionary
    var result: AnyObject?
    SecItemCopyMatching(query, &result)
    return (result as? Data)
  }
  
  func delete(service: String, account: String) {
    let query = [
      kSecAttrService: service,
      kSecAttrAccount: account,
      kSecClass: kSecClassGenericPassword,
    ] as CFDictionary
    SecItemDelete(query)
  }
}
