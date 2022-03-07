//
//  WeeklyReportViewController.swift
//  HealthKitWWDC
//
//  Created by Kanghos on 2022/03/07.
//

import UIKit
import HealthKit

final class WeeklyReportViewController: ChartViewController {

    var content: [String] = [
        HKQuantityTypeIdentifier.stepCount.rawValue,
        HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue
    ]

    var queries: [HKAnchoredObjectQuery] = []

    // MARK: View LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        data = content.map { ($0, []) }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !queries.isEmpty { return }

        HealthData.requestHealthDataAccesssIfNeeded(dataTypes: content) { success in
            if success {
                self.setUpBackgroundObservers()
                self.loadData()
            }
        }
    }

    // MARK: Data Function

    func loadData() {
        performQuery {
            DispatchQueue.main.async { [weak self] in
                self?.reloadData()
            }
        }
    }

    func setUpBackgroundObservers() {

        if let sampleType = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            createAnchoredObjectQuery(for: sampleType)
        }
    }

    func createAnchoredObjectQuery(for sampleType: HKSampleType) {
        let predicate = createLastWeekPredicate()
        let limit = HKObjectQueryNoLimit

        var anchor: HKQueryAnchor?

        if let anchorData = UserManager.anchor {
            anchor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: anchorData)
        } else {
            anchor = nil
        }
        let handler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = { query, sampleOrNil, deletedOjectsOrNil, newAnchor, errorOrNil in

            if let error = errorOrNil {
                print(error.localizedDescription)

                return
            }

            print("query initialized")
            HealthData.updateAnchor(newAnchor, from: query)
        }

        let query = HKAnchoredObjectQuery(type: sampleType, predicate: predicate, anchor: anchor, limit: limit, resultsHandler: handler)


        query.updateHandler = handler

        HealthData.healthStore.execute(query)
        queries.append(query)
    }

    func performQuery(completion: @escaping () -> Void) {

        for (index, item) in data.enumerated() {
            let now = Date()
            let startDate = getLastWeekStartDate()
            let endDate = now

            let predicate = createLastWeekPredicate()
            let dateInterval = DateComponents(day: 1)

            let statisticsOptions = getStatisticsOptions(for: item.dataTypeIdentifier)
            let initialResultsHandler: (HKStatisticsCollection) -> Void = { statisticsCollection in
                var values: [Double] = []
                statisticsCollection.enumerateStatistics(from: startDate, to: endDate) { (statistics, stop) in
                    let statisticsQuantity = getStatisticsQuantity(for: statistics, with: statisticsOptions)
                    if let unit = preferredUnit(for: item.dataTypeIdentifier),
                       let value = statisticsQuantity?.doubleValue(for: unit) {
                        values.append(value)
                    }
                }

                self.data[index].values = values

                completion()
            }
            // Fetch statistics.
            HealthData.fetchStatistics(with: HKQuantityTypeIdentifier(rawValue: item.dataTypeIdentifier),
                                       predicate: predicate,
                                       options: statisticsOptions,
                                       startDate: startDate,
                                       interval: dateInterval,
                                       completion: initialResultsHandler)

        }
    }
}
