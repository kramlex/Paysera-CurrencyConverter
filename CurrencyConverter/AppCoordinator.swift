//
//  AppCoordinator.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import Foundation

final class AppCoordinator: BaseCoordinator {
  
  override func start() {
    let converterCoordinator = addDependency(ConverterCoordinator(window: window))
    converterCoordinator.start()
  }
}
