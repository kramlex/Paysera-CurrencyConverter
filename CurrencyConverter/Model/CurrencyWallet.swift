//
//  CurrencyWallet.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import Foundation

struct CurrencyWallet: Codable {
  let currency: Currency
  let amount: Double
  
  func withAmount(_ newAmount: Double) -> CurrencyWallet {
    CurrencyWallet(currency: currency, amount: newAmount)
  }
}
