//
//  Сurrencies.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import Foundation

protocol CurrencyType {
  var name: String? { get }
  var shortName: String { get }
  var id: Int { get }
}

enum Currency: CaseIterable, CurrencyType, Codable {
  
  var id: Int {
    shortName.hashValue
  }
  
  case eur
  case usd
  case jpy
  
  var name: String? {
    switch self {
    case .eur:
      return "Euro"
    case .usd:
      return "United States dollar"
    case .jpy:
      return "Japanese Yen"
    }
  }
  
  var shortName: String {
    switch self {
    case .eur:
      return "EUR"
    case .usd:
      return "USD"
    case .jpy:
      return "JPY"
    }
  }
  
  var startAmount: Double { 1000.0 }
}
