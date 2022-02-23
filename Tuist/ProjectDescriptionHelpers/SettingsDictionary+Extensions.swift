import ProjectDescription

public extension SettingValue {
    init(string: String) {
        self = .string(string)
    }

    init(array: [String]) {
        self = .array(array)
    }

    static func + (left: SettingValue, right: SettingValue) -> SettingValue {
        switch (left, right) {
        case let (.string(lString), .string(rString)):
            return SettingValue(array: [lString, rString])
        case let (.array(leftArray), .array(rightArray)):
            return SettingValue(array: leftArray + rightArray)
        case let (.string(lString), .array(rArray)):
            return SettingValue(array: [lString] + rArray)
        case let (.array(lArray), .string(rString)):
            return SettingValue(array: lArray + [rString])
        @unknown default:
            fatalError("Not supported SettingValue")
        }
    }
}

public extension SettingsDictionary {
    /// Sets `"GCC_PREPROCESSOR_DEFINITIONS"` to `definitions`
    func preprocessorDefinitions(_ definitions: String...) -> SettingsDictionary {
        merging(["GCC_PREPROCESSOR_DEFINITIONS": SettingValue(string: definitions.joined(separator: " "))])
    }

    /// Sets `"PROVISIONING_PROFILE_SPECIFIER"` to `definitions`
    func provisioningProfile(_ profile: String) -> SettingsDictionary {
        merging(["PROVISIONING_PROFILE_SPECIFIER": SettingValue(string: profile)])
    }
}
