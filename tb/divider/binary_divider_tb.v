`include "rtl/divider/binary_divider.v"

module binary_divider_tb;

  reg         clk;
  reg         reset;
  reg         div_en;
  reg  [63:0] g_dividend_Q;
  reg  [63:0] g_divider_Q;
  wire [31:0] quotient;
  wire        done;
  
  binary_divider div_compute1 (
      .clk           (clk),
	  .reset         (reset),
	  .div_en        (div_en),
	  .g_dividend_Q  (g_dividend_Q),
	  .g_divider_Q   (g_divider_Q),
	  .quotient      (quotient),
	  .done          (done)
	  );
	  
  initial
  begin
  
  clk = 1;
  reset = 1;
  div_en = 0;
  g_dividend_Q = 64'd765;
  g_divider_Q = 64'd63; 
  #10 reset = 0;
  #20 div_en = 1;
  #10 div_en = 0;

  

  end
  
  always 
  #5 clk = !clk;
  
  initial
  begin
  
  $dumpfile ("binary_divider.vcd");
  $dumpvars;
  end
  
  initial
  #80000 $finish;
  
endmodule
  