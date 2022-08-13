//
//  GradientButton.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import UIKit

final class GradientButton: UIButton {
  
//  @IBInspectable var labelText: String = ""
  @IBInspectable var startPointX: CGFloat = .zero
  @IBInspectable var startPointY: CGFloat = .zero
  @IBInspectable var endPointX: CGFloat = 1.0
  @IBInspectable var endPointY: CGFloat = .zero
  
  @IBInspectable var gradientColorFirst: UIColor? = nil
  @IBInspectable var gradientColorSecond: UIColor? = nil
  @IBInspectable var gradientColorThird: UIColor? = nil
  @IBInspectable var gradientColorFourth: UIColor? = nil
  
  @IBInspectable var gradientDisabledColorFirst: UIColor? = nil
  @IBInspectable var gradientDisabledColorSecond: UIColor? = nil
  @IBInspectable var gradientDisabledColorThird: UIColor? = nil
  @IBInspectable var gradientDisabledColorFourth: UIColor? = nil
  
  @IBInspectable var shadowColor: UIColor = .darkGray
  @IBInspectable var shadowOffsetWidth: CGFloat = 2.5
  @IBInspectable var shadowOffsetHeight: CGFloat = 2.5
  @IBInspectable var shadowRadius: CGFloat = 5.0
  @IBInspectable var shadowOpacity: Float = 0.3
  
  @IBInspectable var textColor: UIColor = .white
  @IBInspectable var fontSize: CGFloat = 17.0
  
  private weak var gradientLayer: CAGradientLayer?
  
  
  private var colors: [CGColor] {
    [gradientColorFirst,
     gradientColorSecond,
     gradientColorThird,
     gradientColorFourth].compactMap { $0?.cgColor }
  }
  
  private var disabledColors: [CGColor] {
    [gradientDisabledColorFirst,
     gradientDisabledColorSecond,
     gradientDisabledColorThird,
     gradientDisabledColorFourth].compactMap { $0?.cgColor }
  }
  
  private var gradientStartPoint: CGPoint {
    .init(x: startPointX, y: startPointY)
  }
  
  private var gradientEndPoint: CGPoint {
    .init(x: endPointX, y: endPointY)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  private func setup() {
    self.backgroundColor = nil
    self.contentVerticalAlignment = .center
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    setupLayer()
    setupView()
  }
  
  private func setupView() {
    setTitleColor(textColor, for: .normal)
    titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
    titleLabel?.textColor = textColor
//    setTitle(labelText, for: .normal)
  }
  
  private func setupLayer() {
    self.gradientLayer?.removeFromSuperlayer()
    self.gradientLayer = nil
    
    let gradientLayer = CAGradientLayer()
    if isEnabled {
      gradientLayer.colors = colors
    } else {
      gradientLayer.colors = disabledColors
    }
    gradientLayer.startPoint = gradientStartPoint
    gradientLayer.endPoint = gradientEndPoint
    gradientLayer.frame = self.bounds
    gradientLayer.cornerRadius = self.frame.height / 2
    
    gradientLayer.shadowColor = UIColor.darkGray.cgColor
    gradientLayer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)
    gradientLayer.shadowRadius = shadowRadius
    gradientLayer.shadowOpacity = shadowOpacity
    gradientLayer.masksToBounds = false
    
    layer.insertSublayer(gradientLayer, at: 0)
    self.gradientLayer = gradientLayer
  }
}
