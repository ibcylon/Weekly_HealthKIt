import Foundation
import HealthKit

func getSampleType(for identifier: String) -> HKSampleType? {
    if let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: identifier)) {
        return quantityType
    }

    if let categoryType = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: identifier)) {
        return categoryType
    }

    return nil
}

func preferredUnit(for sampleIdentifier: String) -> HKUnit? {
    return preferredUnit(for: sampleIdentifier, sampleType: nil)
}

private func preferredUnit(for identifier: String, sampleType: HKSampleType? = nil) -> HKUnit? {
    var unit: HKUnit?
    let sampleType = sampleType ?? getSampleType(for: identifier)

    if sampleType is HKQuantityType {
        let quantityTypeIdentifier = HKQuantityTypeIdentifier(rawValue: identifier)

        switch quantityTypeIdentifier {
        case .stepCount:
            unit = .count()
        case .distanceWalkingRunning, .sixMinuteWalkTestDistance:
            unit = .meter()
        default:
            break
        }
    }

    return unit
}

func createLastWeekPredicate(from endDate: Date = Date()) -> NSPredicate {
    let startDate = getLastWeekStartDate(from: endDate)
    return HKQuery.predicateForSamples(withStart: startDate, end: endDate)
}

func getLastWeekStartDate(from date: Date = Date()) -> Date {
    return Calendar.current.date(byAdding: .day, value: -6, to: date)!
}

func createAnchorDate() -> Date {
    // Set the arbitrary anchor date to Monday at 3:00 a.m.
    let calendar: Calendar = .current
    var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: Date())
    let offset = (7 + (anchorComponents.weekday ?? 0) - 2) % 7

    anchorComponents.day! -= offset
    anchorComponents.hour = 3

    let anchorDate = calendar.date(from: anchorComponents)!

    return anchorDate
}

func getStatisticsOptions(for dataTypeIdentifier: String) -> HKStatisticsOptions {
    var options: HKStatisticsOptions = .discreteAverage
    let sampleType = getSampleType(for: dataTypeIdentifier)

    if sampleType is HKQuantityType {
        let quantityTypeIdentifier = HKQuantityTypeIdentifier(rawValue: dataTypeIdentifier)

        switch quantityTypeIdentifier {
        case .stepCount, .distanceWalkingRunning:
            options = .cumulativeSum
        case .sixMinuteWalkTestDistance:
            options = .discreteAverage
        default:
            break
        }
    }

    return options
}

func getStatisticsQuantity(for statistics: HKStatistics, with statisticsOptions: HKStatisticsOptions) -> HKQuantity? {
    var statisticsQuantity: HKQuantity?

    switch statisticsOptions {
    case .cumulativeSum:
        statisticsQuantity = statistics.sumQuantity()
    case .discreteAverage:
        statisticsQuantity = statistics.averageQuantity()
    default:
        break
    }

    return statisticsQuantity
}
