//
//  UIViewController+Alert.swift
//  CurrencyConverter
//
//  Created by mdubkov on 13.08.2022.
//

import UIKit

extension UIViewController {

  func presentAlert(withTitle title: String, message : String) {
    let OKAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    presentAlert(withTitle: title, message: message, actions: [OKAction])
  }
  
  func presentAlert(withTitle title: String, message: String, actions: [UIAlertAction]) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    actions.forEach { alertController.addAction($0) }
    self.present(alertController, animated: true, completion: nil)
  }
}
