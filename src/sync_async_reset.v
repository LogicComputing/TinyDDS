// sync_async_reset.v
// https://www.intel.com/content/www/us/en/docs/programmable/683082/23-1/use-synchronized-asynchronous-reset.html

module sync_async_reset (
        input    clock,
        input    reset_n,
        output   rst_n
        );
reg     reg3, reg4;
assign  rst_n    = reg4;
always @ (posedge clock, negedge reset_n)
begin
    if (!reset_n)
    begin
       reg3     <= 1'b0;
       reg4     <= 1'b0;
    end
    else
    begin
       reg3     <= 1'b1;
       reg4     <= reg3;
    end
end
endmodule  // sync_async_reset