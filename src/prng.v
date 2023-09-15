// prng.v
//

`default_nettype none

module prng (
    
    // Clock and reset
    input  wire        clk,
    input  wire        rst_n,

    // Output
    output wire [7:0]   prng_data

);

    reg [7:0] prbs8_register;
    assign prng_data = prbs8_register;

    always @(posedge clk) begin
        if (rst_n == 0) begin
            prbs8_register <= 8'b00000001;
        end 
        else begin
            prbs8_register <= {prbs8_register[6:0], prbs8_register[7] ^ prbs8_register[4] ^ prbs8_register[3] ^ prbs8_register[2]};
        end
    end

endmodule