// Copyright (C) 2022 Toitware ApS. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be found
// in the LICENSE file.

import modbus
import modbus.rs485 as modbus
import rs485
import gpio

/**
A driver for the N4AIA04 voltage and current sensor.
*/
class N4aia04:
  static DEFAULT_UNIT_ID ::= 1
  static DEFAULT_BAUD_RATE ::= 9600

  static V1_VOLTAGE_ ::= 0x00
  static V2_VOLTAGE_ ::= 0x01
  static C1_CURRENT_ ::= 0x02
  static C2_CURRENT_ ::= 0x03

  static V1_CORRECTION_ ::= 0x07
  static V2_CORRECTION_ ::= 0x08
  static C1_CORRECTION_ ::= 0x09
  static C2_CORRECTION_ ::= 0x0A

  static UNIT_ID_ ::= 0x0E

  static BAUD_RATE_ ::= 0x0F
  static BAUD_RATE_1200_ ::= 0
  static BAUD_RATE_2400_ ::= 1
  static BAUD_RATE_4800_ ::= 2
  static BAUD_RATE_9600_ ::= 3
  static BAUD_RATE_19200_ ::= 4

  registers_/modbus.HoldingRegisters

  constructor station/modbus.Station:
    registers_ = station.holding_registers


  constructor.detect bus/modbus.Modbus:
    id := detect_unit_id bus
    return N4aia04 (bus.station id)

  /**
  Reads the unit id (also known as "server address", or "station address") from the connected sensor.

  Note that only one unit must be on the bus when performing this action.
  */
  static detect_unit_id bus/modbus.Modbus -> int:
    broadcast_station := bus.station 0xFF
    return broadcast_station.holding_registers.read_single --address=UNIT_ID_

  /**
  Reads the voltage between pin V1 and GND.
  The V1 pin can measure at must 5V.

  Returns the voltage in Volts.
  */
  read_v1 -> float:
    return (read_v1 --raw) * 0.01

  /**
  Returns the voltage between pin V1 and GND.
  The V1 pin can measure at must 5V.

  Returns the raw value as reported by the sensor.
  */
  read_v1 --raw/bool -> int:
    if not raw: throw "INVALID_ARGUMENT"
    return read_ V1_VOLTAGE_

  /**
  Reads the voltage between pin V2 and GND.
  The V2 pin can measure at must 10V.

  Returns the voltage in Volts.
  */
  read_v2 -> float:
    return (read_v2 --raw) * 0.01

  /**
  Returns the voltage between pin V2 and GND.
  The V2 pin can measure at must 10V.

  Returns the raw value as reported by the sensor.
  */
  read_v2 --raw/bool -> int:
    if not raw: throw "INVALID_ARGUMENT"
    return read_ V2_VOLTAGE_

  /**
  Reads the current between pin C1 and GND.
  The C1 pin can measure between 4-20mA. Some places in the specification quote 0-20mA.

  Returns the current in Amperes.
  */
  read_c1 -> float:
    return (read_c1 --raw) * 0.0001

  /**
  Returns the current between pin C1 and GND.
  The C1 pin can measure between 4-20mA. Some places in the specification quote 0-20mA.

  Returns the raw value, as reported by the sensor.
  */
  read_c1 --raw/bool -> int:
    if not raw: throw "INVALID_ARGUMENT"
    return read_ C1_CURRENT_

  /**
  Reads the current between pin C2 and GND.
  The C2 pin can measure between 4-20mA.

  Returns the current in Amperes.
  */
  read_c2 -> float:
    return (read_c2 --raw) * 0.0001

  /**
  Returns the current between pin C2 and GND.
  The C2 pin can measure between 4-20mA.

  Returns the raw value, as reported by the sensor.
  */
  read_c2 --raw/bool -> int:
    if not raw: throw "INVALID_ARGUMENT"
    return read_ C2_CURRENT_

  /**
  Reads the correction factor of pin V1.

  For example, a value of 1.1 means that $read_v1 returns a 10% higher value than it actually measured.
  */
  read_correction_v1 -> float:
    return (read_correction_v1 --raw) * 0.001

  /**
  Reads the correction factor of pin V1.

  Returns the raw value as reported by the sensor.
  */
  read_correction_v1 --raw/bool -> int:
    if not raw: throw "INVALID_ARGUMENT"
    return read_ V1_CORRECTION_

  /**
  Sets the correction factor of pin V1.

  For example, a value of 1.1 means that $read_v1 will return a 10% higher value after this call.
  */
  set_correction_v1 factor/float:
    set_correction_v1 --raw (factor * 1000).to_int

  /**
  Sets the correction factor of pin V1.

  Writes the given $factor as raw value to the sensor.
  */
  set_correction_v1 --raw factor/int:
    if not raw: throw "INVALID_ARGUMENT"
    write_ --address=V1_CORRECTION_ factor

  /**
  Reads the correction factor of pin V2.

  For example, a value of 1.1 means that $read_v2 returns a 10% higher value than it actually measured.
  */
  read_correction_v2 -> float:
    return (read_correction_v2 --raw) * 0.001

  /**
  Reads the correction factor of pin V2.

  Returns the raw value as reported by the sensor.
  */
  read_correction_v2 --raw/bool -> int:
    if not raw: throw "INVALID_ARGUMENT"
    return read_ V2_CORRECTION_

  /**
  Sets the correction factor of pin V2.

  For example, a value of 1.1 means that $read_v2 will return a 10% higher value after this call.
  */
  set_correction_v2 factor/float:
    set_correction_v2 --raw (factor * 1000).to_int

  /**
  Sets the correction factor of pin V1.

  Writes the given $factor as raw value to the sensor.
  */
  set_correction_v2 --raw factor/int:
    if not raw: throw "INVALID_ARGUMENT"
    write_ --address=V2_CORRECTION_ factor

  /**
  Reads the correction factor of pin C1.

  For example, a value of 1.1 means that $read_c1 returns a 10% higher value than it actually measured.
  */
  read_correction_c1 -> float:
    return (read_correction_c1 --raw) * 0.001

  /**
  Reads the correction factor of pin C1.

  Returns the raw value as reported by the sensor.
  */
  read_correction_c1 --raw/bool -> int:
    if not raw: throw "INVALID_ARGUMENT"
    return read_ C1_CORRECTION_

  /**
  Sets the correction factor of pin C1.

  For example, a value of 1.1 means that $read_c1 will return a 10% higher value after this call.
  */
  set_correction_c1 factor/float:
    set_correction_c1 --raw (factor * 1000).to_int

  /**
  Sets the correction factor of pin C1.

  Writes the given $factor as raw value to the sensor.
  */
  set_correction_c1 --raw factor/int:
    if not raw: throw "INVALID_ARGUMENT"
    write_ --address=C1_CORRECTION_ factor

  /**
  Reads the correction factor of pin C2.

  For example, a value of 1.1 means that $read_c2 returns a 10% higher value than it actually measured.
  */
  read_correction_c2 -> float:
    return (read_correction_c2 --raw) * 0.001

  /**
  Reads the correction factor of pin C2.

  Returns the raw value as reported by the sensor.
  */
  read_correction_c2 --raw/bool -> int:
    if not raw: throw "INVALID_ARGUMENT"
    return read_ C2_CORRECTION_

  /**
  Sets the voltage correction factor of pin C2.

  For example, a value of 1.1 means that $read_c2 will return a 10% higher value after this call.
  */
  set_correction_c2 factor/float:
    set_correction_c2 --raw (factor * 1000).to_int

  /**
  Sets the voltage correction factor of pin C1.

  Writes the given $factor as raw value to the sensor.
  */
  set_correction_c2 --raw factor/int:
    if not raw: throw "INVALID_ARGUMENT"
    write_ --address=C2_CORRECTION_ factor


  /**
  Changes the unit id (also known as "server address", or "station address") to the given $id.

  After this call, this current instance will be unable to communicate with the sensor (unless the chosen $id is the
    unit id that is already set). One has to create a new instance with the new station.

  The $id must be in range 1-247.
  */
  set_unit_id id/int:
    if not 1 <= id <= 247: throw "INVALID_ARGUMENT"
    write_ --address=UNIT_ID_ id

  /**
  Sets the baud rate of the sensor.

  The change will only take effect after a reboot of the sensor.

  The $baud_rate must be one of:
  - 1200
  - 2400
  - 4800
  - 9600 (default)
  - 19200
  */
  set_baud_rate baud_rate/int:
    register_value /int := ?
    if baud_rate == 1200: register_value = BAUD_RATE_1200_
    else if baud_rate == 2400: register_value = BAUD_RATE_2400_
    else if baud_rate == 4800: register_value = BAUD_RATE_4800_
    else if baud_rate == 9600: register_value = BAUD_RATE_9600_
    else if baud_rate == 19200: register_value = BAUD_RATE_19200_
    else: throw "INVALID_ARGUMENT"
    write_ --address=BAUD_RATE_ register_value



  read_ address/int -> int:
    // Note that the N4aia04 must use function 0x03 (read holding registers) and 0x06 (write single holding register).
    // Other functions are not officially supported.
    return registers_.read_single --address=address

  write_ --address/int value/int:
    registers_.write_single --address=address value
