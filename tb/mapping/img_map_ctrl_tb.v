`include "rtl/mapping/img_map_ctrl.v"

module img_map_ctrl_tb;

  reg            clk;
  reg            reset;
  reg            enable;
  reg            div_sc_mem_wt_done;
  reg   [127:0]  inp_mem_rd_data1;
  reg   [127:0]  inp_mem_rd_data2;
  reg   [127:0]  sc_mem_rd_data1;
  reg   [127:0]  sc_mem_rd_data2;
  wire  [15:0]   inp_mem_rd_addr1;
  wire  [15:0]   inp_mem_rd_addr2;
  wire  [15:0]   sc_mem_rd_addr1;
  wire  [15:0]   sc_mem_rd_addr2;
  wire  [127:0]  out_mem_wt_data;
  wire  [15:0]   out_mem_wt_addr;
  wire           out_mem_wt_en;
  wire           output_wt_done;
  
  img_map_ctrl  mapping_unit1(
	.clk                   (clk),
	.reset                 (reset),
	.enable                (enable),
	.div_sc_mem_wt_done    (div_sc_mem_wt_done),
	.inp_mem_rd_data1      (inp_mem_rd_data1),
	.inp_mem_rd_data2      (inp_mem_rd_data2),
	.sc_mem_rd_data1       (sc_mem_rd_data1),
	.sc_mem_rd_data2       (sc_mem_rd_data2),
	.inp_mem_rd_addr1      (inp_mem_rd_addr1),
	.inp_mem_rd_addr2      (inp_mem_rd_addr2),
	.sc_mem_rd_addr1       (sc_mem_rd_addr1),
	.sc_mem_rd_addr2       (sc_mem_rd_addr2),
	.out_mem_wt_data       (out_mem_wt_data),
	.out_mem_wt_addr       (out_mem_wt_addr),
	.out_mem_wt_en         (out_mem_wt_en),
	.output_wt_done        (output_wt_done)
  );
  
  
  initial
  begin
  
  clk = 1;
  reset = 1;
  inp_mem_rd_data1 = 128'h0F_1F_2F_3F_4F_5F_6F_7F_8F_9F_AF_BF_CF_DF_EF_FF;
  inp_mem_rd_data2 = 128'h0F_1F_2F_3F_4F_5F_6F_7F_8F_9F_AF_BF_CF_DF_EF_FF;
  sc_mem_rd_data1  = 128'hFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF;
  sc_mem_rd_data2  = 128'h00000000_00000000_00000000_00000000;
  
  #15 reset = 0;
  #55 div_sc_mem_wt_done = 1;
  #10 div_sc_mem_wt_done = 0;
  
  
  end

  
  always 
  #5 clk = !clk;
  
  initial
  begin
  
  $dumpfile ("img_map_ctrl.vcd");
  $dumpvars;
  end
  
  initial
  #3000 $finish;
  
endmodule