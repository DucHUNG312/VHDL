# ADC0832-VHDL

## Overview

This project consists of the communication of a CPLD with a analog-to-digital converter which reads the voltage signal comming form two potentiometers. The signals read are presented on a 7-segment display and transmitted to the computer using simple serial transmission (TX only). This project posseses the following characteristics:

- Developed in [VHDL](https://en.wikipedia.org/wiki/VHDL);
- It uses the Altera MAX II EPM240 CPLD Development Board with the CPLD model EPM240T100C5;
- It was developed in Quartus Prime Version 21.1.0. In order to use this project, just restore the archived project (`project-quartus.qar`) from the project menu in the Quartus Prime software. Or just use the VHDL files directly (It may be easier);
- This project contains many VHDL files that may be useful in other applications:
    - Communication with analog-to-digital converter [ADC0831](./adc0831.vhd);
    - Communication with analog-to-digital converter [ADC0832](./adc0832.vhd);
    - [Digital counter](./counter.vhd);
    - [Digital debouncer](./debouncer.vhd);
    - [Decoder for 7-segment display](./decoder7seg.vhd);
    - [D-type Flip Flop](./flip_flop.vhd);
    - [Frequency divider](./freq_divider.vhd);
    - [Frequency divider with low duty cycle](./freq_divider_low.vhd);
    - [Multiplexed decoder for 7-segment display](./multiplexed_decoder7seg.vhd);
    - [Pulse Width Modulation (PWM)](./pwm.vhd);
    - [Transmitter for serial communication](./serial_tx.vhd);
    - [Shift register](./shift_register.vhd);
- In this project, the CPLD receives the data amostrated from the analog-to-digital converter [ADC0832](https://www.ti.com/product/ADC0832-N). This converter has two analog inputs, which are connected to two potentiometers that can be manually adjusted, changing the data received by the CPLD. The voltage level of the CPLD is 3V3 while the ADC0832 operates at 5V. This is not a problem for the AD0832 digital inputs (`clk_adc`, `cs_adc` and `di_adc` pins), as this chip identifies high logic level above 2V. On the other hand, to connect the digital output of the converter (pin `do_adc`) to the CPLD, a voltage divider circuit was used to adjust the signal amplitudes;
- The digital data received from the analog-to-digital converter is transmitted by the CPLD via a serial interface (by the tx pin). A computer can be connected via TTL/USB converter, and thus receive and analyze these signals (using [serialplot](https://github.com/hyOzd/serialplot), for example).
- List of input and output pins of the CPLD:

| Name        | Pin number  | Description |
| ----------- | ----------- | ----------- |
| a           |	PIN_75      | Signal A of the 7-segment display	|
| b           |	PIN_73      | Signal B of the 7-segment display	|
| c           |	PIN_71      | Signal C of the 7-segment display	|
| clk50MHz    |	PIN_12      | Clock signal of 50 MHz |
| d           |	PIN_70      | Signal D of the 7-segment display	|
| e           |	PIN_72      | Signal E of the 7-segment display	|
| f           |	PIN_76      | Signal F of the 7-segment display	|
| g           |	PIN_74      | Signal G of the 7-segment display	|
| led_green   |	PIN_67      | Green LED |
| led_red     |	PIN_68      | Red LED |
| do_adc      |	PIN_42      | Connected to DO pin of the ADC0832 chip |
| clk_adc     |	PIN_52      | Connected to DLK pin of the ADC0832 chip |
| cs_adc      |	PIN_50      | Connected to CS pin of the ADC0832 chip |
| di_adc      |	PIN_40      | Connected to DI pin of the ADC0832 chip |
| tx          |	PIN_44      | Serial communication tx signal |

## Usage

In order to use this project, just restore the archived project (`project-quartus.qar`) from the project menu in the Quartus Prime software. Or just use the VHDL files directly (It may be easier).
