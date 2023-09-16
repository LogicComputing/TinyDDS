# basic_dds

![alt text](./schematic.png)

Work in progress : basic Direct digital synthesis module in Verilog

The idea is to send this module to TinyTapeout..

## Hierarchy

- tt_um_basic_dds.v
  - spi_slave_interface.v
  - dds_top.v
    - dds.v
      - prng.v

## Ressource usage

TODO : show LUT + FF usage

## DDS

TODO : explain how this DDS works

## SPI Slave Interface

TODO : explain here how to configure the component and describe the registers

| Address           | Register Name | Register content |
| :---------------: |:-------------:| :---------------:|
| 4'h0              | CONTROL       | XXXXXXXXXXXXXXXX |
| 4'h1              | REG_FREQ0     | XXXXXXXXXXXXXXXX |
| 4'h2              | REG_FREQ1     | XXXXXXXXXXXXXXXX |
| 4'h3              | REG_PHASE0    | XXXXXXXXXXXXXXXX |
| 4'h4              | REG_PHASE1    | XXXXXXXXXXXXXXXX |
| Others            | No registers  | ---------------  |
