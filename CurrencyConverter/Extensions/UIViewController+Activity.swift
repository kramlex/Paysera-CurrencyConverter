//
//  UIViewController+Loading.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import UIKit
import MBProgressHUD

extension UIViewController {
  func showError(_ error: Error) {
    presentAlert(
      withTitle: "Error",
      message: error.localizedDescription
    )
  }
  
  func showProgress() {
    MBProgressHUD.showAdded(to: self.view, animated: true)
  }

  func hideProgress() {
    MBProgressHUD.hide(for: self.view, animated: false)
  }
}
