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
  wire         div_InProgress;
  
  integer      div_wtdata_file;
  integer      scan_file;
  reg  [127:0] c_model_wdata; 

  
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
	.div_sc_mem_wt_done   (div_sc_mem_wt_done),
	.div_InProgress       (div_InProgress)
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
    
  div_wtdata_file = $fopen("divider_scratch_wdata.txt", "r"); 
  $dumpfile ("divider_top.vcd");
  $dumpvars;
  $readmemh("scratchmem_dump_for_divider.txt", scratch_mem.Register);  
  
  
  clk = 1;
  reset = 1;
  cdf_min = 32'd18;
  c_model_wdata = 128'd0;

  enable = 0;
  #15 reset = 0;
  #100 enable = 1;
  #100 enable = 0;

  
  #30000 $finish;

  end
  
  //Check Write Data Every Write Enable
  always@(posedge div_sc_mem_wt_en)
  begin
	scan_file = $fscanf(div_wtdata_file, "%h\n", c_model_wdata) ;  

    if(!$feof(div_wtdata_file)) 
    begin
	  if ((div_sc_mem_wt_data[127:96] != (c_model_wdata[127:96])) &
	      (div_sc_mem_wt_data[127:96] != (c_model_wdata[127:96] + 32'd1)) & 
		  (div_sc_mem_wt_data[127:96] != (c_model_wdata[127:96] - 32'd1)) ) begin
	    $display("Mismatch div_sc_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, div_sc_mem_wt_data[127:96], c_model_wdata[127:96]); 
      end
	  if ((div_sc_mem_wt_data[95:64] != (c_model_wdata[95:64])) &
	      (div_sc_mem_wt_data[95:64] != (c_model_wdata[95:64] + 32'd1)) & 
		  (div_sc_mem_wt_data[95:64] != (c_model_wdata[95:64] - 32'd1)) ) begin
	    $display("Mismatch div_sc_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, div_sc_mem_wt_data[95:64], c_model_wdata[95:64]); 
      end
	  if ((div_sc_mem_wt_data[63:32] != (c_model_wdata[63:32])) & 
	      (div_sc_mem_wt_data[63:32] != (c_model_wdata[63:32] + 32'd1)) &
		  (div_sc_mem_wt_data[63:32] != (c_model_wdata[63:32] - 32'd1)) ) begin
	    $display("Mismatch div_sc_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, div_sc_mem_wt_data[63:32], c_model_wdata[63:32]); 
	  end
	  if ((div_sc_mem_wt_data[31:0] != (c_model_wdata[31:0])) & 
	      (div_sc_mem_wt_data[31:0] != (c_model_wdata[31:0] + 32'd1)) & 
		  (div_sc_mem_wt_data[31:0] != (c_model_wdata[31:0] - 32'd1)) ) begin
	    $display("Mismatch div_sc_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, div_sc_mem_wt_data[31:0], c_model_wdata[31:0]); 
	  end
    end
  end
  
  
  always 
  #5 clk = !clk;

  
endmodule
