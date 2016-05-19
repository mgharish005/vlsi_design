`include "rtl/divider/divider_top.v"
`include "rtl/memory.v"

module divider_top_tb;

  reg          clk;
  reg          reset;
  reg          enable;
  reg  [31:0]  cdf_min;
  wire [127:0] div_sc_mem_rd_data1;
  wire [127:0] div_sc_mem_rd_data2;
  wire [127:0] div_sc_mem_wt_data;
  wire [15:0]  div_sc_mem_rd_addr1;
  wire [15:0]  div_sc_mem_rd_addr2;
  wire [15:0]  div_sc_mem_wt_addr;
  wire         div_sc_mem_wt_en;
  wire         div_sc_mem_rd_done;
  wire         div_sc_mem_wt_done;
  
  divider_top  divider_top_1(
	.clk            	  (clk),
	.reset            	  (reset),
	.enable           	  (enable),
	.cdf_min              (cdf_min),
	.div_sc_mem_rd_data1  (div_sc_mem_rd_data1),
	.div_sc_mem_rd_data2  (div_sc_mem_rd_data2),
	.div_sc_mem_wt_data   (div_sc_mem_wt_data),
	.div_sc_mem_rd_addr1  (div_sc_mem_rd_addr1),
	.div_sc_mem_rd_addr2  (div_sc_mem_rd_addr2),
	.div_sc_mem_wt_addr   (div_sc_mem_wt_addr),
	.div_sc_mem_wt_en     (div_sc_mem_wt_en),
	.div_sc_mem_rd_done   (div_sc_mem_rd_done),
	.div_sc_mem_wt_done   (div_sc_mem_wt_done)
  );
  
  
  memory   scratch_mem(
    .clock            (clk),
    .WE               (div_sc_mem_wt_en),
    .WriteAddress     (div_sc_mem_wt_addr),
	.ReadAddress1     (div_sc_mem_rd_addr1),
    .ReadAddress2     (div_sc_mem_rd_addr2),
    .WriteBus         (div_sc_mem_wt_data),
    .ReadBus1         (div_sc_mem_rd_data1),
    .ReadBus2         (div_sc_mem_rd_data2)  
    ); 
	
	
  initial
  begin
  
  clk = 1;
  reset = 1;
  cdf_min = 32'd18;
  //div_sc_mem_rd_data1 = 128'h00000961000009610000096100000961;
  //div_sc_mem_rd_data2 = 128'h000012C1000012C1000012C1000012C1;
  enable = 0;
  #15 reset = 0;
  #100 enable = 1;
  #100 enable = 0;
  //#300 div_sc_mem_rd_data2 = 128'h00000961000009610000096100000961;
    //   div_sc_mem_rd_data1 = 128'h000012C1000012C1000012C1000012C1;
  
  end

  
  always 
  #5 clk = !clk;
  
  initial
  begin
  
  $dumpfile ("divider_top.vcd");
  $dumpvars;
  $readmemh("scratchmem_dump_for_divider.txt", scratch_mem.Register);  

  end
  
  initial
  #30000 $finish;
  
endmodule
