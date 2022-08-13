//
//  ConverterViewController.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import UIKit
import RxSwift
import RxCocoa
import ActionSheetPicker_3_0

final class ConverterViewController: RxUIViewController {
  
  // MARK: - IBOutet's
  @IBOutlet private weak var submitButton: GradientButton!
  @IBOutlet private weak var fromTextField: UITextField!
  @IBOutlet private weak var toTextField: UITextField!
  @IBOutlet private weak var walletCollectionView: UICollectionView!
  @IBOutlet private weak var feeLabel: UILabel!
  @IBOutlet private weak var fromCurrencyLabel: UILabel!
  @IBOutlet private weak var toCurrencyLabel: UILabel!
  @IBOutlet private weak var changeToCurrencyButton: UIButton!
  @IBOutlet private weak var changeFromCurrencyButton: UIButton!
  
  // MARK: - ViewModel
  private var viewModel: ConverterViewModelProtocol!
  
  // MARK: - Create
  static func create(viewModel: ConverterViewModelProtocol) -> ConverterViewController {
    let controller = ConverterViewController()
    controller.viewModel = viewModel
    return controller
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollection()
    setupNavbar()
    setupButtons()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    bindViewModel()
  }
  
  // MARK: - Binding
  func bindViewModel() {
    (fromTextField.rx.text <-> viewModel.fromAmountString).disposed(by: disposeBag)
    (toTextField.rx.text <-> viewModel.toAmountString).disposed(by: disposeBag)
    
    viewModel.wallets.asObservable().bind(to: walletCollectionView.rx.items(cellIdentifier: WalletCollectionViewCell.reusableIdentifier)) { _, wallet, cell in
      guard let cell = cell as? WalletCollectionViewCell else { return }
      cell.configure(wallet: wallet)
    }.disposed(by: disposeBag)
    
    
    changeToCurrencyButton.rx.tap.bind { [weak self] _ in
      self?.showDialog(state: .to)
    }.disposed(by: disposeBag)

    changeFromCurrencyButton.rx.tap.bind { [weak self] _ in
      self?.showDialog(state: .from)
    }.disposed(by: disposeBag)
    
    submitButton.rx.tap.bind { [weak self] _ in
      self?.viewModel.onSubmitButtonTap()
    }.disposed(by: disposeBag)
    
    viewModel.isLoading.bind { [weak self] isLoading in
      if isLoading {
        self?.showProgress()
      } else {
        self?.hideProgress()
      }
    }.disposed(by: disposeBag)
    
    viewModel.errorDriver.drive { [weak self] error in
      self?.showError(error)
    }.disposed(by: disposeBag)
    
    
    viewModel.fromCurrencyString
      .bind(to: fromCurrencyLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.toCurrencyString
      .bind(to: toCurrencyLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.submitButtonEnabled
      .bind(to: submitButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    viewModel.exchangeDriver.drive { [weak self] (from: CurrencyWallet, to: CurrencyWallet, fee: Double?) in
      let actions = [UIAlertAction(title: ConstantHelper.exchangeAlertButtonText, style: .default)]
      self?.presentAlert(withTitle: ConstantHelper.exchangeTitle, message: ConstantHelper.exchangeMessage(from: from, to: to, fee: fee), actions: actions)
    }.disposed(by: disposeBag)
    
    viewModel.fee.drive { [weak self] feeModel in
      guard let feeModel = feeModel else {
        self?.feeLabel.isHidden = true
        return
      }
      self?.feeLabel.isHidden = false
      self?.feeLabel.text = ConstantHelper.commisionFeeLabelText(from: feeModel.from, fee: feeModel.fee)
    }.disposed(by: disposeBag)
  }
  
  private func setupCollection() {
    walletCollectionView.register(UINib(nibName: WalletCollectionViewCell.xibName, bundle: nil), forCellWithReuseIdentifier: WalletCollectionViewCell.reusableIdentifier)
    (walletCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    walletCollectionView.contentInset = ConstantHelper.collectionEdgeInsets
  }
  
  private func setupButtons() {
    changeToCurrencyButton.setBackgroundImage(R.image.downChevron()!, for: .normal)
    changeFromCurrencyButton.setBackgroundImage(R.image.downChevron()!, for: .normal)
  }
  
  private func setupNavbar() {
    title = ConstantHelper.title
    navigationController?.navigationBar.customizeNavbar(backgroundColor: R.color.mainBlue(), titleColor: .white, customFont: UIFont.systemFont(ofSize: 16, weight: .regular))
  }
  
  private func showDialog(state: ChangeState) {
    let elements = state == .from ? viewModel.getFromCurrencies() : viewModel.getToCurrencies()
    ActionSheetStringPicker.show(
      withTitle: ConstantHelper.dialogTitle,
      rows: elements.map {$0.shortName} ,
      initialSelection: .zero,
      doneBlock: { [weak self] (_ , index, object) in
        guard object != nil, let currency = elements[safe: index] else { return }
        switch state {
        case .from:
          self?.viewModel?.changeFromCurrency(currency)
        case .to:
          self?.viewModel?.changeToCurrency(currency)
        }
      },
      cancel: nil,
      origin: view)
  }
  
  private enum ChangeState {
    case from
    case to
  }
}

private typealias ConstantHelper = ConverterViewController
private extension ConstantHelper {
  
  static let horizontalCollectionInset: CGFloat = 16.0
  
  static var collectionEdgeInsets: UIEdgeInsets {
    .init(top: .zero, left: ConstantHelper.horizontalCollectionInset, bottom: .zero, right: ConstantHelper.horizontalCollectionInset)
  }
  
  static let title = "Currency converter"
  
  static let exchangeTitle = "Currency converted"
  static func exchangeMessage(from: CurrencyWallet, to: CurrencyWallet, fee: Double?) -> String {
    let fromString = String(format: "%.2f", from.amount)
    let fromCurrencyString = from.currency.shortName
    let toString = String(format: "%.2f", to.amount)
    let toCurrencyString = to.currency.shortName
    return "You have converted \(fromString) \(fromCurrencyString) to \(toString) to \(toCurrencyString). " + commisionFeeLabelText(from: from.currency, fee: fee)
  }
  static let exchangeAlertButtonText: String = "Done"
  
  static func commisionFeeLabelText(from: Currency, fee: Double?) -> String {
    var feeString: String
    if let fee = fee {
      feeString = "\(String(format: "%.2f", fee)) \(from.shortName)"
    } else {
      feeString = "Free"
    }
    return "Commision Fee: \(feeString)"
  }
  
  static let dialogTitle = "Select currency"
}
