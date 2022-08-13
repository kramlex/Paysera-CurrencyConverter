//
//  ConverterCoordinator.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import Foundation

final class ConverterCoordinator: BaseCoordinator {
  
  override func start() {
    let viewModel = ConverterViewModel()
    let viewController = ConverterViewController.create(viewModel: viewModel)
    window.rootViewController = beginInNewNavigation(viewController)
  }
}
