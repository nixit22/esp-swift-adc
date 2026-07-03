// Copyright (c) 2026 Nicolas Christe
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

@_exported import ESP_ADC
import Platform

private let log = Logger(tag: "ADC")

/// Wrapper for the ESP-IDF ADC oneshot driver.
///
/// `~Copyable` — owns the unit handle; resources freed automatically in `deinit`.
/// Local variables are destroyed in reverse declaration order, so declare `AdcUnit`
/// before any `Channel` values to guarantee the channel is destroyed first.
public struct AdcUnit: ~Copyable {
    private let handle: adc_oneshot_unit_handle_t
    private let unitId: adc_unit_t

    /// Create an ADC oneshot unit. Aborts on failure — intended for boot-time static allocation.
    ///
    /// - Parameter unit: ADC unit to use (default: `ADC_UNIT_1`).
    public init(unit: adc_unit_t = ADC_UNIT_1) {
        // Zero-init lets the driver pick its default clock source and disables ULP.
        var cfg = adc_oneshot_unit_init_cfg_t()
        cfg.unit_id = unit
        var handle: adc_oneshot_unit_handle_t?
        adc_oneshot_new_unit(&cfg, &handle)
            .abortOnError {
                log.e("Failed to create ADC unit: \($0.name)")
            }
        guard let handle else {
            log.e("Failed to create ADC unit: handle is nil")
            fatalError()
        }
        self.handle = handle
        self.unitId = unit
    }

    deinit {
        _ = adc_oneshot_del_unit(handle)
    }

    /// Configure a channel on this ADC unit and return a `Channel` for reading.
    ///
    /// - Parameters:
    ///   - channel:  ADC channel to configure.
    ///   - atten:    Input attenuation (default: `ADC_ATTEN_DB_12` ≈ 0–3.3 V).
    ///   - bitwidth: Conversion resolution (default: `ADC_BITWIDTH_DEFAULT`).
    ///
    /// - Returns: A `Channel` bound to this unit.
    /// - Throws: `Error` if channel configuration fails.
    public func addChannel(
        channel: adc_channel_t,
        atten: adc_atten_t = ADC_ATTEN_DB_12,
        bitwidth: adc_bitwidth_t = ADC_BITWIDTH_DEFAULT
    ) throws(Error) -> Channel {
        var cfg = adc_oneshot_chan_cfg_t(atten: atten, bitwidth: bitwidth)
        try adc_oneshot_config_channel(handle, channel, &cfg)
            .throwEspError {
                log.e("Failed to configure ADC channel: \($0.name)")
            }
        let caliHandle = adc_cali_create_best(unitId, channel, atten, bitwidth)
        return Channel(unitHandle: handle, channel: channel, caliHandle: caliHandle)
    }

    /// A single ADC channel bound to an `AdcUnit`.
    ///
    /// `~Copyable` — owns the calibration handle; freed automatically in `deinit`.
    public struct Channel: ~Copyable {
        private let unitHandle: adc_oneshot_unit_handle_t
        private let channel: adc_channel_t
        private let caliHandle: adc_cali_handle_t?

        init(
            unitHandle: adc_oneshot_unit_handle_t,
            channel: adc_channel_t,
            caliHandle: adc_cali_handle_t?
        ) {
            self.unitHandle = unitHandle
            self.channel = channel
            self.caliHandle = caliHandle
        }

        deinit {
            adc_cali_delete_best(caliHandle)
        }

        /// Read the raw ADC conversion result.
        ///
        /// - Returns: Raw sample in `[0, 2^bitwidth - 1]`.
        /// - Throws: `Error` on timeout or invalid state.
        public func readRaw() throws(Error) -> Int32 {
            var raw: Int32 = 0
            try adc_oneshot_read(unitHandle, channel, &raw)
                .throwEspError {
                    log.e("ADC read failed: \($0.name)")
                }
            return raw
        }

        /// Read the calibrated voltage in millivolts.
        ///
        /// - Returns: Voltage in mV.
        /// - Throws: `Error.espError(ESP_ERR_NOT_SUPPORTED)` if no calibration
        ///   scheme is available on this SoC, or `Error` on read/conversion failure.
        public func readVoltage() throws(Error) -> Int32 {
            guard let caliHandle else {
                throw Error.espError(ESP_ERR_NOT_SUPPORTED)
            }
            let raw = try readRaw()
            var voltage: Int32 = 0
            try adc_cali_raw_to_voltage(caliHandle, raw, &voltage)
                .throwEspError {
                    log.e("ADC calibration conversion failed: \($0.name)")
                }
            return voltage
        }
    }
}
