`include "rtl/divider/D_FLOP_16REG.v"

module divider 
(
input  wire         clk,
input  wire         reset,
input  wire [7:0]   cdf_in,
output reg  [7:0]   g_out,
output reg          ready_g_out
);

wire  [15:0] g_dividend_In;
wire  [15:0] g_divider_In;

wire  [15:0] g_dividend_Q;
wire  [15:0] g_divider_Q;

parameter CDFMIN = 1;
parameter SIZE = 64;
parameter DYN_RANGE = 8;

assign     g_dividend_In[15:0]    =    (((cdf_in - CDFMIN)<<DYN_RANGE) - (cdf_in - CDFMIN));
assign     g_divider_In[15:0]     =    {8'd0, (SIZE - CDFMIN)};

  D_FLOP_16REG dff16A(
         .clk        (clk),
         .reset      (reset),
         .D          (g_dividend_In),
         .Q          (g_dividend_Q)
  );
  
  D_FLOP_16REG dff16B(
         .clk        (clk),
         .reset      (reset),
         .D          (g_divider_In),
         .Q          (g_divider_Q)
  );
  
always @(posedge clk)
begin
 if(reset) begin
   g_out <= 8'd0;
   ready_g_out <= 1'b0;
 end
 else begin
   g_out <= 8'b11111111;
   ready_g_out <= 1'b0;
 end
end
endmodule
   
 