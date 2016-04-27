`include "rtl/divider/divider_mem_datapath.v"

module divider_mem_datapath_tb ;

  reg         clk;
  reg         reset;
  reg         enable;
  reg         sc_mem_rd_data_rdy;
  reg [127:0] sc_mem_rd_data1;
  reg [127:0] sc_mem_rd_data2;
  wire [31:0] cdfval_todiv1;
  wire [31:0] cdfval_todiv2;
  wire [31:0] cdfval_todiv3;
  wire [31:0] cdfval_todiv4;
  wire [31:0] cdfval_todiv5;
  wire [31:0] cdfval_todiv6;
  wire [31:0] cdfval_todiv7;
  wire [31:0] cdfval_todiv8;
  
divider_mem_datapath d_memdp1(
  .clk              	  (clk),
  .reset            	  (reset),
  .enable           	  (enable),
  .sc_mem_rd_data_rdy     (sc_mem_rd_data_rdy),
  .sc_mem_rd_data1        (sc_mem_rd_data1),
  .sc_mem_rd_data2        (sc_mem_rd_data2),
  .cdfval_todiv1          (cdfval_todiv1),
  .cdfval_todiv2          (cdfval_todiv2),
  .cdfval_todiv3          (cdfval_todiv3),
  .cdfval_todiv4          (cdfval_todiv4),
  .cdfval_todiv5          (cdfval_todiv5),
  .cdfval_todiv6          (cdfval_todiv6),
  .cdfval_todiv7          (cdfval_todiv7),
  .cdfval_todiv8          (cdfval_todiv8)
  );
  
  
  initial
  begin
  
  clk = 1;
  reset = 1;
  enable = 0;
  sc_mem_rd_data_rdy = 1'b0;
  sc_mem_rd_data1 = 32'd32;
  sc_mem_rd_data2 = 32'd33;
  #5 reset = 0;
  #5 sc_mem_rd_data_rdy = 1'b1;
  #10 sc_mem_rd_data_rdy  = 1'b0;
  #10 sc_mem_rd_data1 = 32'd64;
  sc_mem_rd_data2 = 32'd65;
  #5 sc_mem_rd_data_rdy = 1'b1;
  #10 sc_mem_rd_data_rdy = 1'b0;
  end

  
  always 
  #5 clk = !clk;
  
  initial
  begin
  
  $dumpfile ("divider_mem_datapath.vcd");
  $dumpvars;
  end
  
  initial
  #3000 $finish;
  
endmodule
  

