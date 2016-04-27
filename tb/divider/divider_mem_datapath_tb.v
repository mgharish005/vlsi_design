`include "rtl/divider/divider_mem_datapath.v"

module divider_mem_datapath_tb ;

  reg          clk;
  reg          reset;
  reg          enable;
  reg          sc_mem_rd_data_rdy;
  reg [127:0]  sc_mem_rd_data1;
  reg [127:0]  sc_mem_rd_data2;
  reg          div1_done;
  reg          div2_done;
  reg          div3_done;
  reg          div4_done;
  reg          div5_done;
  reg          div6_done;
  reg          div7_done;
  reg          div8_done;
  reg  [31:0]  div1_value;
  reg  [31:0]  div2_value;
  reg  [31:0]  div3_value;
  reg  [31:0]  div4_value;
  reg  [31:0]  div5_value;
  reg  [31:0]  div6_value;
  reg  [31:0]  div7_value;
  reg  [31:0]  div8_value;
  wire [31:0]  cdfval_todiv1;
  wire [31:0]  cdfval_todiv2;
  wire [31:0]  cdfval_todiv3;
  wire [31:0]  cdfval_todiv4;
  wire [31:0]  cdfval_todiv5;
  wire [31:0]  cdfval_todiv6;
  wire [31:0]  cdfval_todiv7;
  wire [31:0]  cdfval_todiv8;
  wire [127:0] sc_mem_wt_data; 
  
divider_mem_datapath d_memdp1(
  .clk              	  (clk),
  .reset            	  (reset),
  .enable           	  (enable),
  .sc_mem_rd_data_rdy     (sc_mem_rd_data_rdy),
  .sc_mem_rd_data1        (sc_mem_rd_data1),
  .sc_mem_rd_data2        (sc_mem_rd_data2),
  .div1_done              (div1_done),
  .div2_done              (div2_done),
  .div3_done              (div3_done),
  .div4_done              (div4_done),
  .div5_done              (div5_done),
  .div6_done              (div6_done),
  .div7_done              (div7_done),
  .div8_done              (div8_done),
  .div1_value             (div1_value),
  .div2_value             (div2_value),
  .div3_value             (div3_value),
  .div4_value             (div4_value),
  .div5_value             (div5_value),
  .div6_value             (div6_value),
  .div7_value             (div7_value),
  .div8_value             (div8_value),
  .cdfval_todiv1          (cdfval_todiv1),
  .cdfval_todiv2          (cdfval_todiv2),
  .cdfval_todiv3          (cdfval_todiv3),
  .cdfval_todiv4          (cdfval_todiv4),
  .cdfval_todiv5          (cdfval_todiv5),
  .cdfval_todiv6          (cdfval_todiv6),
  .cdfval_todiv7          (cdfval_todiv7),
  .cdfval_todiv8          (cdfval_todiv8),
  .sc_mem_wt_data         (sc_mem_wt_data)
  );
  
  
  initial
  begin
  
  clk = 1;
  reset = 1;
  enable = 0;
  sc_mem_rd_data_rdy = 1'b0;
  sc_mem_rd_data1 = 32'd32;
  sc_mem_rd_data2 = 32'd33;
  div1_done = 1'b0;
  div2_done = 1'b0;
  div3_done = 1'b0;
  div4_done = 1'b0;
  div5_done = 1'b0;
  div6_done = 1'b0;
  div7_done = 1'b0;
  div8_done = 1'b0;
  div1_value = 32'd1;
  div2_value = 32'd1;
  div3_value = 32'd1;
  div4_value = 32'd1;
  div5_value = 32'd1;
  div6_value = 32'd1;
  div7_value = 32'd1;
  div8_value = 32'd1;
  #5 reset = 0;
  #5 sc_mem_rd_data_rdy = 1'b1;
  #10 sc_mem_rd_data_rdy  = 1'b0;
  #10 sc_mem_rd_data1 = 32'd64;
  sc_mem_rd_data2 = 32'd65;
  #5 sc_mem_rd_data_rdy = 1'b1;
  #10 sc_mem_rd_data_rdy = 1'b0;
  #30 div1_done = 1'b1;
  div2_done = 1'b1;
  div3_done = 1'b1;
  div4_done = 1'b1;
  div5_done = 1'b1;
  div6_done = 1'b1;
  div7_done = 1'b1;
  div8_done = 1'b1;
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
  

