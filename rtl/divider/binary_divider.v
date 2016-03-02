`include "rtl/divider/D_FLOP_1REG.v"

module  binary_divider(
input  wire         clk,
input  wire         reset,
input  wire         enable,
input  wire [15:0]  g_dividend_Q,
input  wire [15:0]  g_divider_Q,
output reg  [7:0]   quotient,
output reg          ready
);

reg   [31:0]   qr;
reg   [16:0]   diff;
reg   [4:0]    bit_cnt;
reg            first_cycle;
wire           enable_D1;

  D_FLOP_1REG dff1A(
         .clk        (clk),
         .reset      (reset),
         .D          (enable),
         .Q          (enable_D1)
  );
  
//Reset logic and Determine first cycle of division calc  
always @(posedge clk) begin
  
  if(reset) begin
    bit_cnt <= 5'd0;
	quotient <= 8'd0;
	qr <= 32'd0;
	diff <= 17'd0;
	ready <= 1'b0;
	first_cycle <= 1'b0;
  end
  else begin
    if(enable && ~enable_D1) begin
	  bit_cnt <= 5'd16;
	  qr <= {16'd0, g_dividend_Q[15:0]};
	  first_cycle <= 1'b1;
	end
	else first_cycle <= 1'b0;
  end 
  
end

//Mux to compute Difference every cycle divider is on
always @(posedge clk) begin
  if (first_cycle || enable_D1) begin
    diff <= (qr[31:15] - {1'b0, g_divider_Q[15:0]});
  end
  else diff <= 17'd0;
end


endmodule
	