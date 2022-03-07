//
//  UserManager.swift
//  HealthKitWWDC
//
//  Created by Kanghos on 2022/03/07.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    private let userDefaults: UserDefaults
    private let defaultValue: T

    let key: String

    var wrappedValue: T {
        get { return UserDefaults.standard.object(forKey: self.key) as? T ?? self.defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: self.key) }
    }

    init(key: String, defaultValue: T, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }
}

final class UserManager {

    @UserDefault(key: "lastSelectedTab", defaultValue: 0)
    static var lastSelectedTab: Int
}
