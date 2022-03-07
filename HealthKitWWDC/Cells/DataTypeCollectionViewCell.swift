import UIKit
import CareKit
import SnapKit
import HealthKit

final class DataTypeCollectionViewCell: UICollectionViewCell {

    var dataTypeIdentifier: String!
    var statisticalValues: [Double] = []

    var chartView = OCKCartesianChartView(type: .bar)

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        contentView.addSubview(chartView)

        setUpConstraints()
    }

    private func setUpConstraints() {
        chartView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.trailing.bottom.equalToSuperview().priority(-1)
        }
    }

    func updateChartView(with dataTypeIdentifier: String, values: [Double]) {
        self.dataTypeIdentifier = dataTypeIdentifier
        self.statisticalValues = values

        // Update HeaderView
        chartView.headerView.titleLabel.text = "Step Count"
        chartView.headerView.detailLabel.text = "detail"

        // Update graphView
        chartView.applyDefaultConfiguration()
        chartView.graphView.horizontalAxisMarkers = createHorizenAxis()

        // Update graphView dataSeries
        let dataPoints: [CGFloat] = statisticalValues.map { CGFloat($0) }
        let unitTitle = " steps"

        chartView.graphView.dataSeries = [
            OCKDataSeries(values: dataPoints, title: unitTitle)
        ]
    }

    func createHorizenAxis(lastDate: Date = Date(), useWeekday: Bool = true) -> [String] {
        let calendar: Calendar = .current
        let weekdayTitles = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

        var titles: [String] = []

        titles = weekdayTitles

        let weekday = calendar.component(.weekday, from: lastDate)

        return Array(titles[weekday..<titles.count]) + Array(titles[0..<weekday])
    }
}
