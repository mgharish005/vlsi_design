
//top level
`include "../../rtl/top.v"
`include "../../rtl/top_without_mem.v"
`include "../../rtl/memory.v"
`include "../../rtl/top_level_control.v"
`include "../../rtl/mem_controller.v"
`include "../../rtl/histogram_equalizer_core.v"
`include "../../rtl/histogram/histogram_data_path.v"
`include "../../rtl/histogram/histogram_control.v"
`include "../../rtl/cdf/cdf_control.v"
`include "../../rtl/cdf/cdf_datapath.v"
`include "../../rtl/dm/dm_top.v"



//`timescale 1 ns/ 100 ps
module top_tb; 

    reg clock , reset;
    reg new_image_pulse; 
    reg [16:0] input_mem_depth, scratch_mem_depth, output_mem_depth; 
    integer wdata_file; 
    integer waddr_file; 
	integer div_wtdata_file;
    integer out_wtdata_file;
	integer div_scan_file;
    integer out_scan_file;
    reg [127:0] c_model_div_wdata; 
    reg [127:0] c_model_out_wdata;
    integer scan_file1 ,scan_file2; 
    integer c_model_waddr; 
    reg [31:0] c_model_wdata[0:3]; 

    initial
    begin
        waddr_file = $fopen("hist_scratch_waddr.txt", "r"); 
        wdata_file = $fopen("hist_scratch_wdata.txt", "r"); 
	div_wtdata_file = $fopen("divider_scratch_wdata.txt", "r"); 
        out_wtdata_file = $fopen("divider_output_wdata.txt", "r"); 
        $dumpfile("top_tb.vcd"); 
        $dumpvars(0, top_tb) ;
        $readmemh("input_image.txt", top_u0.input_memory_u0.Register);  

        clock = 1; 
        reset = 1; 
        c_model_wdata[0] = 32'b0; 
        c_model_wdata[1] = 32'b0; 
        c_model_wdata[2] = 32'b0; 
        c_model_wdata[3] = 32'b0; 
		c_model_div_wdata = 128'd0;
        c_model_out_wdata = 128'd0;

        input_mem_depth = 1<<7; //To shorten sim time modify this. For Ex : "1<<4" makes it parse lesser lines
        scratch_mem_depth = 1<<7; 
        output_mem_depth = 1<<7; 
        //sequence
        #30 reset = 0 ;
        #10 new_image_pulse = 1; 
        #20 new_image_pulse = 0; 

		@(posedge top_u0.top_without_mem_u0.histogram_equalizer_core_u0.start_divider) $dumpvars(0, top_tb);
        @(posedge top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.output_wt_done)  $finish;
    end
    
    top top_u0
    (
        .clock(clock),
        .reset(reset), 
        .input_mem_depth(input_mem_depth),
        .scratch_mem_depth(scratch_mem_depth),
        .output_mem_depth(output_mem_depth),
        .new_image_pulse(new_image_pulse)
    ); 
  /* Make a regular pulsing clock. */
  always #5 clock = !clock;


  always@(posedge top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.write_enable)
  begin
    #2; 
    //read from file and compare the write address and wdata
    scan_file1 = $fscanf(waddr_file, "%d\n", c_model_waddr) ;  
    scan_file2 = $fscanf(wdata_file, "%032x%032x%032x%032x\n", c_model_wdata[3], c_model_wdata[2], c_model_wdata[1], c_model_wdata[0]) ;  

 // $display("[checker] wdata from pli = %x", c_model_wdata[3]); 
 // $display("[checker] wdata from pli = %x", c_model_wdata[2]); 
 // $display("[checker] wdata from pli = %x", c_model_wdata[1]); 
 // $display("[checker] wdata from pli = %x", c_model_wdata[0]); 


    if(!$feof(waddr_file)) 
    begin
        if(top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.write_address != c_model_waddr)
                $display("Mismatch hist_scratch_waddr @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.write_address, c_model_waddr); 
//      else
//              $display("Match hist_scratch_waddr @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.write_address, c_model_waddr); 
    end

    if(!$feof(wdata_file)) 
    begin
        if(top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.wdata[127:96] != c_model_wdata[3])
                $display("Mismatch hist_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.wdata[127:96], c_model_wdata[3]); 
//      else
//              $display("Match hist_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.wdata[127:96], c_model_wdata[3]); 
        
        if(top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.wdata[95:64] != c_model_wdata[2])
                $display("Mismatch hist_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.wdata[95:64], c_model_wdata[2]); 
//      else
//              $display("Match hist_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.wdata[95:64], c_model_wdata[2]); 

        if(top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.wdata[63:32] != c_model_wdata[1])
                $display("Mismatch hist_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.wdata[63:32], c_model_wdata[1]); 
//      else
//              $display("Match hist_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.wdata[63:32], c_model_wdata[1]); 

        if(top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.wdata[31:0] != c_model_wdata[0])
                $display("Mismatch hist_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.wdata[31:0], c_model_wdata[0]); 
//      else
//              $display("Match hist_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.wdata[31:0], c_model_wdata[0]); 
    end

  end

  
  //Check Divider Write Data Every Write Enable
  always@(posedge top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_en)
  begin
	div_scan_file = $fscanf(div_wtdata_file, "%h\n", c_model_div_wdata) ;  

    if(!$feof(div_wtdata_file)) 
    begin
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data[127:96] != (c_model_div_wdata[127:96])) &
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data[127:96] != (c_model_div_wdata[127:96] + 32'd1)) & 
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data[127:96] != (c_model_div_wdata[127:96] - 32'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data[127:96], c_model_div_wdata[127:96]); 
      end
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data[95:64] != (c_model_div_wdata[95:64])) &
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data[95:64] != (c_model_div_wdata[95:64] + 32'd1)) & 
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data[95:64] != (c_model_div_wdata[95:64] - 32'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data[95:64], c_model_div_wdata[95:64]); 
      end
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data[63:32] != (c_model_div_wdata[63:32])) & 
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data[63:32] != (c_model_div_wdata[63:32] + 32'd1)) &
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data[63:32] != (c_model_div_wdata[63:32] - 32'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data[63:32], c_model_div_wdata[63:32]); 
	  end
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data[31:0] != (c_model_div_wdata[31:0])) & 
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data[31:0] != (c_model_div_wdata[31:0] + 32'd1)) & 
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data[31:0] != (c_model_div_wdata[31:0] - 32'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.sc_mem_wt_data[31:0], c_model_div_wdata[31:0]); 
	  end
    end
  end
  
  
  //Check Output Write Data Every Write Enable
  always@(posedge top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_en)
  begin
	out_scan_file = $fscanf(out_wtdata_file, "%h\n", c_model_out_wdata) ;  

    if(!$feof(out_wtdata_file)) 
    begin
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[127:120] != (c_model_out_wdata[127:120])) &
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[127:120] != (c_model_out_wdata[127:120] + 8'd1)) & 
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[127:120] != (c_model_out_wdata[127:120] - 8'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[127:120], c_model_out_wdata[127:120]); 
      end
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[119:112] != (c_model_out_wdata[119:112])) &
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[119:112] != (c_model_out_wdata[119:112] + 8'd1)) & 
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[119:112] != (c_model_out_wdata[119:112] - 8'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[119:112], c_model_out_wdata[119:112]); 
      end
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[111:104] != (c_model_out_wdata[111:104])) &
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[111:104] != (c_model_out_wdata[111:104] + 8'd1)) & 
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[111:104] != (c_model_out_wdata[111:104] - 8'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[111:104], c_model_out_wdata[111:104]); 
      end
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[103:96] != (c_model_out_wdata[103:96])) &
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[103:96] != (c_model_out_wdata[103:96] + 8'd1)) & 
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[103:96] != (c_model_out_wdata[103:96] - 8'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[103:96], c_model_out_wdata[103:96]); 
      end
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[95:88] != (c_model_out_wdata[95:88])) &
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[95:88] != (c_model_out_wdata[95:88] + 8'd1)) & 
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[95:88] != (c_model_out_wdata[95:88] - 8'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[95:88], c_model_out_wdata[95:88]); 
      end
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[87:80] != (c_model_out_wdata[87:80])) &
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[87:80] != (c_model_out_wdata[87:80] + 8'd1)) & 
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[87:80] != (c_model_out_wdata[87:80] - 8'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[87:80], c_model_out_wdata[87:80]); 
      end
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[79:72] != (c_model_out_wdata[79:72])) &
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[79:72] != (c_model_out_wdata[79:72] + 8'd1)) & 
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[79:72] != (c_model_out_wdata[79:72] - 8'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[79:72], c_model_out_wdata[79:72]); 
      end
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[71:64] != (c_model_out_wdata[71:64])) &
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[71:64] != (c_model_out_wdata[71:64] + 8'd1)) & 
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[71:64] != (c_model_out_wdata[71:64] - 8'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[71:64], c_model_out_wdata[71:64]); 
      end
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[63:56] != (c_model_out_wdata[63:56])) & 
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[63:56] != (c_model_out_wdata[63:56] + 8'd1)) &
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[63:56] != (c_model_out_wdata[63:56] - 8'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[63:56], c_model_out_wdata[63:56]); 
	  end
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[55:48] != (c_model_out_wdata[55:48])) & 
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[55:48] != (c_model_out_wdata[55:48] + 8'd1)) &
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[55:48] != (c_model_out_wdata[55:48] - 8'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[55:48], c_model_out_wdata[55:48]); 
	  end
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[47:40] != (c_model_out_wdata[47:40])) & 
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[47:40] != (c_model_out_wdata[47:40] + 8'd1)) &
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[47:40] != (c_model_out_wdata[47:40] - 8'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[47:40], c_model_out_wdata[47:40]); 
	  end
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[39:32] != (c_model_out_wdata[39:32])) & 
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[39:32] != (c_model_out_wdata[39:32] + 8'd1)) &
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[39:32] != (c_model_out_wdata[39:32] - 8'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[39:32], c_model_out_wdata[39:32]); 
	  end
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[31:24] != (c_model_out_wdata[31:24])) & 
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[31:24] != (c_model_out_wdata[31:24] + 8'd1)) & 
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[31:24] != (c_model_out_wdata[31:24] - 8'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[31:24], c_model_out_wdata[31:24]); 
	  end
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[23:16] != (c_model_out_wdata[23:16])) & 
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[23:16] != (c_model_out_wdata[23:16] + 8'd1)) & 
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[23:16] != (c_model_out_wdata[23:16] - 8'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[23:16], c_model_out_wdata[23:16]); 
	  end
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[15:8] != (c_model_out_wdata[15:8])) & 
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[15:8] != (c_model_out_wdata[15:8] + 8'd1)) & 
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[15:8] != (c_model_out_wdata[15:8] - 8'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[15:8], c_model_out_wdata[15:8]); 
	  end
	  if ((top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[7:0] != (c_model_out_wdata[7:0])) & 
	      (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[7:0] != (c_model_out_wdata[7:0] + 8'd1)) & 
		  (top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[7:0] != (c_model_out_wdata[7:0] - 8'd1)) ) begin
	    $display("Mismatch top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.dm_top_u0.out_mem_wt_data[7:0], c_model_out_wdata[7:0]); 
	  end
    end
  end
  

endmodule 

