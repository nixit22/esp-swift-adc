# SwiftADC

Swift ADC oneshot driver wrapping ESP-IDF's `esp_adc`. Exposes `AdcUnit` and `AdcUnit.Channel` for configuring channels and reading raw or calibrated (mV) samples. Swift module name: **`ADC`**.

Depends on: `SwiftPlatform`, `SwiftSupport`, `esp_adc`.

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
