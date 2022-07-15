// Copyright (C) 2022 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

/**
Tests the N4AIA04 driver.

Connections:
Connect the ESP32 to the modbus with pins RX=17, TX=16, RTS=18.

# Voltage sensor

Create a 3-part voltage divider:
Pin26 on the esp32, followed by three 330Ohm resistors in series (the last one being connected to GND).
The resistor values could be more, but should not be less.
They should all be equal.

Connect V2 to the junction between the first two resistors.
Connect V1 to the junction between the last two resistors.

We expect to measure 1.1V at V1, and 2.2V at V2 (when Pin26 is high).

# Current sensor

Note: we weren't able to measure the correct current. It seems like the sensor has
an internal resistance of ~200Ohm, thus falsifying the result.
This test works under this assumption.

Connect 5V directly to a 330Ohm resistor, and connect the other side to C1.

Connect pin25 to a 330Ohm resistor, and connect the other side to C2.

We expect to measure 5V/330Ohm = 15mA at C1.
When pin25 is high we expect to measure 3.3V/330Ohm = 10mA at C2.
*/

import expect show *
import gpio
import n4aia04
import rs485
import modbus
import log

RX ::= 17
TX ::= 16
RTS ::= 18

VOLTAGE_TEST_PIN ::= 26
CURRENT_TEST_PIN ::= 25

main:
  log.set_default (log.default.with_level log.INFO_LEVEL)
  pin_rx := gpio.Pin RX
  pin_tx := gpio.Pin TX
  pin_rts := gpio.Pin RTS

  voltage_test_pin := gpio.Pin VOLTAGE_TEST_PIN --output
  current_test_pin := gpio.Pin CURRENT_TEST_PIN --output

  rs485_bus := rs485.Rs485
      --rx=pin_rx
      --tx=pin_tx
      --rts=pin_rts
      --baud_rate=n4aia04.N4aia04.DEFAULT_BAUD_RATE
  bus := modbus.Modbus.rtu rs485_bus --baud_rate=n4aia04.N4aia04.DEFAULT_BAUD_RATE

  // Assume that the sensor is the only one on the bus.
  sensor := n4aia04.N4aia04.detect bus

  sensor.set_correction_v1 1.0
  sensor.set_correction_v2 1.0
  sensor.set_correction_c1 1.0
  sensor.set_correction_c2 1.0
  expect_equals 1.0 sensor.read_correction_v1
  expect_equals 1.0 sensor.read_correction_v2
  expect_equals 1.0 sensor.read_correction_c1
  expect_equals 1.0 sensor.read_correction_c2

  sensor.set_correction_v1 1.1
  sensor.set_correction_v2 1.1
  sensor.set_correction_c1 1.1
  sensor.set_correction_c2 1.1
  expect_equals 1.1 sensor.read_correction_v1
  expect_equals 1.1 sensor.read_correction_v2
  expect_equals 1.1 sensor.read_correction_c1
  expect_equals 1.1 sensor.read_correction_c2

  sensor.set_correction_v1 1.0
  sensor.set_correction_v2 1.0
  sensor.set_correction_c1 1.0
  sensor.set_correction_c2 1.0
  expect_equals 1.0 sensor.read_correction_v1
  expect_equals 1.0 sensor.read_correction_v2
  expect_equals 1.0 sensor.read_correction_c1
  expect_equals 1.0 sensor.read_correction_c2

  // These corrections should not be necessary, but the sensor seems to limit the current
  // that goes through it.
  sensor.set_correction_c1 1.64
  sensor.set_correction_c2 1.64

  print "V1: $sensor.read_v1  - should be 0V"
  print "V2: $sensor.read_v2  - should be 0V"
  print "C1: $sensor.read_c1  - should be 15mA"
  print "C2: $sensor.read_c2  - should be 0mA"

  expect 0 <= sensor.read_v1 <= 0.15
  expect 0 <= sensor.read_v2 <= 0.15
  // C1 is constantly connected to V5 and a 330Ohm resistor -> 15mA.
  expect 0.014 <= sensor.read_c1 <= 0.016
  expect 0.0 <= sensor.read_c2 <= 0.0015

  voltage_test_pin.set 1
  print "V1: $sensor.read_v1  - should be 1.1V"
  print "V2: $sensor.read_v2  - should be 2.2V"
  print "C1: $sensor.read_c1  - should be 15mA"
  print "C2: $sensor.read_c2  - should be 0mA"

  expect 1.0 <= sensor.read_v1 <= 1.2
  expect 2.0 <= sensor.read_v2 <= 2.4
  expect 0.014 <= sensor.read_c1 <= 0.016
  expect 0.0 <= sensor.read_c2 <= 0.0015

  current_test_pin.set 1
  print "V1: $sensor.read_v1  - should be 1.1V"
  print "V2: $sensor.read_v2  - should be 2.2V"
  print "C1: $sensor.read_c1  - should be 15mA"
  print "C2: $sensor.read_c2  - should be 10mA"

  expect 1.0 <= sensor.read_v1 <= 1.2
  expect 2.0 <= sensor.read_v2 <= 2.4
  expect 0.014 <= sensor.read_c1 <= 0.016
  expect 0.009 <= sensor.read_c2 <= 0.011

  old_id := n4aia04.N4aia04.detect_unit_id bus
  print "current unit id: $old_id"

  sensor.set_unit_id 5
  expect_equals 5 (n4aia04.N4aia04.detect_unit_id bus)
  sensor5 := n4aia04.N4aia04 (bus.station 5)
  expect 1.0 <= sensor5.read_v1 <= 1.2

  sensor5.set_unit_id 6
  expect_equals 6 (n4aia04.N4aia04.detect_unit_id bus)
  sensor6 := n4aia04.N4aia04 (bus.station 6)
  expect 1.0 <= sensor6.read_v1 <= 1.2

  print "Switching back to old unit id"
  sensor6.set_unit_id old_id

  if old_id != 5:
    expect_throw DEADLINE_EXCEEDED_ERROR: sensor5.read_v1
  else:
    expect_throw DEADLINE_EXCEEDED_ERROR: sensor6.read_v1

  print "done"
