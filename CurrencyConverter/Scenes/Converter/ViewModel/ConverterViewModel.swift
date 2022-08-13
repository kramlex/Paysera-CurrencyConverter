//
//  ConverterViewModel.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import RxSwift
import RxCocoa

typealias ExchangeModel = (from: CurrencyWallet, to: CurrencyWallet, fee: Double?)
typealias FeeModel = (from: Currency, fee: Double?)

typealias ConverterViewModelProtocol = ConverterViewModelInput & ConverterViewModelOutput

protocol ConverterViewModelInput {
  func onSubmitButtonTap()
  func getFromCurrencies() -> [Currency]
  func getToCurrencies() -> [Currency]
  func changeFromCurrency(_ currency: Currency)
  func changeToCurrency(_ currency: Currency)
}

protocol ConverterViewModelOutput {
  var fromAmountString: BehaviorSubject<String?> { get }
  var toAmountString: BehaviorSubject<String?> { get }
  var fromCurrencyString: Observable<String> { get }
  var toCurrencyString: Observable<String> { get }
  var wallets: Driver<[CurrencyWallet]> { get }
  var submitButtonEnabled: Observable<Bool> { get }
  var errorDriver: Driver<Error> { get }
  var exchangeDriver: Driver<ExchangeModel> { get }
  var isLoading: Observable<Bool> { get }
  var fee: Driver<FeeModel?> { get }
}

final class ConverterViewModel: ConverterViewModelProtocol {
  
  private var currencyStore: CurrencyStoreProtocol = CurrencyStore()
  
  private let errorSubject = PublishSubject<Error>()
  private let exchangeSubject = PublishSubject<ExchangeModel>()
  
  private let fromCurrency = BehaviorSubject<Currency>(value: Currency.allCases[0])
  private let toCurrency = BehaviorSubject<Currency>(value: Currency.allCases[1])
  private let lastEdit = BehaviorRelay<EditState>(value: .from)
  
  private let rateIsCalculated = BehaviorRelay<Bool>(value: false)
  private let fromAmountValue = BehaviorRelay<Double?>(value: nil)
  private let toAmountValue = BehaviorRelay<Double?>(value: nil)
  private let exchangeFee = BehaviorRelay<Double?>(value: nil)
  private let feeModel = BehaviorRelay<FeeModel?>(value: nil)
  
  private let disposeBag = DisposeBag()
  
  private var loadRateDisposable: Disposable?
  private var isSetupAfterLoad: Bool = false
  
  private let _isLoading = BehaviorRelay<Bool>(value: false)
  let isLoading: Observable<Bool>
  
  let fromAmountString = BehaviorSubject<String?>(value: "")
  let toAmountString = BehaviorSubject<String?>(value: "")
  
  let fromCurrencyString: Observable<String>
  let toCurrencyString: Observable<String>
  
  let _submitButtonEnabled = BehaviorRelay<Bool>(value: false)
  let submitButtonEnabled: Observable<Bool>
  
  let currentWallets = BehaviorRelay<[CurrencyWallet]>(value: [])
  
  var errorDriver: Driver<Error> {
    errorSubject.asDefaultDriver()
  }
  
  var exchangeDriver: Driver<ExchangeModel> {
    exchangeSubject.asDefaultDriver()
  }
  
  var wallets: Driver<[CurrencyWallet]> {
    currentWallets.asDriver()
  }
  
  var fee: Driver<FeeModel?> {
    feeModel.asDriver()
  }
  
  init() {
    fromCurrencyString = fromCurrency.map { $0.shortName }
    toCurrencyString = toCurrency.map { $0.shortName }
    isLoading = _isLoading.asObservable()
    submitButtonEnabled = _submitButtonEnabled.asObservable()
    
    setup()
  }
  
  func onSubmitButtonTap() {
    guard let fromAmountValue = fromAmountValue.value, let toAmountValue = toAmountValue.value, let fromCurrency = try? fromCurrency.value(), let toCurrency = try? toCurrency.value() else { return }
    let paidAmount = fromAmountValue + (exchangeFee.value ?? .zero)
    let currentWallets = UserDefaultsService.wallet
    let newWallets = currentWallets.map { wallet -> CurrencyWallet in
      if wallet.currency.id == fromCurrency.id {
        return wallet.withAmount(wallet.amount - paidAmount)
      } else if wallet.currency.id == toCurrency.id {
        return wallet.withAmount(wallet.amount + toAmountValue)
      } else {
        return wallet
      }
    }
    let exchangeModel: ExchangeModel = (
      from: CurrencyWallet(currency: fromCurrency, amount: fromAmountValue),
      to: CurrencyWallet(currency: toCurrency, amount: toAmountValue),
      fee: exchangeFee.value
    )
    exchangeSubject.onNext(exchangeModel)
    UserDefaultsService.wallet = newWallets
    UserDefaultsService.operationsCount = UserDefaultsService.operationsCount + 1
    self.fromAmountString.onNext(try? self.fromAmountString.value())
  }
  
  func getFromCurrencies() -> [Currency] {
    guard let toCurrency = try? toCurrency.value() else {
      return Currency.allCases
    }
    return Currency.allCases.filter { currency in
      currency.id != toCurrency.id
    }
  }
  
  func getToCurrencies() -> [Currency] {
    guard let fromCurrency = try? fromCurrency.value() else {
      return Currency.allCases
    }
    return Currency.allCases.filter { currency in
      currency.id != fromCurrency.id
    }
  }
  
  func changeFromCurrency(_ currency: Currency) {
    fromCurrency.onNext(currency)
  }
  
  func changeToCurrency(_ currency: Currency) {
    toCurrency.onNext(currency)
  }
  
  private func setup() {
    fromAmountString.bind { [weak self] string in
      guard let self = self else {
        return
      }
      self.rateIsCalculated.accept(false)
      let doubleValue = Double(string ?? "")
      self.fromAmountValue.accept(Double(string ?? "") )
      guard let _ = doubleValue, !self.isSetupAfterLoad else {
        self.isSetupAfterLoad = false
        return
      }
      self.lastEdit.accept(.from)
    }.disposed(by: disposeBag)
    
    toAmountString.bind { [weak self] string in
      guard let self = self else {
        return
      }
      self.rateIsCalculated.accept(false)
      let doubleValue = Double(string ?? "")
      self.toAmountValue.accept(Double(string ?? "") )
      guard let _ = doubleValue, !self.isSetupAfterLoad else {
        self.isSetupAfterLoad = false
        return
      }
      self.lastEdit.accept(.to)
    }.disposed(by: disposeBag)
    
    toCurrency.bind { [weak self] _ in
      self?.lastEdit.accept(.to)
    }.disposed(by: disposeBag)
    
    fromCurrency.bind { [weak self] _ in
      self?.lastEdit.accept(.from)
    }.disposed(by: disposeBag)
    
    lastEdit.debounce(ConstantHelper.editStateDebounceTime, scheduler: MainScheduler.instance).bind { [weak self] editState in
      self?.getExchangeRate(state: editState)
    }.disposed(by: disposeBag)
    
    UserDefaultsService.walletObservable.bind { [weak self] wallets in
      self?.currentWallets.accept(wallets)
    }.disposed(by: disposeBag)
    
    rateIsCalculated.bind { [weak self] rateIsCalculated in
      guard rateIsCalculated, let fromAmount = self?.fromAmountValue.value, let fromCurrency = try? self?.fromCurrency.value() else {
        return
      }
      let operationCount: Int = UserDefaultsService.operationsCount
      var fee: Double?
      if operationCount + 1 > ConstantHelper.freeExchangeCount {
        fee = fromAmount * ConstantHelper.feeMultiplier
      } else {
        fee = nil
      }
      self?.exchangeFee.accept(fee)
      self?.feeModel.accept((from: fromCurrency, fee: fee))
    }.disposed(by: disposeBag)
    
    rateIsCalculated.bind{ [weak self] rateIsCalculated in
      guard rateIsCalculated, let fromAmountValue = self?.fromAmountValue.value, let fromCurrency = try? self?.fromCurrency.value(), let fromCurrencyWallet = self?.currentWallets.value.first(where: { wallet in
        wallet.currency.id == fromCurrency.id
      }) else {
        self?._submitButtonEnabled.accept(false)
        return
      }
      let paidAmount = fromAmountValue + (self?.exchangeFee.value ?? .zero)
      self?._submitButtonEnabled.accept(fromCurrencyWallet.amount >= paidAmount)
    }.disposed(by: disposeBag)
    
    setupAfterLaunch()
    fromAmountString.onNext(ConstantHelper.startedStringValue)
  }
  
  private func getExchangeRate(state: EditState) {
    switch state {
    case .from:
      guard let fromAmout = fromAmountValue.value, let fromCurrency = try? fromCurrency.value(), let toCurrency = try? toCurrency.value() else {
        return
      }
      exchangeRateRequest(fromAmount: fromAmout, fromCurrency: fromCurrency, toCurrency: toCurrency) { [weak self] response in
        self?.toAmountString.onNext(String(response.amount))
      }
    case .to:
      guard let fromAmout = toAmountValue.value, let fromCurrency = try? self.toCurrency.value(), let toCurrency = try? self.fromCurrency.value() else {
        return
      }
      exchangeRateRequest(fromAmount: fromAmout, fromCurrency: fromCurrency, toCurrency: toCurrency) { [weak self] response in
        self?.fromAmountString.onNext(response.amount)
      }
    }
  }
  
  private func exchangeRateRequest(fromAmount: Double, fromCurrency: Currency, toCurrency: Currency, completion: @escaping (CurrencyExchangeResponse) -> Void) {
    loadRateDisposable?.dispose()
    loadRateDisposable = nil
    _isLoading.accept(true)
    loadRateDisposable = currencyStore.getExchangeRate(fromAmount: fromAmount, fromCurrency: fromCurrency, toCurrency: toCurrency).subscribe { [weak self] response in
      self?.isSetupAfterLoad = true
      completion(response)
      self?.rateIsCalculated.accept(true)
      self?._isLoading.accept(false)
    } onError: { [weak self] error in
      self?._isLoading.accept(false)
      self?.errorSubject.onNext(error)
    }
  }
  
  private func setupAfterLaunch() {
    UserDefaultsService.setupAfterLaunch()
  }
  
  enum EditState {
    case from
    case to
  }
}

private typealias ConstantHelper = ConverterViewModel
private extension ConstantHelper {
  
  static let startedStringValue: String = "1.00"
  
  static let editStateDebounceTime: RxTimeInterval = .seconds(1)
  static let feeMultiplier: Double = 0.007 // 0.7%
  static let freeExchangeCount: Int = 5
}
