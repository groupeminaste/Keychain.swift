# Keychain

A swift package to manage a REST API

## Installation

Add `https://github.com/GroupeMINASTE/Keychain.swift.git` to your Swift Package configuration (or using the Xcode menu: `File` > `Swift Packages` > `Add Package Dependency`)

## Usage

```swift
// Import the package
import Keychain

// When your need to access the Keychain, initialize it like this:
let keychain = Keychain()

// If you want to use an access group for your Keychain, pass it as a String argument
// let keychain = Keychain(accessGroup: "TEAMID.your.app.identifier")

// To save a value for a key named "yourKey", simply use:
let saved:Bool = keychain.save(5, forKey: "yourKey")
// The returned boolean indicates if the operation was successful

// To read a value for this key
let value = keychain.value(forKey: "yourKey") as? Int ?? 0

// And finally to delete your key and it's value, use:
let deleted:Bool = keychain.remove(forKey: "yourKey")
// The returned boolean indicates if the operation was successful
```
