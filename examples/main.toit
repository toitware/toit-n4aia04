// Copyright (C) 2022 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

/**
Demonstrates the use of the driver using a common uart-rs485 transceiver, such as the
  SP3485, used in the BOB-10124 transceiver breakout board.
*/

import gpio
import n4aia04
import rs485
import modbus

RX ::= 17
TX ::= 16
RTS ::= 18

main:
  pin_rx := gpio.Pin RX
  pin_tx := gpio.Pin TX
  pin_rts := gpio.Pin RTS

  rs485_bus := rs485.Rs485
      --rx=pin_rx
      --tx=pin_tx
      --rts=pin_rts
      --baud_rate=n4aia04.N4aia04.DEFAULT_BAUD_RATE
  bus := modbus.Modbus.rtu rs485_bus --baud_rate=n4aia04.N4aia04.DEFAULT_BAUD_RATE

  // Assume that the sensor is the only one on the bus.
  sensor := n4aia04.N4aia04.detect bus

  print sensor.read_v1
  print sensor.read_v2
  print sensor.read_c1
  print sensor.read_c2
