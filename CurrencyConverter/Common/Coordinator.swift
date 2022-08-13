//
//  Coordinator.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import Foundation

protocol Coordinator: AnyObject {
  var completionHandler: (() -> Void)? { get }
  func start()
  func clear()
}
