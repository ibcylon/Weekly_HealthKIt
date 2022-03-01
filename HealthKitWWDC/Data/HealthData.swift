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

    
}
