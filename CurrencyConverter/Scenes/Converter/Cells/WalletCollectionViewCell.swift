//
//  WalletCollectionViewCell.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import UIKit

class WalletCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet private weak var walletLabel: UILabel!
  
  func configure(wallet: CurrencyWallet) {
    walletLabel.text = "\(wallet.currency.shortName) \(String(format: "%.2f", wallet.amount))"
  }
  
  static var reusableIdentifier: String {
    String(describing: Self.self)
  }
  
  static var xibName: String {
    String(describing: Self.self)
  }
}
