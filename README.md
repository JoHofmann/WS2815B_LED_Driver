# WS2815B LED Driver

## Introduction

This is an driver for WS2815B RGB LEDs. This is used to run on a FPGA and is written in VHDL. It converts input data from a SPI interface to serial data that drives the LEDs.

## SPI Interface

TODO

## Serial output

See datasheet of WS2815B.

## Usage

To run the project you need to install following tools:
    - GHDL
    - Yosys
    - nextpnr
    - GTKWave

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

## Simulation

![Simulation with GTKWave](doc/images/Simulation.png)

## Synthesis

TODO

## License

=======
    Copyright 2013 Mir Ikram Uddin

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.