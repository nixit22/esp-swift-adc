# SwiftADC

Swift ADC oneshot driver wrapping `esp_adc`. Swift module name: **`ADC`**.

Depends on: `SwiftPlatform`, `SwiftSupport`, `esp_adc`

## Files

| File | Role |
|---|---|
| `src/ADC.swift` | `AdcUnit` and `AdcUnit.Channel` — public Swift API |
| `src/adc.c` / `src/adc.h` | C glue: calibration scheme factory and delete helpers |
| `module.modulemap` | Clang module `ESP_ADC` — umbrella over `src/adc.h` |

## Public API

```swift
// Create unit (ADC_UNIT_1 is the default; only one unit exists on C6/H2) — aborts on failure
let adc = AdcUnit(unit: ADC_UNIT_1)

// Configure a channel; curve-fitting calibration created automatically
let channel = try adc.addChannel(channel: ADC_CHANNEL_0, atten: ADC_ATTEN_DB_12)

// Read raw sample (in [0, 2^bitwidth - 1])
let raw = try channel.readRaw()

// Read calibrated voltage in mV (throws ESP_ERR_NOT_SUPPORTED if no calibration)
let mV = try channel.readVoltage()

// No explicit cleanup — deinit handles it.
// channel is destroyed before adc (reverse declaration order) — correct IDF order.
```

## Non-obvious patterns

**`~Copyable` + `deinit`** — both `AdcUnit` and `AdcUnit.Channel` are noncopyable. `AdcUnit.deinit` calls `adc_oneshot_del_unit`; `Channel.deinit` calls `adc_cali_delete_best`. Declare `adc` before `channel` so Swift destroys them in reverse order (channel first), which matches the IDF ownership requirement.

**Calibration scheme is SoC-conditional** — `adc_cali_create_best` (C wrapper) tries curve fitting first, then line fitting. On ESP32-C6 and ESP32-H2 only `ADC_CALI_SCHEME_CURVE_FITTING_SUPPORTED` is defined, so curve fitting is always selected. `adc_cali_delete_best` mirrors this priority — it calls the correct delete function for whatever scheme was created. If neither scheme is supported, `caliHandle` is nil and `readVoltage()` throws `ESP_ERR_NOT_SUPPORTED`.

**`clk_src` zero-init** — `adc_oneshot_unit_init_cfg_t` is zero-initialized; only `unit_id` is set explicitly. Passing 0 for `clk_src` lets the driver choose its default clock source, avoiding an SoC-conditional enum value.

**`@_exported import ESP_ADC`** — re-exports the C module so callers get `adc_unit_t`, `adc_channel_t`, `adc_atten_t`, `ADC_UNIT_*`, `ADC_CHANNEL_*`, `ADC_ATTEN_*` etc. without importing `ESP_ADC` separately.

**ADC_UNIT_2 not available on C6/H2** — both targets only expose ADC_UNIT_1. Passing `ADC_UNIT_2` to `adc_oneshot_new_unit` returns `ESP_ERR_NOT_FOUND`.
