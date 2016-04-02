`include "rtl/divider/divider.v"

module divider_tb ;

  reg        clk;
  reg        reset;
  reg        enable;
  reg  [7:0] cdf_in;
  wire [7:0] g_out;
  wire       ready_g_out;
  
  divider d1(
  .clk           (clk),
  .reset         (reset),
  .enable        (enable),
  .cdf_in        (cdf_in),
  .g_out         (g_out),
  .ready_g_out   (ready_g_out)
  );
  
  initial
  begin
  
  clk = 1;
  reset = 1;
  enable = 0;
  cdf_in = 8'd1;
  #5 reset = 0;
  #25 enable = 1;
  #10 enable = 0;
  #10 cdf_in = 8'd4;
  end
  
  always 
  #5 clk = !clk;
  
  initial
  begin
  
  $dumpfile ("divider.vcd");
  $dumpvars;
  end
  
  initial
  #800 $finish;
  
endmodule
  
  