# SwiftADC

Swift ADC oneshot driver wrapping ESP-IDF's `esp_adc`. Exposes `AdcUnit` and `AdcUnit.Channel` for configuring channels and reading raw or calibrated (mV) samples. Swift module name: **`ADC`**.

Depends on: `SwiftPlatform`, `SwiftSupport`, `esp_adc`.

## Adding it to a project

This is a [SwiftPM](https://www.swift.org/package-manager/) package, built for ESP-IDF by
`swift_package()` from [esp-swift-support](https://github.com/nixit22/esp-swift-support). In your
app's `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/nixit22/esp-swift-adc.git", branch: "SPM"),
],
targets: [
    .target(name: "App", dependencies: [.product(name: "ADC", package: "esp-swift-adc")]),
]
```

See esp-swift-support's README for the project setup (top-level `CMakeLists.txt`, `main`
component, Swift toolchain).

## Usage

```swift
import ADC

let adc = AdcUnit(unit: ADC_UNIT_1)
let channel = try adc.addChannel(channel: ADC_CHANNEL_0, atten: ADC_ATTEN_DB_12)
let raw = try channel.readRaw()
let voltage = try channel.readVoltage()
```

See [`CLAUDE.md`](CLAUDE.md) for full API details and non-obvious patterns (calibration scheme selection, destruction order).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
