import Library
import UIKit

final class SelectCurrencyViewController: UITableViewController {
  private let viewModel: SelectCurrencyViewModelType = SelectCurrencyViewModel()

  internal static func instantiate() -> SelectCurrencyViewController {
    return SelectCurrencyViewController(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
  }
}

extension SelectCurrencyViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Currency.allCases.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

    let currency = Currency.allCases[indexPath.row]

    cell.textLabel?.text = currency.descriptionText
    cell.accessoryType = self.viewModel.outputs.isSelectedCurrency(currency) ? .checkmark : .none

    return cell
  }
}
