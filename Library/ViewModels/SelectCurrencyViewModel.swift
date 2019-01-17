import Foundation
import ReactiveSwift
import Result

public protocol SelectCurrencyViewModelInputs {
  func configure(with selectedCurrency: Currency?)
  func viewDidLoad()
}

public protocol SelectCurrencyViewModelOutputs {
  func isSelectedCurrency(_ currency: Currency) -> Bool
}

public protocol SelectCurrencyViewModelType {
  var inputs: SelectCurrencyViewModelInputs { get }
  var outputs: SelectCurrencyViewModelOutputs { get }
}

final public class SelectCurrencyViewModel: SelectCurrencyViewModelType, SelectCurrencyViewModelInputs,
SelectCurrencyViewModelOutputs {

  public init() {
//    let currencies = self.viewDidLoadSignal.switchMap {
//
//    }
  }

  private let (selectedCurrencySignal, selectedCurrencyObserver) = Signal<Currency?, NoError>.pipe()
  public func configure(with selectedCurrency: Currency?) {
    self.selectedCurrencyObserver.send(value: selectedCurrency)
  }

  private let (viewDidLoadSignal, viewDidLoadObserver) = Signal<(), NoError>.pipe()
  public func viewDidLoad() {
    self.viewDidLoadObserver.send(value: ())
  }

  public func isSelectedCurrency(_ currency: Currency) -> Bool {
    return true
  }

  public var inputs: SelectCurrencyViewModelInputs { return self }
  public var outputs: SelectCurrencyViewModelOutputs { return self }
}
