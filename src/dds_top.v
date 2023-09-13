// dds_top.v
// Top module of our design : it contains the SPI Slave interface and the DDS modules

`default_nettype none

module dds_top (
    
    // Clock and reset
    input  wire clk,
    input  wire rst_n,

    // SPI Interface
    input  wire spi_clock,
    input  wire spi_cs_n,
    input  wire spi_mosi,

    // Inputs
    input  wire fselect,
    input  wire pselect,

    // DDS output
    output wire [7:0] dds_output

);

    /////////////////////////////////////////////////////////////////////////////
    // Wires ////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////

    // SPI Registers
    wire [27:0] register_freq0;
    wire [27:0] register_freq1;
    wire [11:0] register_phase0;
    wire [11:0] register_phase1;
    wire [1:0]  register_mode;
    wire [7:0]  register_gain;
    wire [7:0]  register_offset;

    /////////////////////////////////////////////////////////////////////////////
    // SPI Slave Interface //////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////

    spi_slave_interface inst_spi_slave_interface (
        
        // Clock and reset
        .clk(clk),
        .rst_n(rst_n),
        
        // SPI Interface
        .spi_clock(spi_clock),
        .spi_cs_n(spi_cs_n),
        .spi_mosi(spi_mosi),
        
        // Registers
        .register_freq0(register_freq0),
        .register_freq1(register_freq1),
        .register_phase0(register_phase0),
        .register_phase1(register_phase1),
        .register_mode(register_mode),
        .register_gain(register_gain),
        .register_offset(register_offset)

    );

    /////////////////////////////////////////////////////////////////////////////
    // DDS //////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////

    dds inst_dds (
    
        // Clock and reset
        .clk(clk),
        .rst_n(rst_n),
        
        // Registers
        .register_freq0(register_freq0),
        .register_freq1(register_freq1),
        .register_phase0(register_phase0),
        .register_phase1(register_phase1),
        .fselect(fselect),
        .pselect(pselect),
        .register_mode(register_mode),
        .register_gain(register_gain),
        .register_offset(register_offset),

        // DDS Output
        .dds_output(dds_output)

    );

endmodule