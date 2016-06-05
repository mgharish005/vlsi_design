`include "rtl/mapping/img_map_ctrl.v"
`include "rtl/divider/divider_top.v"

module dm_top(
input  wire         clk,
input  wire         reset,
input  wire         enable,
input  wire [31:0]  cdf_min,
input  wire [127:0] sc_mem_rd_data1,
input  wire [127:0] sc_mem_rd_data2,
input  wire [127:0] inp_mem_rd_data1,
input  wire [127:0] inp_mem_rd_data2,
output wire [127:0] sc_mem_wt_data,
output wire [15:0]  sc_mem_rd_addr1,
output wire [15:0]  sc_mem_rd_addr2,
output wire [15:0]  sc_mem_wt_addr,
output wire         sc_mem_wt_en,
output wire [15:0]  inp_mem_rd_addr1,
output wire [15:0]  inp_mem_rd_addr2,
output wire [127:0] out_mem_wt_data,
output wire [15:0]  out_mem_wt_addr,
output wire         out_mem_wt_en,
output wire         output_wt_done,
output wire         div_sc_mem_rd_done,
output wire         div_sc_mem_wt_done
);


wire          div_InProgress;
wire          mapping_InProgress;
wire  [15:0]  div_sc_mem_rd_addr1;
wire  [15:0]  div_sc_mem_rd_addr2;
wire  [15:0]  map_sc_mem_rd_addr1;
wire  [15:0]  map_sc_mem_rd_addr2;

assign   sc_mem_rd_addr1   =  (div_InProgress) ? div_sc_mem_rd_addr1 : map_sc_mem_rd_addr1;
assign   sc_mem_rd_addr2   =  (div_InProgress) ? div_sc_mem_rd_addr2 : map_sc_mem_rd_addr2;

  divider_top  divider_top_1(
	.clk            	  (clk),
	.reset            	  (reset),
	.enable           	  (enable),
	.cdf_min              (cdf_min),
	.div_sc_mem_rd_data1  (sc_mem_rd_data1),
	.div_sc_mem_rd_data2  (sc_mem_rd_data2),
	.div_sc_mem_wt_data   (sc_mem_wt_data),
	.div_sc_mem_rd_addr1  (div_sc_mem_rd_addr1),
	.div_sc_mem_rd_addr2  (div_sc_mem_rd_addr2),
	.div_sc_mem_wt_addr   (sc_mem_wt_addr),
	.div_sc_mem_wt_en     (sc_mem_wt_en),
	.div_sc_mem_rd_done   (div_sc_mem_rd_done),
	.div_sc_mem_wt_done   (div_sc_mem_wt_done),
	.div_InProgress       (div_InProgress)
  );
  
  img_map_ctrl  mapping_unit_1(
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
	.map_sc_mem_rd_addr1   (map_sc_mem_rd_addr1),
	.map_sc_mem_rd_addr2   (map_sc_mem_rd_addr2),
	.out_mem_wt_data       (out_mem_wt_data),
	.out_mem_wt_addr       (out_mem_wt_addr),
	.out_mem_wt_en         (out_mem_wt_en),
	.output_wt_done        (output_wt_done),
	.mapping_InProgress    (mapping_InProgress)
  );
  
  endmodule