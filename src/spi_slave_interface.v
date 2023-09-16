// spi_slave_interface.v
// SPI Slave Interface

`default_nettype none

module spi_slave_interface (
    
    // Clock and reset
    input  wire        clk,
    input  wire        rst_n,
    
    // SPI Interface
    input  wire        spi_clock,
    input  wire        spi_cs_n,
    input  wire        spi_mosi,

    // Registers
    output reg [27:0]  register_freq0,
    output reg [27:0]  register_freq1,
    output reg [11:0]  register_phase0,
    output reg [11:0]  register_phase1,
    output reg [1:0]   register_mode,
    output reg [7:0]   register_gain,
    output reg [7:0]   register_offset

);

    reg [31:0] shift_register;
    reg spi_clock_d;
    reg spi_cs_n_d;

    always @(posedge clk) begin
        if (!rst_n) begin
            spi_clock_d         <= 0;
            spi_cs_n_d          <= 0;
            register_freq0      <= 0;
            register_freq1      <= 0;
            register_phase0     <= 0;
            register_phase1     <= 0;
            register_mode       <= 0;
            register_gain       <= 0;
            register_offset     <= 0;
        end
        else begin
            
            // We delay our signals in order to detect edges
            spi_clock_d <= spi_clock;
            spi_cs_n_d  <= spi_cs_n;

            // We detect a rising edge on the clock signal
            // So we sample the spi_mosi signal
            if (spi_clock == 1 && spi_clock_d == 0) begin
                shift_register <= {shift_register[30:0], spi_mosi};
            end

            // If spi_cs_n goes low : we update our registers
            // We try to detect rising edges
            if (spi_cs_n == 1 && spi_cs_n_d == 0) begin

                // The bits [31:29] indicates wich registers we have to update
                // They are similar to an address
                case (shift_register[31:28])
                    
                    4'b0000 :
                        register_mode   <= shift_register[1:0];

                    4'b0001 :
                        register_freq0 <= shift_register[27:0];

                    4'b0010 :
                        register_freq1 <= shift_register[27:0];

                    4'b0011 : 
                        register_phase0 <= shift_register[11:0];

                    4'b0100 :
                        register_phase1 <= shift_register[11:0];
                    
                    4'b0101 :
                        register_gain   <= shift_register[7:0];
                    
                    4'b0110 :
                        register_offset <= shift_register[7:0];

                endcase

            end

        end

    end


endmodule