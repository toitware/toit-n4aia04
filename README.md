# N4AIA04

Driver for the N4AIA04 voltage and current sensor.

The N4AIA04 is a voltage and current sensor that is connect through Modbus RTU.

It has 4 sensor pins:
- V1: measures voltage up to 5V.
- V2: measures voltage up to 10V.
- C1: measures current in the 4-20 mA range. Some places in the spec also mention 0-20mA.
- C2: measures current in the 4-20 mA range.

The default baud-rate of the sensor is 9600 baud.
The default unit id (also known as "server address", or "station address") is 1. However, this
  driver also comes with a "detect" functionality which finds the unit id, as long as the sensor
  is the only one connected to the bus.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/toitware/toit-n4aia04/issues
