`include "rtl/divider/binary_divider.v"

module divider 
(
input  wire         clk,
input  wire         reset,
input  wire         enable,
input  wire         div_en,
input  wire [31:0]  cdf_min,
input  wire [31:0]  cdf_in,
output wire [31:0]  g_out,
output wire         ready_g_out
);

wire  [63:0] g_dividend_In;
wire  [63:0] g_divider_In;

reg   [63:0] g_dividend_Q;
reg   [63:0] g_divider_Q;

parameter SIZE = 1600;
parameter LPOW = 8;

assign     g_dividend_In[63:0]    =    (({32'd0, (cdf_in - cdf_min)}<<LPOW) - {32'd0, (cdf_in - cdf_min)});
assign     g_divider_In[63:0]     =    {32'd0, (SIZE - cdf_min)};


always @(posedge clk)
begin
 if(reset) begin
  g_dividend_Q <= 64'd0;
  g_divider_Q  <= 64'd0;
 end
 else begin
    //if cdf_in is 0, pixel does not exist.
	if(cdf_in == 32'd0) begin
		g_dividend_Q   <=  64'd0;
	end
	else begin
    g_dividend_Q <= g_dividend_In;
	end
	
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
   
 