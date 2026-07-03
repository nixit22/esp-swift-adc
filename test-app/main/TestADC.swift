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

import ADC
import Platform

func testADC(logger: Logger) {
    do {
        let adc = AdcUnit(unit: ADC_UNIT_1)
        let channel = try adc.addChannel(channel: ADC_CHANNEL_0, atten: ADC_ATTEN_DB_12)
        let raw = try channel.readRaw()
        logger.i("ADC: raw=\(raw)")
        let voltage = try channel.readVoltage()
        logger.i("ADC: voltage=\(voltage) mV")
        logger.i("ADC: APIs compiled and linked successfully")
        // channel destroyed first (reverse declaration order), then adc — correct IDF cleanup order
    } catch {
        logger.e("ADC: failed: \(error.name)")
    }
}
