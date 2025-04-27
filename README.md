# CPLD Maths Game using Verilog

*ELL201 Sem-2 2024-25 Project*

## Overview

This project implements a mathematics game on a MAX3000A CPLD using Verilog. The CPLD interfaces with switches for input and displays outputs via BCD and LEDs.

## Hardware Specifications

### MAX3000A (EPM3064ALC44)
![MAX3000A CPLD](./images/max3000A.png)

### IO Mapping Diagram
![IO Mapping](./images/IO%20mapping.png)

## Pin Configuration

### Clock and Display
| Signal | Pin | Description |
|--------|-----|-------------|
| clk    | 43  | Global clock (1Hz) |
| o_clk  | 24  | Output clock (to monitor output) |

### BCD Display Outputs
| Signal | Pin |
|--------|-----|
| bcd_tens[3] | 34 |
| bcd_tens[2] | 39 |
| bcd_tens[1] | 41 |
| bcd_tens[0] | 18 |
| bcd_units[3] | 37 |
| bcd_units[2] | 40 |
| bcd_units[1] | 16 |
| bcd_units[0] | 19 |

### Input Switches
| Signal | Pin |
|--------|-----|
| switch[7] or rst | 14 |
| switch[6] | 12 |
| switch[5] | 11 |
| switch[4] | 9 |
| switch[3] | 8 |
| switch[2] | 6 |
| switch[1] | 5 |
| switch[0] | 4 |

### LED Indicators
| Signal | Pin |
|--------|-----|
| led[6] | 33 |
| led[5] | 31 |
| led[4] | 29 |
| led[3] | 28 |
| led[2] | 27 |
| led[1] | 26 |
| led[0] | 25 |

## Programming Instructions

### JITAG commands
```
cable ft2232
detect
svf <file_locaion.svf>
```

## Some useful data
![](./images/7447_to_display_mapp.png)

## Contibutors
- Team GMP (Good morning pineapple)