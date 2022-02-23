import ProjectDescription

public func carthage(framework: String) -> TargetDependency {
    .xcframework(path: .relativeToRoot("Carthage/Build/\(framework).xcframework"))
}

public func cocoapods(framework: String) -> TargetDependency {
    .framework(path: .relativeToRoot("Pods/_Prebuild/GeneratedFrameworks/\(framework)/\(framework).framework"))
}

public func project(target: String) -> TargetDependency {
    .project(target: target, path: .relativeToRoot("Modules/\(target)"))
}

public func project(target: String, path: String) -> TargetDependency {
    .project(target: target, path: .relativeToRoot("Modules/" + path))
}

public func module(name: String) -> TargetDependency {
    .project(target: name, path: .relativeToRoot("Modules/" + name))
}

public extension Project {
    static func featureFramework(name: String,
                                 dependencies: [TargetDependency] = [],
                                 exampleDependencies: [TargetDependency] = [],
                                 unitTestDependencies _: [TargetDependency] = [],
                                 exampleHasResources: Bool = false,
                                 projectHasPrivate: Bool = false,
                                 projectHasResources: Bool = true,
                                 projectHasUnitTests _: Bool = false,
                                 projectHasMocks: Bool = false,
                                 unitTestsHasResources _: Bool = false,
                                 coreDataModels: [CoreDataModel] = [],
                                 customConfigurations: [Configuration] = []) -> Project
    {
        let sourcePaths: SourceFilesList = projectHasPrivate ? ["Sources/**/*", "Private/**/*"] : ["Sources/**/*"]
        let targets = [
            Target(name: name,
                   platform: .iOS,
                   product: .framework,
                   bundleId: "com.aton.ru.\(name)",
                   infoPlist: InfoPlist(stringLiteral: "\(name).plist"),
                   sources: sourcePaths,
                   resources: projectHasResources ? "Resources/**" : nil,
                   headers: Headers(public: "Sources/**/*.h",
                                    private: projectHasPrivate ? "Private/**/*.h" : nil,
                                    project: nil),
                   dependencies: dependencies,
                   settings: moduleSettings(customConfigurations: customConfigurations),
                   coreDataModels: coreDataModels),
            Target(name: name + "Examples",
                   platform: .iOS,
                   product: .app,
                   bundleId: "com.aton.ru.\(name)Examples",
                   infoPlist: InfoPlist(stringLiteral: "Examples.plist"),
                   sources: "Examples/Sources/**/*",
                   // resources: examplesResources,
                   dependencies: [
                       .target(name: name),
                    .external(name: "Swinject"),
                   ] + exampleDependencies,
                   settings: moduleExampleSettings,
                   coreDataModels: coreDataModels),
        ]
//        if projectHasUnitTests {
//            var defaultDependencies = [
//                .target(name: name),
//                module(name: "UnitTestUtils"),
//                project(target: "CoreMocks", path: "Core"),
//                project(target: "CommonMocks", path: "Common"),
//                carthage(framework: "Quick"),
//                carthage(framework: "Nimble"),
//            ]
//            if projectHasMocks {
//                defaultDependencies.append(.target(name: "\(name)Mocks"))
//            }
//            var resources: ResourceFileElements = unitTestsHasResources ? [.glob(pattern: .relativeToRoot("Apps/Examples/Resources/**")), "UnitTests/Resources/**"] : [.glob(pattern: .relativeToRoot("Apps/Examples/Resources/**"))]
//
//            targets.append(Target(name: "\(name)UnitTests",
//                                  platform: .iOS,
//                                  product: .unitTests,
//                                  bundleId: "com.aton.ru.\(name)UnitTests",
//                                  infoPlist: InfoPlist(stringLiteral: "\(name).plist"),
//                                  sources: ["UnitTests/Sources/**"],
//                                  resources: resources,
//                                  dependencies: defaultDependencies + unitTestDependencies))
//        }
//        if projectHasMocks {
//            targets.append(Target(name: "\(name)Mocks",
//                                  platform: .iOS,
//                                  product: .framework,
//                                  bundleId: "com.aton.ru.\(name)Mocks",
//                                  infoPlist: InfoPlist(stringLiteral: "\(name).plist"),
//                                  sources: ["Mocks/**"],
//                                  dependencies: [.target(name: name),
//                                                 carthage(framework: "SwiftyMocky"),
//                                                 .xctest]))
//        }
        return Project(name: name, targets: targets)
    }

    static func podProject() -> Project {
        return Project(name: "PodProject",
                       targets: [
                           Target(name: "PodProject",
                                  platform: .iOS,
                                  product: .framework,
                                  productName: "PodProject",
                                  bundleId: "com.aton.ru.PodProject",
                                  infoPlist: "Info.plist",
                                  dependencies: [],
                                  settings: moduleSettings(customConfigurations: []),
                                  coreDataModels: [],
                                  environment: [:]),
                       ])
    }
}
