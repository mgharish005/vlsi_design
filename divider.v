module divider 
(
input          clk,
input          reset,
input  [7:0]   cdf_in,
output [7:0]   g_out
);

reg  [15:0] g_dividend;
reg  [15:0] g_divider;
reg  [31:0] qr;
reg  [16:0] diff;
reg  [4:0]  bit_num;

wire [7:0]  g_out    = qr[7:0];
wire        ready    = !bit_num;

initial begin

   bit_num = 0;
   
end
   
parameter CDFMIN = 1;
parameter SIZE = 64;
parameter DYN_RANGE = 8;

always @(posedge clk )
begin

    if(!reset) begin
	g_dividend = (((cdf_in - CDFMIN)<<DYN_RANGE) - (cdf_in - CDFMIN));
	g_divider  = {8'd0, (SIZE - CDFMIN)};
	end
end

always @(posedge clk)
begin
    if(!reset) begin	
	  if(ready) begin
	  bit_num = 16;
	  qr = {16'd0, g_dividend};
	  end 
	  else begin
	  diff = qr[31:15] - {1'b0, g_divider};
	    if(diff[16]) begin
		qr = {qr[30:0], 1'b0};
		bit_num = bit_num - 1;
		end
		else begin
		qr = {diff[15:0], qr[14:0], 1'b1};
		bit_num = bit_num - 1;
		end
	  end
	end
end
		
	  

endmodule	