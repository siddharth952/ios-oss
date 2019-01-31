import Library
import Prelude
import Prelude_UIKit
import UIKit

final class SelectCurrencyViewController: UIViewController, MessageBannerViewControllerPresenting {
  private let viewModel: SelectCurrencyViewModelType = SelectCurrencyViewModel()

  internal var messageBannerViewController: MessageBannerViewController?
  private var saveButtonView: LoadingBarButtonItemView!

  internal static func instantiate() -> SelectCurrencyViewController {
    return SelectCurrencyViewController(nibName: nil, bundle: nil)
  }

  public func configure(with currency: Currency) {
    self.viewModel.inputs.configure(with: currency)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.addSubview(self.tableView)
    self.tableView.constrainEdges(to: self.view)
    self.tableView.setConstrained(headerView: self.headerView)

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.saveButtonView = LoadingBarButtonItemView.instantiate()
    self.saveButtonView.setTitle(title: Strings.Save())
    self.saveButtonView.addTarget(self, action: #selector(saveButtonTapped(_:)))

    let navigationBarButton = UIBarButtonItem(customView: self.saveButtonView)
    self.navigationItem.setRightBarButton(navigationBarButton, animated: false)

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.headerLabel
      |> UILabel.lens.text %~ { _ in
        """
        \(Strings.This_allows_you_to_see_project_goal_and_pledge_amounts_in_your_preferred_currency())\n
        \(Strings.A_successfully_funded_project_will_collect_your_pledge_in_its_native_currency())
        """
    }

    self.tableView.setConstrained(headerView: self.headerView)
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.activityIndicatorShouldShow
      .observeForUI()
      .observeValues { shouldShow in
        if shouldShow {
          self.saveButtonView.startAnimating()
        } else {
          self.saveButtonView.stopAnimating()
        }
    }

    self.viewModel.outputs.saveButtonIsEnabled
      .observeForUI()
      .observeValues { [weak self] (isEnabled) in
        self?.saveButtonView.setIsEnabled(isEnabled: isEnabled)
    }

    self.viewModel.outputs.updateCurrencyDidFailWithError
      .observeForUI()
      .observeValues { error in
        self.messageBannerViewController?.showBanner(
          with: .error,
          message: error
        )
    }
  }

  // MARK: Actions

  @objc private func saveButtonTapped(_ sender: Any) {
    self.viewModel.inputs.saveButtonTapped()
  }

  // MARK: Subviews

  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)

    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.tableFooterView = UIView(frame: .zero)
    tableView.dataSource = self
    tableView.delegate = self

    return tableView
  }()

  private lazy var headerView: UIView = {
    let view = UIView(frame: .zero)

    let stackView = UIStackView(arrangedSubviews: [
      self.headerImageView,
      self.headerLabel
    ])

    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.spacing = Styles.grid(1)
    stackView.layoutMargins = .init(all: Styles.grid(2))
    stackView.isLayoutMarginsRelativeArrangement = true

    view.addSubview(stackView)
    stackView.constrainEdges(to: view)

    return view
  }()

  private lazy var headerImageView: UIImageView = {
    let imageView = UIImageView(image: image(named: "icon--currency-header"))
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()

  private lazy var headerLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.numberOfLines = 0
    return label
  }()
}

extension SelectCurrencyViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Currency.allCases.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

    let currency = Currency.allCases[indexPath.row]

    cell.textLabel?.text = currency.descriptionText
    cell.accessoryType = self.viewModel.outputs.isSelectedCurrency(currency) ? .checkmark : .none

    return cell
  }
}

extension SelectCurrencyViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let currency = Currency.allCases[indexPath.row]

    self.viewModel.inputs.didSelect(currency)

    tableView.deselectRow(at: indexPath, animated: true)
    tableView.visibleCells.forEach { $0.accessoryType = .none }
    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
  }
}

extension UIView {
  func constrainEdges(to view: UIView) {
    self.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      self.topAnchor.constraint(equalTo: view.topAnchor),
      self.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
}

extension UITableView {
  func setConstrained(headerView: UIView) {
    headerView.translatesAutoresizingMaskIntoConstraints = false

    headerView.layoutIfNeeded()
    self.tableHeaderView = headerView

    NSLayoutConstraint.activate([
      headerView.widthAnchor.constraint(equalTo: self.widthAnchor)
      ])
  }
}
