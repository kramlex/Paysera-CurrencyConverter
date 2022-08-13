//
//  UserDefaultsService+Methods.swift
//  CurrencyConverter
//
//  Created by mdubkov on 13.08.2022.
//

import Foundation

extension UserDefaultsService {
  static func setupAfterLaunch() {
    let isFirstLaunch = UserDefaultsService.isFirstLaunch
    if isFirstLaunch {
      UserDefaultsService.wallet = Currency.allCases
        .map { CurrencyWallet(currency: $0, amount: $0.startAmount) }
      UserDefaultsService.isFirstLaunch = false
    } else {
      let exists = UserDefaultsService.wallet
      UserDefaultsService.wallet = Currency.allCases
        .filter { currency in
          return !exists.contains { wallet in
            wallet.currency.id == currency.id
          }
        }.map { notExistCurrency in
          CurrencyWallet(currency: notExistCurrency, amount: notExistCurrency.startAmount)
        } + exists
    }
  }
  
//  static func 
}
