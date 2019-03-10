# Pikko - iOS color picker made with ❤️

[![CI Status](https://img.shields.io/travis/melloskitten/pikko.svg?style=flat)](https://travis-ci.org/melloskitten/pikko)
[![Version](https://img.shields.io/cocoapods/v/Pikko.svg?style=flat)](https://cocoapods.org/pods/Pikko)
[![License](https://img.shields.io/github/license/melloskitten/pikko.svg?style=flat)](https://cocoapods.org/pods/Pikko)
[![Platform](https://img.shields.io/cocoapods/p/Pikko.svg?style=flat)](https://cocoapods.org/pods/Pikko)

![Demo of pikko color picker](https://raw.githubusercontent.com/melloskitten/pikko/develop/doc/demo.gif)

Pikko is a simple and beautiful color picker for iOS. It's inspired by conventional color pickers from popular graphics tools such as _Photoshop_, _Paint Tool Sai_, _Procreate_ and many others. Pikko allows the selection of hue, saturation and brightness in a more pleasant way than boring sliders.

Feel free to use, modify and improve. ✌️

## Quickstart

To run the example project, clone the repo, and run `pod install` from the Example directory first.

You can intialize a new color picker in the following way:

```swift
// Initialize a new Pikko instance with width and height set to 300, and initialized to blue.
let pikko = Pikko(dimension: 300, setToColor: .blue)
```

Make sure to set the Pikko delegate to get updates on color changes:

```swift
// Set the PikkoDelegate to get notified on new color changes.
pikko.delegate = self
```

Positioning Pikko:

```swift
// Set Pikko center and add it to the main view.
pikko.center = self.view.center
self.view.addSubview(pikko)
```

Manually getting a color from Pikko and setting a color:
```swift
// Getting Pikko color.
let color = pikko.getColor()

// Setting Pikko to a specific color.
pikko.setColor(.blue)
```


## Installation

Pikko is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Pikko'
```

## Authors

Sandra, melloskitten@googlemail.com

Johannes, mail@johannesrohwer.com

## License

__Pikko__ is available under the MIT license. See the LICENSE file for more info.
