
import UIKit
import HealthKit

final class ReadViewController: UITableViewController {

    static let cellIdentifier = "DataTypeTableViewCell"
    
    var healthStore: HKHealthStore?
    let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!

    var query: HKStatisticsCollectionQuery?
    var dataValues: [HKStatistics] = []

    let numberformatter: NumberFormatter = NumberFormatter()
    let dateFormatter: DateFormatter = DateFormatter()

    // MARK: UI

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "EE, yy년 MM월 dd일"
        dateFormatter.locale = Locale(identifier: "ko-kr")

        numberformatter.numberStyle = .decimal

        title = "Step Count"

        setUpNavigationController()
        setUpTableView()
    }

    func setUpNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = true

        // The Add Data bar button item.
        let rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self,
                                                 action: #selector(didTapRightBarButtonItem))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    @objc
    private func didTapRightBarButtonItem() {
        presentManualEntryViewController()
    }

    private func presentManualEntryViewController() {
        let title = "Step Count"
        let message = "오늘 걸음 수를 추가해보세요."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = title
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)

        let confirmAction = UIAlertAction(title: "Add", style: .default) { [weak self, weak alertController] _ in
            guard let alertController = alertController, let textField = alertController.textFields?.first else { return }

            if let string = textField.text, let doubleValue = Double(string) {
                self?.didAddNewData(with: doubleValue)
            }
        }

        alertController.addAction(confirmAction)

        present(alertController, animated: true)
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        isHealthDataAvaliable()
    }

    // MARK: HealthKtt

    // 기기 가능 여부
    func isHealthDataAvaliable() {
        
        if HKHealthStore.isHealthDataAvailable() {

            print("지원 함")

            healthStore = HealthDataManager.healthStore

            requestWalkAuthorization()

        } else {

            print("지원 안 함")
        }
    }

    // 권한 요청
    func requestWalkAuthorization() {

        // 읽기 쓰기 권한 요청
        healthStore?.requestAuthorization(toShare: [stepType], read: [stepType]) { success, error in

            if success {
                print("요청에 성공")
                self.calculateDailyStepCountForPastWeek()
            } else {
                print("요청에 실패")
            }
        }
    }

    // 지난 주 데이터 fetch
    func calculateDailyStepCountForPastWeek() {
        let calendar: Calendar = .current
        var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: Date())

        // Weekday는 일요일부터 1 - 7
        // 7은 일주일 2는 월요일
        let offset = (7 + (anchorComponents.weekday ?? 0) - 2) % 7
        anchorComponents.day! -= offset
        anchorComponents.hour = 3

        let anchorDate = calendar.date(from: anchorComponents)!
        let daily = DateComponents(day: 1)

        let exactlySevenDaysAgo = calendar.date(byAdding: DateComponents(day: -7), to: Date())!
        let oneWeekAgo = HKQuery.predicateForSamples(withStart: exactlySevenDaysAgo, end: nil, options: .strictStartDate)

        self.query = HKStatisticsCollectionQuery(quantityType: stepType,
                                                 quantitySamplePredicate: oneWeekAgo,
                                                 options: .cumulativeSum,
                                                 anchorDate: anchorDate,
                                                 intervalComponents: daily)

        // 쿼리 초기화 핸들러
        self.query?.initialResultsHandler = { query, statisticsCollection, error in
            if let statisticsCollection = statisticsCollection {
                print("초기화 성공")
                self.updateUIFromStatistics(statisticsCollection)
            }
        }

        // 쿼리 업데이트 핸들러
        self.query?.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
            if let statisticsCollection = statisticsCollection {
                print("update 성공")
                self.updateUIFromStatistics(statisticsCollection)
            }
        }

        self.healthStore?.execute(query!)
    }

    func updateUIFromStatistics(_ statisticsCollection: HKStatisticsCollection) {

        DispatchQueue.main.async {
            self.dataValues = []

            // fetch한 데이터에서 일주일 전 걸 가져온다.
            let startDate = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
            let endDate = Date()

            statisticsCollection.enumerateStatistics(from: startDate, to: endDate) { [weak self] statistics, stop in

                self?.dataValues.append(statistics)
                self?.dataValues.sort(by: { first, last in
                    first.startDate > last.startDate
                })
            }

            self.tableView.reloadData()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.healthStore?.stop(query!)
    }
}

extension ReadViewController {

    // MARK : TableView setting 관련

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataValues.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier) as? DataTypeTableViewCell
        else {
            return DataTypeTableViewCell()
        }

        let dataValue = dataValues[indexPath.row]

        let quantity = dataValue.sumQuantity()
        let value = quantity?.doubleValue(for: .count()) ?? 0
        let numberValue = NSNumber(value: value)
        let formattedValue = numberformatter.string(from: numberValue) ?? "0"

        var content = cell.defaultContentConfiguration()
        content.text = formattedValue + " steps"
        content.secondaryText = dateFormatter.string(from: dataValue.startDate)
        cell.contentConfiguration = content

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard !dataValues.isEmpty
        else {
            return nil
        }

        return "Step Count"
    }

    func setUpTableView() {
        tableView.register(DataTypeTableViewCell.self, forCellReuseIdentifier: Self.cellIdentifier)
    }

    // 추가
    func didAddNewData(with value: Double) {
        let sampleType: HKQuantityType = stepType
        let unit: HKUnit = .count()

        let quantity = HKQuantity(unit: unit, doubleValue: value)
        let quantitySample = HKQuantitySample(type: sampleType,
                                              quantity: quantity,
                                              start: .now,
                                              end: .now)

        healthStore?.save(quantitySample, withCompletion: { success, error in

            if success {
                print("저장 성공")
            } else {
                print("저장 실패")
            }
        })
    }
}
