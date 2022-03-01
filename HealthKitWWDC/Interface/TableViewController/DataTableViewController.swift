
import UIKit
import HealthKit

protocol HealthQueryDataSource: AnyObject {
    func performQuery(completion: @escaping () -> Void)
}

class DataTableViewController: UITableViewController {

    static let cellIdentifier = "DataTypeTableViewCell"

    var dataTypeIdentifier: String = ""
    var dataValues: [HealthDataTypeValue] = []

    let dateFormatter = DateFormatter()
    public var showGroupedTableViewTitle: Bool =  false
    
    private var emptyDataView: EmptyDataBackgroundView {
        return EmptyDataBackgroundView(message: "No Data")
    }

    // MARK: Initialize

    init() {
        super.init(style: .insetGrouped)
        dataTypeIdentifier = HKQuantityTypeIdentifier.stepCount.rawValue
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lift Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationController()
        setUpViewController()
        setUpTableView()
    }

    func setUpNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func setUpViewController() {
        title = "StepCount"
        dateFormatter.dateStyle = .medium
    }

    func setUpTableView() {
        tableView.register(DataTypeTableViewCell.self, forCellReuseIdentifier: Self.cellIdentifier)
    }

    // MARK: - Data Life Cycle

    func reloadData() {
        self.dataValues.isEmpty ? self.setEmptyDataView() : self.removeEmptyDataView()
        self.dataValues.sort { $0.startDate > $1.startDate }
        self.tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
    }

    private func setEmptyDataView() {
        tableView.backgroundView = emptyDataView
    }

    private func removeEmptyDataView() {
        tableView.backgroundView = nil
    }

    // MARK: - UITableViewDataSource
}

extension DataTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataValues.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier) as? DataTypeTableViewCell
        else {
            return DataTypeTableViewCell()
        }

        let dataValue = dataValues[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = formattedValue(dataValue.value, typeIdentifier: dataTypeIdentifier)
        content.secondaryText = dateFormatter.string(from: dataValue.startDate)
        cell.contentConfiguration = content

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let dataTypeTitle = getDataTypeName(for: dataTypeIdentifier),
              showGroupedTableViewTitle, !dataValues.isEmpty
        else {
            return nil
        }

        return String(format: "%@ %@", dataTypeTitle, "Samples")
    }
}
