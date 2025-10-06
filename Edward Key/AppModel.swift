//
//  AppModel.swift
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

import AppKit
import Combine
import SwiftUI
import InputMethodKit

class AppModel: ObservableObject {
    static let shared = AppModel()
    
    @Published var lang: Lang {
        didSet {
            UserDefaults.standard.setEnumValue(lang, forKey: "Lang")
            DispatchQueue.main.async {
                KeyEventManager.shared.changeLanguage(lang: self.lang)
            }
        }
    }
    
    @Published var inputMethod: InputMethod {
        didSet {
            UserDefaults.standard.setEnumValue(inputMethod, forKey: "InputMethod")
            DispatchQueue.main.async {
                KeyEventManager.shared.setInputMethod(method: self.inputMethod)
            }
        }
    }
    
    @Published var excludedApps: [String] {
        didSet {
            UserDefaults.standard.set(excludedApps, forKey: "ExcludedApps")
        }
    }
    
    @Published var isEnableDropOver: Bool {
        didSet {
            UserDefaults.standard.set(isEnableDropOver, forKey: "IsEnableDropOver")
        }
    }
    
    // MARK: - Init
    init() {
        self.lang = UserDefaults.standard.enumValue(forKey: "Lang") ?? .EN
        self.inputMethod = UserDefaults.standard.enumValue(forKey: "InputMethod") ?? .Telex
        self.excludedApps = UserDefaults.standard.stringArray(forKey: "ExcludedApps") ?? []
        self.isEnableDropOver = UserDefaults.standard.bool(forKey: "IsEnableDropOver")
    }
}

