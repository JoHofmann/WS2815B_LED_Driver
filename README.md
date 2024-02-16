# WS2815B_Driver

## Introduction
This is an driver for WS2815B RGB LEDs. This is used to run on a FPGA and is written in VHDL. It converts input data from a SPI interface to serial data that drives the LEDs.

## SPI Interface
The FPGA gets the information about zhe coolors of the LEDs via SPI. It acts as an SPI Slave.

TODO impl interface

## Serial data output
see datasheet of WS2815B.

## Usage

Synthesis:
```console
$ make build
```

Flash:
```console
$ make flash
```

Simulation:
```console
$ make sim
```

Show:
```console
$ make show
```

## License
For open source projects, say how it is licensed.
