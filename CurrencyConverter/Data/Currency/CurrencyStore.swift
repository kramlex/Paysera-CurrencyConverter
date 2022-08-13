//
//  CurrencyStore.swift
//  CurrencyConverter
//
//  Created by mdubkov on 13.08.2022.
//

import Foundation
import RxSwift

protocol CurrencyStoreProtocol {
  func getExchangeRate(fromAmount: Double, fromCurrency: Currency, toCurrency: Currency) -> Observable<CurrencyExchangeResponse>
}

struct CurrencyStore: CurrencyStoreProtocol {
  
  func getExchangeRate(fromAmount: Double, fromCurrency: Currency, toCurrency: Currency) -> Observable<CurrencyExchangeResponse> {
    let router = CurrencyAPI.getExchangeRate(fromAmount: fromAmount, fromCurrency: fromCurrency, toCurrency: toCurrency)
    return sendRequest(router)
  }
}

