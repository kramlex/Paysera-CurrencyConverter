//
//  BehaviorSubject+Binding.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import RxCocoa
import RxSwift

infix operator <->
@discardableResult
func <-><T: Equatable>(property: ControlProperty<T>, variable: BehaviorSubject<T>) -> Disposable {
  let variableToProperty = variable.asObservable().bind(to: property)

    let propertyToVariable = property
        .subscribe(
            onNext: { variable.onNext($0) },
            onCompleted: { variableToProperty.dispose() }
    )

    return Disposables.create(variableToProperty, propertyToVariable)
}
