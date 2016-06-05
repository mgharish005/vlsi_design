`include "rtl/dm/dm_top.v"
`include "rtl/memory.v"

module dm_top_tb();

  reg          clk;
  reg          reset;
  reg          enable;
  reg  [31:0]  cdf_min;
  wire [127:0] sc_mem_rd_data1;
  wire [127:0] sc_mem_rd_data2;
  wire [127:0] inp_mem_rd_data1;
  wire [127:0] inp_mem_rd_data2;
  wire [127:0] sc_mem_wt_data;
  wire [15:0]  sc_mem_rd_addr1;
  wire [15:0]  sc_mem_rd_addr2;
  wire [15:0]  sc_mem_wt_addr;
  wire         sc_mem_wt_en;
  wire [15:0]  inp_mem_rd_addr1;
  wire [15:0]  inp_mem_rd_addr2;
  wire [127:0] out_mem_wt_data;
  wire [15:0]  out_mem_wt_addr;
  wire         out_mem_wt_en;
  wire         output_wt_done;
  wire         div_sc_mem_rd_done;
  wire         div_sc_mem_wt_done;
  wire [15:0]  out_mem_rd_addr1;
  wire [15:0]  out_mem_rd_addr2;
  wire [127:0] out_mem_rd_data1;
  wire [127:0] out_mem_rd_data2;
  

  dm_top   dm_top_1(
    .clk            	  (clk),
	.reset            	  (reset),
	.enable           	  (enable),
	.cdf_min              (cdf_min),
	.sc_mem_rd_data1      (sc_mem_rd_data1),
	.sc_mem_rd_data2      (sc_mem_rd_data2),
	.inp_mem_rd_data1     (inp_mem_rd_data1),
	.inp_mem_rd_data2     (inp_mem_rd_data2),
	.sc_mem_wt_data       (sc_mem_wt_data),
	.sc_mem_rd_addr1      (sc_mem_rd_addr1),
	.sc_mem_rd_addr2      (sc_mem_rd_addr2),
	.sc_mem_wt_addr       (sc_mem_wt_addr),
	.sc_mem_wt_en         (sc_mem_wt_en),
	.inp_mem_rd_addr1     (inp_mem_rd_addr1),
	.inp_mem_rd_addr2     (inp_mem_rd_addr2),
	.out_mem_wt_data      (out_mem_wt_data),
	.out_mem_wt_addr      (out_mem_wt_addr),
	.out_mem_wt_en        (out_mem_wt_en),
	.output_wt_done       (output_wt_done),
	.div_sc_mem_rd_done   (div_sc_mem_rd_done),
	.div_sc_mem_wt_done   (div_sc_mem_wt_done)
	);
    
  memory   scratch_mem(
    .clock            (clk),
    .WE               (sc_mem_wt_en),
    .WriteAddress     (sc_mem_wt_addr),
	.ReadAddress1     (sc_mem_rd_addr1),
    .ReadAddress2     (sc_mem_rd_addr2),
    .WriteBus         (sc_mem_wt_data),
    .ReadBus1         (sc_mem_rd_data1),
    .ReadBus2         (sc_mem_rd_data2)  
    ); 
	
  memory   input_mem(
    .clock            (clk),
    .WE               (1'b0),
    .WriteAddress     (16'b0),
	.ReadAddress1     (inp_mem_rd_addr1),
    .ReadAddress2     (inp_mem_rd_addr2),
    .WriteBus         (128'b0),
    .ReadBus1         (inp_mem_rd_data1),
    .ReadBus2         (inp_mem_rd_data2)  
    ); 
	
  memory   output_mem(
    .clock            (clk),
    .WE               (out_mem_wt_en),
    .WriteAddress     (out_mem_wt_addr),
	.ReadAddress1     (out_mem_rd_addr1),
    .ReadAddress2     (out_mem_rd_addr2),
    .WriteBus         (out_mem_wt_data),
    .ReadBus1         (out_mem_rd_data1),
    .ReadBus2         (out_mem_rd_data2)  
    ); 
	
	
	
  initial
  begin
    
  $dumpfile ("dm.vcd");
  $dumpvars;
  $readmemh("input_image.txt", input_mem.Register);
  $readmemh("scratchmem_dump_for_divider.txt", scratch_mem.Register);  
  
  
  clk = 1;
  reset = 1;
  cdf_min = 32'd18;
  
  enable = 0;
  #15 reset = 0;
  #100 enable = 1;
  #100 enable = 0;

  
  #60000 $finish;

  end
   
  
  always 
  #5 clk = !clk;

  
endmodule