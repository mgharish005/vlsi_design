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
  wire [15:0]  out_mem_rd_addr1;
  wire [15:0]  out_mem_rd_addr2;
  wire [127:0] out_mem_rd_data1;
  wire [127:0] out_mem_rd_data2;
  
  integer      div_wtdata_file;
  integer      out_wtdata_file;
  integer      div_scan_file;
  integer      out_scan_file;
  reg  [127:0] c_model_div_wdata; 
  reg  [127:0] c_model_out_wdata;

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
	.output_wt_done       (output_wt_done)
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

  div_wtdata_file = $fopen("divider_scratch_wdata.txt", "r"); 
  out_wtdata_file = $fopen("divider_output_wdata.txt", "r"); 
  $dumpfile ("dm.vcd");
  $dumpvars;
  $readmemh("input_image.txt", input_mem.Register);
  $readmemh("scratchmem_dump_for_divider.txt", scratch_mem.Register);  
  
  
  clk = 1;
  reset = 1;
  cdf_min = 32'd18;
  c_model_div_wdata = 128'd0;
  c_model_out_wdata = 128'd0;

  
  enable = 0;
  #15 reset = 0;
  #100 enable = 1;
  #100 enable = 0;

  
  #60000 $finish;

  end

  //Check Divider Write Data Every Write Enable
  always@(posedge sc_mem_wt_en)
  begin
	div_scan_file = $fscanf(div_wtdata_file, "%h\n", c_model_div_wdata) ;  

    if(!$feof(div_wtdata_file)) 
    begin
	  if ((sc_mem_wt_data[127:96] != (c_model_div_wdata[127:96])) &
	      (sc_mem_wt_data[127:96] != (c_model_div_wdata[127:96] + 32'd1)) & 
		  (sc_mem_wt_data[127:96] != (c_model_div_wdata[127:96] - 32'd1)) ) begin
	    $display("Mismatch sc_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, sc_mem_wt_data[127:96], c_model_div_wdata[127:96]); 
      end
	  if ((sc_mem_wt_data[95:64] != (c_model_div_wdata[95:64])) &
	      (sc_mem_wt_data[95:64] != (c_model_div_wdata[95:64] + 32'd1)) & 
		  (sc_mem_wt_data[95:64] != (c_model_div_wdata[95:64] - 32'd1)) ) begin
	    $display("Mismatch sc_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, sc_mem_wt_data[95:64], c_model_div_wdata[95:64]); 
      end
	  if ((sc_mem_wt_data[63:32] != (c_model_div_wdata[63:32])) & 
	      (sc_mem_wt_data[63:32] != (c_model_div_wdata[63:32] + 32'd1)) &
		  (sc_mem_wt_data[63:32] != (c_model_div_wdata[63:32] - 32'd1)) ) begin
	    $display("Mismatch sc_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, sc_mem_wt_data[63:32], c_model_div_wdata[63:32]); 
	  end
	  if ((sc_mem_wt_data[31:0] != (c_model_div_wdata[31:0])) & 
	      (sc_mem_wt_data[31:0] != (c_model_div_wdata[31:0] + 32'd1)) & 
		  (sc_mem_wt_data[31:0] != (c_model_div_wdata[31:0] - 32'd1)) ) begin
	    $display("Mismatch sc_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, sc_mem_wt_data[31:0], c_model_div_wdata[31:0]); 
	  end
    end
  end
  
  
  //Check Output Write Data Every Write Enable
  always@(posedge out_mem_wt_en)
  begin
	out_scan_file = $fscanf(out_wtdata_file, "%h\n", c_model_out_wdata) ;  

    if(!$feof(out_wtdata_file)) 
    begin
	  if ((out_mem_wt_data[127:120] != (c_model_out_wdata[127:120])) &
	      (out_mem_wt_data[127:120] != (c_model_out_wdata[127:120] + 8'd1)) & 
		  (out_mem_wt_data[127:120] != (c_model_out_wdata[127:120] - 8'd1)) ) begin
	    $display("Mismatch out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, out_mem_wt_data[127:120], c_model_out_wdata[127:120]); 
      end
	  if ((out_mem_wt_data[119:112] != (c_model_out_wdata[119:112])) &
	      (out_mem_wt_data[119:112] != (c_model_out_wdata[119:112] + 8'd1)) & 
		  (out_mem_wt_data[119:112] != (c_model_out_wdata[119:112] - 8'd1)) ) begin
	    $display("Mismatch out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, out_mem_wt_data[119:112], c_model_out_wdata[119:112]); 
      end
	  if ((out_mem_wt_data[111:104] != (c_model_out_wdata[111:104])) &
	      (out_mem_wt_data[111:104] != (c_model_out_wdata[111:104] + 8'd1)) & 
		  (out_mem_wt_data[111:104] != (c_model_out_wdata[111:104] - 8'd1)) ) begin
	    $display("Mismatch out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, out_mem_wt_data[111:104], c_model_out_wdata[111:104]); 
      end
	  if ((out_mem_wt_data[103:96] != (c_model_out_wdata[103:96])) &
	      (out_mem_wt_data[103:96] != (c_model_out_wdata[103:96] + 8'd1)) & 
		  (out_mem_wt_data[103:96] != (c_model_out_wdata[103:96] - 8'd1)) ) begin
	    $display("Mismatch out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, out_mem_wt_data[103:96], c_model_out_wdata[103:96]); 
      end
	  if ((out_mem_wt_data[95:88] != (c_model_out_wdata[95:88])) &
	      (out_mem_wt_data[95:88] != (c_model_out_wdata[95:88] + 8'd1)) & 
		  (out_mem_wt_data[95:88] != (c_model_out_wdata[95:88] - 8'd1)) ) begin
	    $display("Mismatch out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, out_mem_wt_data[95:88], c_model_out_wdata[95:88]); 
      end
	  if ((out_mem_wt_data[87:80] != (c_model_out_wdata[87:80])) &
	      (out_mem_wt_data[87:80] != (c_model_out_wdata[87:80] + 8'd1)) & 
		  (out_mem_wt_data[87:80] != (c_model_out_wdata[87:80] - 8'd1)) ) begin
	    $display("Mismatch out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, out_mem_wt_data[87:80], c_model_out_wdata[87:80]); 
      end
	  if ((out_mem_wt_data[79:72] != (c_model_out_wdata[79:72])) &
	      (out_mem_wt_data[79:72] != (c_model_out_wdata[79:72] + 8'd1)) & 
		  (out_mem_wt_data[79:72] != (c_model_out_wdata[79:72] - 8'd1)) ) begin
	    $display("Mismatch out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, out_mem_wt_data[79:72], c_model_out_wdata[79:72]); 
      end
	  if ((out_mem_wt_data[71:64] != (c_model_out_wdata[71:64])) &
	      (out_mem_wt_data[71:64] != (c_model_out_wdata[71:64] + 8'd1)) & 
		  (out_mem_wt_data[71:64] != (c_model_out_wdata[71:64] - 8'd1)) ) begin
	    $display("Mismatch out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, out_mem_wt_data[71:64], c_model_out_wdata[71:64]); 
      end
	  if ((out_mem_wt_data[63:56] != (c_model_out_wdata[63:56])) & 
	      (out_mem_wt_data[63:56] != (c_model_out_wdata[63:56] + 8'd1)) &
		  (out_mem_wt_data[63:56] != (c_model_out_wdata[63:56] - 8'd1)) ) begin
	    $display("Mismatch out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, out_mem_wt_data[63:56], c_model_out_wdata[63:56]); 
	  end
	  if ((out_mem_wt_data[55:48] != (c_model_out_wdata[55:48])) & 
	      (out_mem_wt_data[55:48] != (c_model_out_wdata[55:48] + 8'd1)) &
		  (out_mem_wt_data[55:48] != (c_model_out_wdata[55:48] - 8'd1)) ) begin
	    $display("Mismatch out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, out_mem_wt_data[55:48], c_model_out_wdata[55:48]); 
	  end
	  if ((out_mem_wt_data[47:40] != (c_model_out_wdata[47:40])) & 
	      (out_mem_wt_data[47:40] != (c_model_out_wdata[47:40] + 8'd1)) &
		  (out_mem_wt_data[47:40] != (c_model_out_wdata[47:40] - 8'd1)) ) begin
	    $display("Mismatch out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, out_mem_wt_data[47:40], c_model_out_wdata[47:40]); 
	  end
	  if ((out_mem_wt_data[39:32] != (c_model_out_wdata[39:32])) & 
	      (out_mem_wt_data[39:32] != (c_model_out_wdata[39:32] + 8'd1)) &
		  (out_mem_wt_data[39:32] != (c_model_out_wdata[39:32] - 8'd1)) ) begin
	    $display("Mismatch out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, out_mem_wt_data[39:32], c_model_out_wdata[39:32]); 
	  end
	  if ((out_mem_wt_data[31:24] != (c_model_out_wdata[31:24])) & 
	      (out_mem_wt_data[31:24] != (c_model_out_wdata[31:24] + 8'd1)) & 
		  (out_mem_wt_data[31:24] != (c_model_out_wdata[31:24] - 8'd1)) ) begin
	    $display("Mismatch out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, out_mem_wt_data[31:24], c_model_out_wdata[31:24]); 
	  end
	  if ((out_mem_wt_data[23:16] != (c_model_out_wdata[23:16])) & 
	      (out_mem_wt_data[23:16] != (c_model_out_wdata[23:16] + 8'd1)) & 
		  (out_mem_wt_data[23:16] != (c_model_out_wdata[23:16] - 8'd1)) ) begin
	    $display("Mismatch out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, out_mem_wt_data[23:16], c_model_out_wdata[23:16]); 
	  end
	  if ((out_mem_wt_data[15:8] != (c_model_out_wdata[15:8])) & 
	      (out_mem_wt_data[15:8] != (c_model_out_wdata[15:8] + 8'd1)) & 
		  (out_mem_wt_data[15:8] != (c_model_out_wdata[15:8] - 8'd1)) ) begin
	    $display("Mismatch out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, out_mem_wt_data[15:8], c_model_out_wdata[15:8]); 
	  end
	  if ((out_mem_wt_data[7:0] != (c_model_out_wdata[7:0])) & 
	      (out_mem_wt_data[7:0] != (c_model_out_wdata[7:0] + 8'd1)) & 
		  (out_mem_wt_data[7:0] != (c_model_out_wdata[7:0] - 8'd1)) ) begin
	    $display("Mismatch out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, out_mem_wt_data[7:0], c_model_out_wdata[7:0]); 
	  end
    end
  end
  
  
  always 
  #5 clk = !clk;

  
endmodule