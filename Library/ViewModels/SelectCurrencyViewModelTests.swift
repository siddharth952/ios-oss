import Foundation
import XCTest
@testable import KsApi
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
import KsApi
import ReactiveSwift
import Result
@testable import Library
import Prelude

internal final class SelectCurrencyViewModelTests: TestCase {
  private let vm: SelectCurrencyViewModelType = SelectCurrencyViewModel()

  private let activityIndicatorShouldShow = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.activityIndicatorShouldShow.observe(self.activityIndicatorShouldShow.observer)
  }

  func testActivityIndicator_Success() {
    self.vm.inputs.configure(with: .USD)
    self.vm.inputs.viewDidLoad()

    self.activityIndicatorShouldShow.assertValues([])

    withEnvironment(apiService: MockService(changeCurrencyResponse: .init())) {
      self.vm.inputs.didSelect(.AUD)
      self.vm.inputs.saveButtonTapped()

      self.activityIndicatorShouldShow.assertValues([true])

      self.scheduler.advance()

      self.activityIndicatorShouldShow.assertValues([true, false])
    }
  }

  func testActivityIndicator_Failure() {
    self.vm.inputs.configure(with: .USD)
    self.vm.inputs.viewDidLoad()

    self.activityIndicatorShouldShow.assertValues([])

    withEnvironment(apiService: MockService(changeCurrencyError: .invalidInput)) {
      self.vm.inputs.didSelect(.AUD)
      self.vm.inputs.saveButtonTapped()

      self.activityIndicatorShouldShow.assertValues([true])

      self.scheduler.advance()

      self.activityIndicatorShouldShow.assertValues([true, false])
    }
  }

//  func testTrackSelectedChosenCurrency() {
//    self.vm.inputs.showChangeCurrencyAlert(for: Currency.CHF)
//    self.vm.inputs.didConfirmChangeCurrency()
//
//    self.scheduler.advance()
//
//    XCTAssertEqual(["Selected Chosen Currency"], self.trackingClient.events)
//    XCTAssertEqual(["Fr Swiss Franc (CHF)"], self.trackingClient.properties(forKey: "currency",
//                                                                            as: String.self))
//  }
}
