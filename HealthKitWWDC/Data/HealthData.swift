//
//  HealthData.swift
//  HealthKitWWDC
//
//  Created by Kanghos on 2022/02/28.
//

import Foundation
import HealthKit

final class HealthData {

    static let healthStore: HKHealthStore = HKHealthStore()

    private static var allHealthDataTypes: [HKSampleType] {
        let typeIdentifies: [String] = [
            HKQuantityTypeIdentifier.stepCount.rawValue
        ]

        return typeIdentifies.compactMap { getSampleType(for: $0) }
    }

    class func requestHealthDataAccesssIfNeeded(dataTypes: [String]? = nil, completion: @escaping (_ success: Bool) -> Void) {
        var readDataTypes = Set(allHealthDataTypes)
        var shareDataTypes = Set(allHealthDataTypes)

        if let dataTypeIdentifiers = dataTypes {
            readDataTypes = Set(dataTypeIdentifiers.compactMap { getSampleType(for: $0) })
            shareDataTypes = readDataTypes
        }

        requestHealthDataAccessIfNeeded(toShare: shareDataTypes, read: readDataTypes, completion: completion)
    }

    class func requestHealthDataAccessIfNeeded(toShare shareTypes: Set<HKSampleType>?,
                                               read readTypes: Set<HKObjectType>,
                                               completion: @escaping (_ success: Bool) -> Void) {
        if !HKHealthStore.isHealthDataAvailable() {
            fatalError("Health data is not available!")
        }

        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { success, error in
            if let error = error {
                print("requestAuthorizaion error:", error.localizedDescription)
            }

            if success {
                print("HealthKit authorization request was successful")
            } else {
                print("HealthKit authorization requeest")
            }

            completion(success)
        }
    }

    // MARK: - Helper Functions

    class func updateAnchor(_ newAnchor: HKQueryAnchor?, from query: HKAnchoredObjectQuery) {
        if let sampleType = query.objectType as? HKSampleType {
            setAnchor(newAnchor, for: sampleType)
        } else {
            if let identifier = query.objectType?.identifier {
                print("anchoredObjectQueryDidUpdate error: Did not save anchor for \(identifier) – Not an HKSampleType.")
            } else {
                print("anchoredObjectQueryDidUpdate error: query doesn't not have non-nil objectType.")
            }
        }
    }

    private static let userDefaults = UserDefaults.standard

    private static let anchorKeyPrefix = "Anchor_"

    private class func anchorKey(for type: HKSampleType) -> String {
        return anchorKeyPrefix + type.identifier
    }

    /// Returns the saved anchor used in a long-running anchored object query for a particular sample type.
    /// Returns nil if a query has never been run.
    class func getAnchor(for type: HKSampleType) -> HKQueryAnchor? {
        if let anchorData = userDefaults.object(forKey: anchorKey(for: type)) as? Data {
            return try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: anchorData)
        }

        return nil
    }

    /// Update the saved anchor used in a long-running anchored object query for a particular sample type.
    private class func setAnchor(_ queryAnchor: HKQueryAnchor?, for type: HKSampleType) {
        if let queryAnchor = queryAnchor,
            let data = try? NSKeyedArchiver.archivedData(withRootObject: queryAnchor, requiringSecureCoding: true) {
            userDefaults.set(data, forKey: anchorKey(for: type))
        }
    }

    class func fetchStatistics(with identifier: HKQuantityTypeIdentifier,
                               predicate: NSPredicate? = nil,
                               options: HKStatisticsOptions,
                               startDate: Date,
                               endDate: Date = Date(),
                               interval: DateComponents,
                               completion: @escaping (HKStatisticsCollection) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            fatalError("*** Unable to create a step count type ***")
        }

        let anchorDate = createAnchorDate()

        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: predicate,
                                                options: options,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)

        // Set the results handler
        query.initialResultsHandler = { query, results, error in
            if let statsCollection = results {
                completion(statsCollection)
            }
        }

        healthStore.execute(query)
    }

    
}
