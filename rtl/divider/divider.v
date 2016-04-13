`include "rtl/divider/binary_divider.v"

module divider 
(
input  wire         clk,
input  wire         reset,
input  wire         enable,
input  wire         div_en,
input  wire [7:0]   cdf_in,
output wire [7:0]   g_out,
output wire         ready_g_out
);

wire  [15:0] g_dividend_In;
wire  [15:0] g_divider_In;

reg   [15:0] g_dividend_Q;
reg   [15:0] g_divider_Q;

parameter CDFMIN = 1;
parameter SIZE = 64;
parameter DYN_RANGE = 8;

assign     g_dividend_In[15:0]    =    (((cdf_in - CDFMIN)<<DYN_RANGE) - (cdf_in - CDFMIN));
assign     g_divider_In[15:0]     =    {8'd0, (SIZE - CDFMIN)};


always @(posedge clk)
begin
 if(reset) begin
  g_dividend_Q <= 16'd0;
  g_divider_Q  <= 16'd0;
 end
 else begin
  g_dividend_Q <= g_dividend_In;
  g_divider_Q  <= g_divider_In;
  end
end

binary_divider div01 (
        .clk            (clk),
		.reset          (reset),
		.div_en         (div_en),
		.g_dividend_Q   (g_dividend_Q),
		.g_divider_Q    (g_divider_Q),
		.quotient       (g_out),
		.done           (ready_g_out)
		);
		
endmodule
   
 