//
//  CurrencyExchangeResponse.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import Foundation

struct CurrencyExchangeResponse: Codable {
  let amount: String
  let currency: String
}
