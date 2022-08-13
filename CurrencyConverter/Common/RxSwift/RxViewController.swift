//
//  RxViewController.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import UIKit
import RxSwift

class RxUIViewController: UIViewController, DisposableContainer {
  var disposeBag: DisposeBag!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.disposeBag = DisposeBag()
  }

  deinit {
    self.disposeBag = nil
  }
}
