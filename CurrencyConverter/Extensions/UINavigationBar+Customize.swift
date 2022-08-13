//
//  UINavigationBar+Setup.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import UIKit

extension UINavigationBar {
  func customizeNavbar(backgroundColor: UIColor? = nil, titleColor: UIColor? = nil, customFont: UIFont? = nil) {
    
    // setup title font color
    var titleAttribute: [NSAttributedString.Key: Any] = [:]
    if let customFont = customFont {
      titleAttribute[NSAttributedString.Key.font] = customFont
    }
    if let titleColor = titleColor {
      titleAttribute[NSAttributedString.Key.foregroundColor] = titleColor
    }
    
    if #available(iOS 15, *) {
      let appearance = UINavigationBarAppearance()
      if let backgroundColor = backgroundColor {
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
      }
      appearance.titleTextAttributes = titleAttribute
      self.standardAppearance = appearance
      self.scrollEdgeAppearance = appearance
    } else {
      if let titleColor = titleColor {
        self.barTintColor = titleColor
      }
      if let backgroundColor = backgroundColor {
        self.backgroundColor = backgroundColor
      }
      self.titleTextAttributes = titleAttribute
    }
  }
}
