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

    _ = self.tableView
      |> settingsTableViewStyle
      |> \.separatorStyle .~ .singleLine

    _ = self.headerImageView
      |> \.contentMode .~ .scaleAspectFill

    _ = self.headerStackView
      |> \.axis .~ .vertical
      |> \.alignment .~ .center
      |> \.spacing .~ Styles.grid(2)
      |> \.layoutMargins .~ .init(
        top: Styles.grid(4), left: Styles.grid(2), bottom: Styles.grid(2), right: Styles.grid(2)
      )
      |> \.isLayoutMarginsRelativeArrangement .~ true

    _ = self.headerLabel
      |> settingsDescriptionLabelStyle
      |> \.textColor .~ .ksr_text_dark_grey_500
      |> \.text %~ { _ in
        """
        \(Strings.Making_this_change())\n
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

    view.addSubview(self.headerStackView)
    self.headerStackView.constrainEdges(to: view)

    return view
  }()

  private lazy var headerStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [
      self.headerImageView,
      self.headerLabel
    ])

    return stackView
  }()

  private lazy var headerImageView: UIImageView = {
    let imageView = UIImageView(image: image(named: "icon--currency-header"))
    return imageView
  }()

  private lazy var headerLabel: UILabel = {
    let label = UILabel(frame: .zero)
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
