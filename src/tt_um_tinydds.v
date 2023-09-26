// tt_um_tinydds.v
// Wrapper our DDS module

`default_nettype none

module tt_um_tinydds #( parameter MAX_COUNT = 10_000_000 ) (
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
    // SYNCHRONIZING INPUTS /////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////

    wire [7:0] ui_in_clk;
    wire async_rstn = ena && rst_n;
    wire rst_n_clk;
    wire rst_clk = !rst_n_clk;

    // Synchronize rst_n
    sync_async_reset inst_sync_async_reset (
        .clock(clk),
        .reset_n(async_rstn),
        .rst_n(rst_n_clk)
    );

    // Synchronize ui_in
    synchronizer #(
        .Width(8), 
        .Stages(2),         //number of shift registers
        .Init(0),           //if nonzero, initialize each register to InitValue
        .InitValue(0)       //initial & reset value
    ) sync_0 (
        .clk(clk),          //in: output clock
        .reset(rst_clk),    //in: active high reset
        .in(ui_in),         //in [Width]: data in
        .out(ui_in_clk)     //out [Width]: data out, delayed by Stages clk cycles
    );

    /////////////////////////////////////////////////////////////////////////////
    // Wires ////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////

    // SPI Interface
    wire spi_clock        = ui_in_clk[0];
    wire spi_cs_n         = ui_in_clk[1];
    wire spi_mosi         = ui_in_clk[2];
    
    // Frequency Select and Phase Select
    wire fselect          = ui_in_clk[3];
    wire pselect          = ui_in_clk[4];

    // Output
    wire [7:0] dds_output;
    assign uo_out         = dds_output;
    
    // Unused
    assign uio_oe         = "00000000";
    assign uio_out        = "00000000";

    /////////////////////////////////////////////////////////////////////////////
    // DDS //////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////

    dds_top inst_dds_top (
        
        // Clock and reset
        .clk(clk),
        .rst_n(rst_n_clk),

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