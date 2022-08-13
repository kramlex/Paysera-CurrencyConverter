//
//  CurrencyAPI.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import Foundation
import Alamofire

enum CurrencyAPI: APIRouter {
  
  case getExchangeRate(fromAmount: Double, fromCurrency: Currency, toCurrency: Currency)
  
  var baseUrl: String {
    "http://api.evp.lt/currency/commercial/exchange"
  }
  
  var method: HTTPMethod {
    switch self {
    case .getExchangeRate:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .getExchangeRate(let fromAmount, let fromCurrency, let toCurrency):
      return "\(String(format: "%.2f", fromAmount))-\(fromCurrency.shortName)/\(toCurrency.shortName)/latest"
    }
  }
}
