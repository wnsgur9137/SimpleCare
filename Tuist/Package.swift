// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "ComposableArchitecture": .framework,
        ],
        baseSettings: Settings.settings(
            configurations: [
                .debug(name: .DEV),
                .release(name: .PROD)
            ]
        )
    )
#endif

let package = Package(
    name: "SimpleCare",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        .package(url: "https://github.com/Moya/Moya", from: "15.0.0"),

        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.22.0"),
        .package(url: "https://github.com/CombineCommunity/CombineCocoa", from: "0.4.0"),

        .package(url: "https://github.com/onevcat/Kingfisher", from: "7.11.0"),
        .package(url: "https://github.com/airbnb/lottie-ios", from: "4.4.1"),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardManager.git", from: "7.0.0"),

        .package(url: "https://github.com/vtourraine/AcknowList", from: "3.2.0")
    ]
)
