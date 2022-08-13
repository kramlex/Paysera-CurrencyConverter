//
//  Observable+Driver.swift
//  CurrencyConverter
//
//  Created by mdubkov on 13.08.2022.
//

import Foundation
import RxCocoa
import RxSwift

extension Observable {
  func asDefaultDriver() -> Driver<Element> {
    return map({ $0 as (Element?)})
      .asDriver(onErrorJustReturn: nil)
      .filter({ $0 != nil })
      .map({ $0! })
  }
}
