// dds.v
//

`default_nettype none

module dds (
    
    // Clock and reset
    input  wire        clk,
    input  wire        rst_n,
    
    // Registers
    input  wire [27:0] register_freq0,
    input  wire [27:0] register_freq1,
    input  wire [11:0] register_phase0,
    input  wire [11:0] register_phase1,
    input  wire        fselect,
    input  wire        pselect,
    input  wire [1:0]  register_mode,
    input  wire [7:0]  register_gain,
    input  wire signed [7:0]  register_offset,

    // DDS Output
    output reg [7:0]   dds_output

);

    /////////////////////////////////////////////////////////////////////////////
    // Phase accumulator ////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////

    reg [27:0] phase_accumulator;

    always @(posedge clk) begin
        if (!rst_n)
            phase_accumulator <= 0;
        else
            if (fselect == 0)
                phase_accumulator <= phase_accumulator + register_freq0;
            else
                phase_accumulator <= phase_accumulator + register_freq1;
    end

    /////////////////////////////////////////////////////////////////////////////
    // Phase offset /////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////

    wire [11:0] phase_accumulator_trunc;
    reg [11:0] phase_accumulator_post_offset;
    assign phase_accumulator_trunc = phase_accumulator[27:16];

    always @(posedge clk) begin
        if (pselect == 0)
            phase_accumulator_post_offset <= phase_accumulator_trunc + register_phase0;
        else
            phase_accumulator_post_offset <= phase_accumulator_trunc + register_phase1;
    end

    /////////////////////////////////////////////////////////////////////////////
    // Sin Read Only Memory /////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////

    reg signed  [7:0] sine_data;

    reg [7:0] sine_memory [0:255];
    initial begin
        $display("Loading rom.");
        $readmemh("sine.mem", sine_memory);
    end

    // Compute the sine of our phase
    always @(posedge clk) begin
        sine_data = sine_memory[phase_accumulator_post_offset[11:4]];
    end
    
    /////////////////////////////////////////////////////////////////////////////
    // Gain & Offset Stage //////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////

    reg signed [15:0] sine_data_post_gain;
    wire signed [7:0] sine_data_post_gain2 = sine_data_post_gain[15:8];
    reg signed [8:0] sine_data_post_offset;
    reg signed [7:0] sine_data_post_offset_satured;
    reg saturating;

    // Gain and offset
    always @(posedge clk) begin
        sine_data_post_gain   <= register_gain * sine_data;
        sine_data_post_offset <= sine_data_post_gain2 + register_offset;
    end

    // Saturation
    always @(posedge clk) begin
        if (rst_n == 0) begin
            saturating <= 0;
        end
        else begin

            // Saturation on the maximum value : +127
            if (sine_data_post_offset > 127) begin
                sine_data_post_offset_satured = 127;
                saturating = 1;
            end

            // Saturation on the minimum value : -128
            else if (sine_data_post_offset < -128) begin
                sine_data_post_offset_satured = -128;
                saturating = 1;
            end

            // No saturation : we can safely copy the data
            else begin
                sine_data_post_offset_satured = sine_data_post_offset[7:0];
                saturating = 0;
            end

        end
    end

    /////////////////////////////////////////////////////////////////////////////
    // Mux output data //////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////

    // TODO : implement a basic pseudo random number generator => PRBS ?
    wire [7:0] pn_random;

    // We select the data to ouput with the register_mode
    //
    // Here is how register_mode works :
    //  - "00" = Sine data
    //  - "01" = Phase ramp
    //  - "10" = Sine MSB
    //  - "11" = Pseudorandom Number
    always @(*) begin
        if (register_mode == 0)
            dds_output <= sine_data_post_offset_satured;
        else if (register_mode == 1)
            dds_output <= phase_accumulator_trunc;
        else if (register_mode == 1)
            dds_output <= sine_data[7];
        else
            dds_output <= pn_random;
    end

endmodule