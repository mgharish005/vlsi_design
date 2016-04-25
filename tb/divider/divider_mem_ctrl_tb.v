`include "rtl/divider/divider_mem_ctrl.v"

module divider_mem_ctrl_tb ;

  reg         clk;
  reg         reset;
  reg         enable;
  reg         div_done;
  wire [15:0] sc_mem_rd_addr1;
  wire [15:0] sc_mem_rd_addr2;
  wire [15:0] sc_mem_wt_addr;
  wire        sc_mem_rd_data_rdy;
  wire        sc_mem_wt_en;
  wire        sc_mem_rd_done;
  wire        sc_mem_wt_done;
  

divider_mem_ctrl d_memctrl1(
  .clk              	  (clk),
  .reset            	  (reset),
  .enable           	  (enable),
  .div_done         	  (div_done),
  .sc_mem_rd_addr1  	  (sc_mem_rd_addr1),
  .sc_mem_rd_addr2  	  (sc_mem_rd_addr2),
  .sc_mem_wt_addr   	  (sc_mem_wt_addr),
  .sc_mem_rd_done         (sc_mem_rd_done),
  .sc_mem_wt_done         (sc_mem_wt_done),
  .sc_mem_rd_data_rdy     (sc_mem_rd_data_rdy),
  .sc_mem_wt_en     	  (sc_mem_wt_en)
  );
  
  initial
  begin
  
  clk = 1;
  reset = 1;
  div_done = 0;
  enable = 0;
  #5 reset = 0;
  #5 enable = 1;
  #10 enable = 0;
  end
  
  //Toggle divider_done to test reading
  //of all cdf values from scratch
  always
  #10 div_done = ~div_done;
  
  always 
  #5 clk = !clk;
  
  initial
  begin
  
  $dumpfile ("divider_mem_ctrl.vcd");
  $dumpvars;
  end
  
  initial
  #3000 $finish;
  
endmodule
  
  

  