/*
 * Copyright (c) 2026 Nicolas Christe
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#pragma once

#if defined(__has_include)
#  if __has_include(<esp_adc/adc_oneshot.h>)
#    include <esp_adc/adc_oneshot.h>
#  elif __has_include(<driver/adc_oneshot.h>)
#    include <driver/adc_oneshot.h>
#  else
#    include <driver/adc.h>
#  endif

#  if __has_include(<esp_adc/adc_cali.h>)
#    include <esp_adc/adc_cali.h>
#  endif

#  if __has_include(<esp_adc/adc_cali_scheme.h>)
#    include <esp_adc/adc_cali_scheme.h>
#  endif
#else
#  include <esp_adc/adc_oneshot.h>
#  include <esp_adc/adc_cali.h>
#  include <esp_adc/adc_cali_scheme.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

/// Create the best calibration scheme available for this unit/channel configuration.
///
/// Tries curve fitting first (supported on C6, H2), then line fitting.
/// Returns NULL if no calibration scheme is available on this SoC.
///
/// @param unit      ADC unit.
/// @param channel   ADC channel.
/// @param atten     Attenuation setting.
/// @param bitwidth  Output bit width.
/// @return A calibration handle, or NULL on failure.
adc_cali_handle_t adc_cali_create_best(
    adc_unit_t unit,
    adc_channel_t channel,
    adc_atten_t atten,
    adc_bitwidth_t bitwidth);

/// Delete a calibration handle created by adc_cali_create_best.
///
/// Safe to call with NULL.
///
/// @param handle Calibration handle to delete.
void adc_cali_delete_best(adc_cali_handle_t handle);

#ifdef __cplusplus
}
#endif
