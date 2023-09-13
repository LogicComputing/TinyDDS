// tt_um_basic_dds.v
// Wrapper our DDS module

`default_nettype none

module tt_um_basic_dds #( parameter MAX_COUNT = 10_000_000 ) (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    /////////////////////////////////////////////////////////////////////////////
    // Wires ////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////

    wire spi_clock        = ui_in[0];
    wire spi_cs_n         = ui_in[1];
    wire spi_mosi         = ui_in[2];
        
    wire fselect          = ui_in[3];
    wire pselect          = ui_in[4];

    wire [7:0] dds_output;
    assign uo_out         = dds_output;
    
    assign uio_oe         = "00000000";
    assign uio_out        = "00000000";

    /////////////////////////////////////////////////////////////////////////////
    // DDS //////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////

    dds_top inst_dds_top (
        
        // Clock and reset
        .clk(clk),
        .rst_n(rst_n),

        // SPI Interface
        .spi_clock(spi_clock),
        .spi_cs_n(spi_cs_n),
        .spi_mosi(spi_mosi),

        // Inputs
        .fselect(fselect),
        .pselect(pselect),

        // DDS outputs
        .dds_output(dds_output)

    );

endmodule