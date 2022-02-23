import ProjectDescription

let config = Config(compatibleXcodeVersions: ["13.0", "13.1", "13.2", "13.2.1", "13.3"],
                    cache: .cache(profiles: [.profile(name: "Development", configuration: "Debug", device: "iPhone 12", os: "15.2"),
                                             .profile(name: "Release", configuration: "Release", device: "iPhone 12", os: "15.2")],
                                  path: .relativeToRoot( "../TuistCache")),
                    swiftVersion: "5.5.0",
                    generationOptions: [.disableSynthesizedResourceAccessors, .developmentRegion("ru")])
