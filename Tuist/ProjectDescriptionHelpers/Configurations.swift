import ProjectDescription

// MARK: - Base configurations

public let base: SettingsDictionary = [
    "SDKROOT": "iphoneos",
    "TARGETED_DEVICE_FAMILY": "1",
    "ALWAYS_SEARCH_USER_PATHS": false,
    "IPHONEOS_DEPLOYMENT_TARGET": "12.0",
    "VERSIONING_SYSTEM": "Apple Generic",
    "ARCHS": "$(ARCHS_STANDARD)",
    "SWIFT_VERSION": "5.5",
    "CLANG_ENABLE_MODULES": true,
    "CODE_SIGN_STYLE": "Manual",
    "PLIST_FILE_OUTPUT_FORMAT": "binary",
    "DEVELOPMENT_TEAM": "T97SCTZCHY",
    "COMPRESS_PNG_FILES": false, // png optimization is done manually
    "ENABLE_BITCODE": false,
    "BITCODE_GENERATION_MODE": "bitcode",
    "OTHER_CFLAGS": "-fembed-bitcode",
    "OTHER_LDFLAGS": "-ObjC",
    "INTENTS_CODEGEN_LANGUAGE": "Objective-C",
    // Warnings
    "GCC_TREAT_WARNINGS_AS_ERRORS": false,
    "WARNING_CFLAGS": "-Wno-ambiguous-macro -Wno-incomplete-module -Wno-nullability-completeness",
    "CLANG_WARN_STRICT_PROTOTYPES": false
]
public let disabledWarningsSwiftFlags = SettingValue("-Xcc -Wno-incomplete-module -Xcc -Wno-nullability-completeness")

private let releasePreprocessorDefinitions = SettingValue("NDEBUG=1 ddLogLevel=DDLogLevelError FIREBASE=1")
private let releaseSwiftFlags = SettingValue("-DPROD")
public let release = base.merging([
    "COPY_PHASE_STRIP": true,
    "ENABLE_NS_ASSERTIONS": false,
    "GCC_OPTIMIZATION_LEVEL": "s",
    "GCC_PREPROCESSOR_DEFINITIONS": releasePreprocessorDefinitions,
    "OTHER_SWIFT_FLAGS": releaseSwiftFlags,
    "LLVM_LTO": false,
    "ONLY_ACTIVE_ARCH": false,
    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "PROD",
    "STRIP_INSTALLED_PRODUCT": true,
    "SWIFT_OPTIMIZATION_LEVEL": "-Owholemodule",
    "SWIFT_COMPILATION_MODE": "wholemodule",
    "VALIDATE_PRODUCT": true,
    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
    "CODE_SIGN_IDENTITY": "iPhone Distribution",
    "CONFIGURATION": "Release"
])

private let adhocPreprocessorDefinitions = SettingValue("DEBUG=1 ddLogLevel=DDLogLevelVerbose ENABLE_DEBUG_SETTINGS=1 CRASHLYTICS=1")
private let adhocSwiftFlags = disabledWarningsSwiftFlags + "-DDEBUG -DENABLE_DEBUG_SETTINGS"
public let adhoc = base.merging([
    "COPY_PHASE_STRIP": false,
    "GCC_OPTIMIZATION_LEVEL": "0",
    "GCC_PREPROCESSOR_DEFINITIONS": adhocPreprocessorDefinitions,
    "OTHER_SWIFT_FLAGS": adhocSwiftFlags,
    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG",
    "STRIP_INSTALLED_PRODUCT": false,
    "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
    "LLVM_LTO": false,
    "ONLY_ACTIVE_ARCH": false,
    "OTHER_CFLAGS": "-ftrapv",
    "OTHER_CODE_SIGN_FLAGS": "--timestamp=none",
    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
    "CODE_SIGN_IDENTITY": "iPhone Distribution",
    "CONFIGURATION": "Adhoc"
])

private let debugPreprocessorDefinitions = SettingValue("DEBUG=1 ddLogLevel=DDLogLevelVerbose ENABLE_DEBUG_SETTINGS=1")
private let debugSwiftFlags = disabledWarningsSwiftFlags + "-DDEBUG -DENABLE_DEBUG_SETTINGS"
public let debug = base.merging([
    "COPY_PHASE_STRIP": false,
    "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
    "GCC_PREPROCESSOR_DEFINITIONS": debugPreprocessorDefinitions,
    "OTHER_SWIFT_FLAGS": debugSwiftFlags,
    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG",
    "STRIP_INSTALLED_PRODUCT": false,
    "ENABLE_TESTABILITY": true,
    "LLVM_LTO": false,
    "ONLY_ACTIVE_ARCH": true,
    "OTHER_CFLAGS": "-ftrapv",
    "OTHER_CODE_SIGN_FLAGS": "--timestamp=none",
    "SWIFT_COMPILATION_MODE": "singlefile",
    "DEBUG_INFORMATION_FORMAT": "dwarf",
    "CODE_SIGN_IDENTITY": "iPhone Developer",
    "CONFIGURATION": "Debug"
])

private func settings(debug: SettingsDictionary,
                      adhoc: SettingsDictionary,
                      release: SettingsDictionary,
                      customConfigurations: [Configuration] = []) -> Settings {
    let defaultSettings = [String: SettingValue]()
    let configurations = [
    Configuration.debug(name: "Debug", settings: debug, xcconfig: nil),
    Configuration.release(name: "AdHoc", settings: adhoc, xcconfig: nil),
    Configuration.release(name: "Release", settings: release, xcconfig: nil),
    Configuration.debug(name: "DEV1", settings: debug, xcconfig: nil),
    Configuration.debug(name: "DEV2", settings: debug, xcconfig: nil),
    Configuration.debug(name: "TEST1", settings: debug, xcconfig: nil),
    Configuration.debug(name: "TEST2", settings: debug, xcconfig: nil),
    Configuration.debug(name: "TEST3", settings: debug, xcconfig: nil),
    Configuration.debug(name: "UAT", settings: debug, xcconfig: nil)
    ]
    let finalConfigurations = customConfigurations.count > 0 ? customConfigurations : configurations
    return .settings(base: defaultSettings, configurations: finalConfigurations, defaultSettings: .essential)
}

private let atonBase: SettingsDictionary = [
    "CURRENT_PROJECT_VERSION": appBuild(fallback: "1"),
    "MARKETING_VERSION": appVersion(fallback: "2.65.0"),
    "SWIFT_VERSION": "5.5"
]

public let atonLineSettings: Settings = {
    let aton = atonBase.merging([
        "PRODUCT_NAME": "Aton Line",
        "PRODUCT_MODULE_NAME": "Aton_Line",
        "APP_NAME": appName(fallback: "Aton Line"),
        "OTHER_LDFLAGS": "$(OTHER_LDFLAGS) -ObjC",
        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
    ])
    let r = release.merging(aton).provisioningProfile("match AppStore ru.aton.finance")
    let a = adhoc.merging(aton).provisioningProfile("match AdHoc ru.aton.finance")
    let d = debug.merging(aton).provisioningProfile("match Development ru.aton.finance")

    return settings(debug: d,
                    adhoc: a,
                    release: r,
                    customConfigurations: [
                        Configuration.debug(name: "Debug", settings: d, xcconfig: "Configs/Debug.xcconfig"),
                        Configuration.release(name: "AdHoc", settings: a, xcconfig: "Configs/Release.xcconfig"),
                        Configuration.release(name: "Release", settings: r, xcconfig: "Configs/Release.xcconfig")
                    ])
}()

public let atonLineDEV1Settings: Settings = {
    let aton = atonBase.merging([
        "PRODUCT_NAME": "Aton Line DEV1",
        "PRODUCT_MODULE_NAME": "Aton_Line",
        "APP_NAME": appName(fallback: "Aton Line DEV1"),
        "OTHER_LDFLAGS": "$(OTHER_LDFLAGS) -ObjC",
        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        "GCC_PRECOMPILE_PREFIX_HEADER": true
    ])

    let r = release.merging(aton).provisioningProfile("match AppStore ru.aton.finance.dev1")
    let a = adhoc.merging(aton).provisioningProfile("match AdHoc ru.aton.finance.dev1")
    let d = debug.merging(aton).provisioningProfile("match Development ru.aton.finance.dev1")

    return settings(debug: d,
                    adhoc: a,
                    release: r,
                    customConfigurations: [
                        Configuration.debug(name: "Debug", settings: d, xcconfig: "Configs/DEV1.xcconfig"),
                        Configuration.release(name: "AdHoc", settings: a, xcconfig: "Configs/DEV1.xcconfig"),
                        Configuration.release(name: "Release", settings: r, xcconfig: "Configs/DEV1.xcconfig")
                    ])
}()

public let atonLineDEV2Settings: Settings = {
    let aton = atonBase.merging([
        "PRODUCT_NAME": "Aton Line DEV2",
        "PRODUCT_MODULE_NAME": "Aton_Line",
        "APP_NAME": appName(fallback: "Aton Line DEV2"),
        "OTHER_LDFLAGS": "$(OTHER_LDFLAGS) -ObjC",
        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        "GCC_PRECOMPILE_PREFIX_HEADER": true
    ])

    let r = release.merging(aton).provisioningProfile("match AppStore ru.aton.finance.dev2")
    let a = adhoc.merging(aton).provisioningProfile("match AdHoc ru.aton.finance.dev2")
    let d = debug.merging(aton).provisioningProfile("match Development ru.aton.finance.dev2")

    return settings(debug: d,
                    adhoc: a,
                    release: r,
                    customConfigurations: [
                        Configuration.debug(name: "Debug", settings: d, xcconfig: "Configs/DEV2.xcconfig"),
                        Configuration.release(name: "AdHoc", settings: a, xcconfig: "Configs/DEV2.xcconfig"),
                        Configuration.release(name: "Release", settings: r, xcconfig: "Configs/DEV2.xcconfig")
                    ])
}()

public let atonLineTEST1Settings: Settings = {
    let aton = atonBase.merging([
        "PRODUCT_NAME": "Aton Line TEST1",
        "PRODUCT_MODULE_NAME": "Aton_Line",
        "APP_NAME": appName(fallback: "Aton Line TEST1"),
        "OTHER_LDFLAGS": "$(OTHER_LDFLAGS) -ObjC",
        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        "GCC_PRECOMPILE_PREFIX_HEADER": true
    ])

    let r = release.merging(aton).provisioningProfile("match AppStore ru.aton.finance.test1")
    let a = adhoc.merging(aton).provisioningProfile("match AdHoc ru.aton.finance.test1")
    let d = debug.merging(aton).provisioningProfile("match Development ru.aton.finance.test1")

    return settings(debug: d,
                    adhoc: a,
                    release: r,
                    customConfigurations: [
                        Configuration.debug(name: "Debug", settings: d, xcconfig: "Configs/TEST1.xcconfig"),
                        Configuration.release(name: "AdHoc", settings: a, xcconfig: "Configs/TEST1.xcconfig"),
                        Configuration.release(name: "Release", settings: r, xcconfig: "Configs/TEST1.xcconfig")
                    ])
}()

public let atonLineTEST2Settings: Settings = {
    let aton = atonBase.merging([
        "PRODUCT_NAME": "Aton Line TEST2",
        "PRODUCT_MODULE_NAME": "Aton_Line",
        "APP_NAME": appName(fallback: "Aton Line TEST2"),
        "OTHER_LDFLAGS": "$(OTHER_LDFLAGS) -ObjC",
        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        "GCC_PRECOMPILE_PREFIX_HEADER": true
    ])

    let r = release.merging(aton).provisioningProfile("match AppStore ru.aton.finance.test2")
    let a = adhoc.merging(aton).provisioningProfile("match AdHoc ru.aton.finance.test2")
    let d = debug.merging(aton).provisioningProfile("match Development ru.aton.finance.test2")

    return settings(debug: d,
                    adhoc: a,
                    release: r,
                    customConfigurations: [
                        Configuration.debug(name: "Debug", settings: d, xcconfig: "Configs/TEST2.xcconfig"),
                        Configuration.release(name: "AdHoc", settings: a, xcconfig: "Configs/TEST2.xcconfig"),
                        Configuration.release(name: "Release", settings: r, xcconfig: "Configs/TEST2.xcconfig")
                    ])
}()

public let atonLineTEST3Settings: Settings = {
    let aton = atonBase.merging([
        "PRODUCT_NAME": "Aton Line TEST3",
        "PRODUCT_MODULE_NAME": "Aton_Line",
        "APP_NAME": appName(fallback: "Aton Line TEST3"),
        "OTHER_LDFLAGS": "$(OTHER_LDFLAGS) -ObjC",
        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        "GCC_PRECOMPILE_PREFIX_HEADER": true
    ])

    let r = release.merging(aton).provisioningProfile("match AppStore ru.aton.finance.test3")
    let a = adhoc.merging(aton).provisioningProfile("match AdHoc ru.aton.finance.test3")
    let d = debug.merging(aton).provisioningProfile("match Development ru.aton.finance.test3")

    return settings(debug: d,
                    adhoc: a,
                    release: r,
                    customConfigurations: [
                        Configuration.debug(name: "Debug", settings: d, xcconfig: "Configs/TEST3.xcconfig"),
                        Configuration.release(name: "AdHoc", settings: a, xcconfig: "Configs/TEST3.xcconfig"),
                        Configuration.release(name: "Release", settings: r, xcconfig: "Configs/TEST3.xcconfig")
                    ])
}()

public let atonLineUATSettings: Settings = {
    let aton = atonBase.merging([
        "PRODUCT_NAME": "Aton Line UAT",
        "PRODUCT_MODULE_NAME": "Aton_Line",
        "APP_NAME": appName(fallback: "Aton Line UAT"),
        "OTHER_LDFLAGS": "$(OTHER_LDFLAGS) -ObjC",
        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        "GCC_PRECOMPILE_PREFIX_HEADER": true
    ])

    let r = release.merging(aton).provisioningProfile("match AppStore ru.aton.finance.uat")
    let a = adhoc.merging(aton).provisioningProfile("match AdHoc ru.aton.finance.uat")
    let d = debug.merging(aton).provisioningProfile("match Development ru.aton.finance.uat")

    return settings(debug: d,
                    adhoc: a,
                    release: r,
                    customConfigurations: [
                        Configuration.debug(name: "Debug", settings: d, xcconfig: "Configs/UAT.xcconfig"),
                        Configuration.release(name: "AdHoc", settings: a, xcconfig: "Configs/UAT.xcconfig"),
                        Configuration.release(name: "Release", settings: r, xcconfig: "Configs/UAT.xcconfig")
                    ])
}()

// MARK: - Modules configurations

public func moduleSettings(customConfigurations: [Configuration] = []) -> Settings {
    let r = release.merging(atonBase)
    let a = adhoc.merging(atonBase)
    let d = debug.merging(atonBase)
    return settings(debug: d, adhoc: a, release: r, customConfigurations: customConfigurations)
}

public let moduleExampleSettings: Settings = {
    let r = release.merging(atonBase)
    let a = adhoc.merging(atonBase)
    let d = debug.merging(atonBase).provisioningProfile("match")
    return settings(debug: d, adhoc: a, release: r)
}()

// MARK: - Helpers

private func appVersion(fallback: String) -> SettingValue {
    if case let .string(environmentAppVersion) = Environment.appVersion {
        return SettingValue(string: environmentAppVersion)
    } else {
        return SettingValue(string: fallback)
    }
}

private func appBuild(fallback: String) -> SettingValue {
    if case let .string(environmentAppBuild) = Environment.appBuild {
        return SettingValue(string: environmentAppBuild)
    } else {
        return SettingValue(string: fallback)
    }
}

private func appName(fallback: String) -> SettingValue {
    if case let .string(environmentAppName) = Environment.appName {
        return SettingValue(string: environmentAppName)
    } else {
        return SettingValue(string: fallback)
    }
}
