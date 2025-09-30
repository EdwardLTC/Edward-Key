//
//  Extension.swift
//  Edward Key
//
//  Created by Thành Công Lê on 30/9/25.
//

import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleLanguage = Self("toggleLanguage")
    static let dropOver = Self("dropOver")
}

extension UserDefaults {
    func enumValue<T: RawRepresentable>(forKey key: String) -> T? where T.RawValue == String {
        if let rawValue = string(forKey: key) {
            return T(rawValue: rawValue)
        }
        return nil
    }
    
    func setEnumValue<T: RawRepresentable>(_ value: T, forKey key: String) where T.RawValue == String {
        set(value.rawValue, forKey: key)
    }
}
