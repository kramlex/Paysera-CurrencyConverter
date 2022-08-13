//
//  DisposableContainer.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import Foundation
import RxSwift

protocol DisposableContainer {
  var disposeBag: DisposeBag! { get }
}
