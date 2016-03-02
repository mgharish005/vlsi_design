`include "rtl/divider/binary_divider.v"

module binary_divider_tb;

  reg         clk;
  reg         reset;
  reg         enable;
  reg  [15:0] g_dividend_Q;
  reg  [15:0] g_divider_Q;
  wire [7:0]  quotient;
  wire        ready;
  
  binary_divider div_compute1 (
      .clk           (clk),
	  .reset         (reset),
	  .enable        (enable),
	  .g_dividend_Q  (g_dividend_Q),
	  .g_divider_Q   (g_divider_Q),
	  .quotient      (quotient),
	  .ready         (ready)
	  );
	  
  initial
  begin
  
  clk = 1;
  reset = 1;
  enable = 0;
  g_dividend_Q = 16'd765;
  g_divider_Q = 16'd63; 
  #5 reset = 0;
  #20 enable = 1;
  #160 enable = 0;
  end
  
  always 
  #5 clk = !clk;
  
  initial
  begin
  
  $dumpfile ("binary_divider.vcd");
  $dumpvars;
  end
  
  initial
  #800 $finish;
  
endmodule
  