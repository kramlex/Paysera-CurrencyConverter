//
//  UserDefaultsService.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import Foundation
import RxSwift

private struct Constants {
  static let observeDebounce: RxTimeInterval = .milliseconds(100)
}

struct UserDefaultsService {
  
  @Storage(key: .isFirstLaunch, defaultValue: true)
  static var isFirstLaunch: Bool
  
  @Storage(key: .operationsCount, defaultValue: .zero)
  static var operationsCount: Int
  
  @CodableStorage(key: .wallet, defaultValue: [])
  static var wallet: [CurrencyWallet]
  
  
  static var walletObservable: Observable<[CurrencyWallet]> = UserDefaults.standard.rx
    .observe((Any).self, UserDefaultsKey.wallet.rawValue)
    .map { anyValue in
      let defaultValue: [CurrencyWallet] = []
      guard let anyValue = anyValue as? Data else { return defaultValue }
      return decode(anyValue, defaultValue: defaultValue)
    }
  
  static let operationsCountObservable: Observable<Int> = UserDefaults.standard.rx
    .observe(Int.self, UserDefaultsKey.operationsCount.rawValue)
    .map { $0 ?? .zero }
}

enum UserDefaultsKey: String {
  case isFirstLaunch = "isFirstLaunchKey"
  case operationsCount = "operationsCountKey"
  case wallet = "walletKey"
}

@propertyWrapper
struct Storage<T> {
  private let key: UserDefaultsKey
  private let defaultValue: T
  
  init(key: UserDefaultsKey, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
  }
  
  var wrappedValue: T {
    get {
      return UserDefaults.standard.object(forKey: key.rawValue) as? T ?? defaultValue
    }
    set {
      UserDefaults.standard.set(newValue, forKey: key.rawValue)
    }
  }
}

@propertyWrapper
struct CodableStorage<T: Codable> {
  private let key: UserDefaultsKey
  private let defaultValue: T
  
  init(key: UserDefaultsKey, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
  }
  
  var wrappedValue: T {
    get {
      guard let data = UserDefaults.standard.object(forKey: key.rawValue) as? Data else {
        return defaultValue
      }
      return decode(data, defaultValue: defaultValue)
    }
    set {
      let data = try? JSONEncoder().encode(newValue)
      
      UserDefaults.standard.set(data, forKey: key.rawValue)
    }
  }
}

private func decode<T: Codable>(_ data: Data, defaultValue: T) -> T {
  let value = try? JSONDecoder().decode(T.self, from: data)
  return value ?? defaultValue
}
