`include "rtl/divider/divider.v"

module divider_tb ;

  reg         clk;
  reg         reset;
  reg         enable;
  reg         div_en;
  reg  [31:0] cdf_in;
  wire [31:0] g_out;
  wire        ready_g_out;
  
  divider d1(
  .clk           (clk),
  .reset         (reset),
  .enable        (enable),
  .div_en        (div_en),
  .cdf_in        (cdf_in),
  .g_out         (g_out),
  .ready_g_out   (ready_g_out)
  );
  
  initial
  begin
  
  clk = 1;
  reset = 1;
  div_en = 0;
  cdf_in = 32'd1;
  #5 reset = 0;
  #25 div_en = 1;
  #10 div_en = 0;
  #10 cdf_in = 32'd4;
  #40 cdf_in = 32'd60;
  end
  
  always 
  #5 clk = !clk;
  
  initial
  begin
  
  $dumpfile ("divider.vcd");
  $dumpvars;
  end
  
  initial
  #80000 $finish;
  
endmodule
  
  