# ASAPTY iOS SDK

[![Version](https://img.shields.io/cocoapods/v/ASAPTY_SDK.svg?style=flat)](https://cocoapods.org/pods/ASAPTY_SDK)
[![License](https://img.shields.io/cocoapods/l/ASAPTY_SDK.svg?style=flat)](https://cocoapods.org/pods/ASAPTY_SDK)
[![Platform](https://img.shields.io/cocoapods/p/ASAPTY_SDK.svg?style=flat)](https://cocoapods.org/pods/ASAPTY_SDK)
[![Swift Package Manager](https://img.shields.io/badge/SwiftPM-compatible-yellowgreen.svg)](https://swift.org/package-manager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift 5](https://img.shields.io/badge/language-Swift5-orange.svg)](https://developer.apple.com/swift)
[![Powered by Tuist](https://img.shields.io/badge/Powered%20by-Tuist-blue)](https://tuist.io)

Apple Search Ads attributions in one line of code.
```swift
ASAPTY.shared.attribution(with: "#########")
```

To track In-App Events:

```swift
ASAPTY.shared.subscribeForInAppEvents()
```
or track events manually using:
```swift
ASAPTY.shared.track(eventName: "inapp_purchase", productId: "com.sdk.asapty", revenue: "3.0", currency: "USD")
```




## Installation

### Cocoapods:

```ruby
pod 'ASAPTY_SDK'
```
### Swift Package Manager:

1. From Xcode, select from the menu **File > Swift Packages > Add Package Dependency**
2. Specify the URL `https://github.com/asapty/asapty_sdk`

### Carthage:

To integrate PinLayout into your Xcode project using Carthage, specify it in your `Cartfile`:

```
github "asapty/asapty_sdk"
```

Then, run `carthage update` to build the framework and drag the built `ASAPTY_SDK.framework` into your Xcode project.

## License

ASAPTY is available under the MIT license. See the LICENSE file for more info.



