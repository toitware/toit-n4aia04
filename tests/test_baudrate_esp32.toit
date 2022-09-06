// Copyright (C) 2022 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

/**
Tests changing of baudrate.

No connections except for the standard RS-485 connections are necessary.

Change the FROM_BAUDRATE and TO_BAUDRATE so that the sensor switches the setting.
Then reset the sensor, and change to the next pair.
After each execution the sensor must be reset (power-off).

Typically one would cycle through the available baud-rates:
- 1200
- 2400
- 4800
- 9600
- 19200
*/

import expect show *
import gpio
import n4aia04
import rs485
import modbus
import log

FROM_BAUD_RATE ::= 9600
TO_BAUD_RATE ::= 9600

RX ::= 17
TX ::= 16
RTS ::= 18

main:
  log.set_default (log.default.with_level log.INFO_LEVEL)

  from_baudrate := FROM_BAUD_RATE
  to_baudrate := TO_BAUD_RATE

  pin_rx := gpio.Pin RX
  pin_tx := gpio.Pin TX
  pin_rts := gpio.Pin RTS

  rs485_bus := rs485.Rs485
      --rx=pin_rx
      --tx=pin_tx
      --rts=pin_rts
      --baud_rate=from_baudrate
  bus := modbus.Modbus.rtu rs485_bus

  // Assume that the sensor is the only one on the bus.
  sensor := n4aia04.N4aia04.detect bus

  sensor.set_baud_rate to_baudrate
  print "done"
