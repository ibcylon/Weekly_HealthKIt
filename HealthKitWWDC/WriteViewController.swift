//WriteExample

import HealthKit
import UIKit

final class HealthDataManager {

    static let healthStore: HKHealthStore = HKHealthStore()
}


final class WriteViewController: UIViewController {

    var healthStore: HKHealthStore?
    let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func isHealthDataAvaliable() {

        if HKHealthStore.isHealthDataAvailable() {

            print("지원 함")

            healthStore = HealthDataManager.healthStore

            requestWalkAuthorization()

        } else {

            print("지원 안 함")
        }
    }

    func requestWalkAuthorization() {

        // 권한 요청
        healthStore?.requestAuthorization(toShare: [distanceType], read: nil) { success, error in

            if success {
                print("요청에 성공")
            } else {
                print("요청에 실패")
            }
        }
    }

    func saveWalkDistance() {

        // QuantitySample을 만들기 위해서 아래와 같은 시작 / 종료 / Value가 필요 함.
        let startDate = Calendar.current.date(bySettingHour: 14, minute: 35, second: 0, of: Date())!
        let endDate = Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: Date())!

        let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: 628.0)

        //샘플 생성
        let sample = HKQuantitySample(type: distanceType,
                                      quantity: distanceQuantity,
                                      start: startDate,
                                      end: endDate)

        //샘플 저장
        healthStore?.save(sample) { success, error in
            if success {
                print("저장 성공")
            } else {
                print("저장 실패")
            }
        }
    }
}
