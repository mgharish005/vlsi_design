module D_FLOP_16REG
(
input               clk,
input               reset,
input       [15:0]  D,
output  reg [15:0]  Q);

always @(posedge clk)
begin

if(reset)
  Q <= 16'd0;
else 
  Q <= D;  
end

endmodule

