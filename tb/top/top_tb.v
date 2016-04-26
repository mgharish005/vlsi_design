
//top level
`include "../../rtl/top.v"
`include "../../rtl/top_without_mem.v"
`include "../../rtl/memory.v"
`include "../../rtl/top_level_control.v"
`include "../../rtl/mem_controller.v"
`include "../../rtl/histogram_equalizer_core.v"
`include "../../rtl/histogram/histogram_data_path.v"
`include "../../rtl/histogram/histogram_control.v"


//`timescale 1 ns/ 100 ps
module top_tb; 

    reg clock , reset;
    reg new_image_pulse; 
    reg [16:0] input_mem_depth, scratch_mem_depth, output_mem_depth; 
    integer wdata_file; 
    integer waddr_file; 
    integer scan_file1 ,scan_file2; 
    integer c_model_waddr; 
    integer c_model_wdata[0:3]; 
    reg[31:0] c_model_wdata_all; 

    initial
    begin
        waddr_file = $fopen("hist_scratch_waddr.txt", "r"); 
        wdata_file = $fopen("hist_scratch_wdata.txt", "r"); 
        $dumpfile("top_tb.vcd"); 
        $dumpvars(0, top_tb) ;
        $readmemh("input_image.txt", top_u0.input_memory_u0.Register);  
        clock = 1; 
        reset = 1; 
        c_model_wdata_all = 0; 

        input_mem_depth = 1<<16; 
        scratch_mem_depth = 1<<16; 
        output_mem_depth = 1<<16; 
        //sequence
        #30 reset = 0 ;
        #10 new_image_pulse = 1; 
        #20 new_image_pulse = 0; 


        #8500 $finish; 
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
    scan_file2 = $fscanf(wdata_file, "%x\n", c_model_wdata_all) ;  


    c_model_wdata[0] = c_model_wdata_all & 32'h000f; 
    c_model_wdata[1] = (c_model_wdata_all & 32'h00f0) >> 4 ; 
    c_model_wdata[2] = (c_model_wdata_all & 32'h0f00) >> 8; 
    c_model_wdata[3] = (c_model_wdata_all & 32'hf000) >> 12; 


  //$display("[checker] wdata from pli = %x", c_model_wdata_all); 
  //$display("[checker] wdata from pli = %x", c_model_wdata[3]); 
  //$display("[checker] wdata from pli = %x", c_model_wdata[2]); 
  //$display("[checker] wdata from pli = %x", c_model_wdata[1]); 
  //$display("[checker] wdata from pli = %x", c_model_wdata[0]); 


    if(!$feof(waddr_file)) 
    begin
        if(top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.write_address != c_model_waddr)
                $display("Mismatch hist_scratch_waddr @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.write_address, c_model_waddr); 
  //    else
  //            $display("Match hist_scratch_waddr @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.write_address, c_model_waddr); 
    end

    if(!$feof(wdata_file)) 
    begin
        if(top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.wdata[127:96] != c_model_wdata[3])
                $display("Mismatch hist_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.wdata[127:96], c_model_wdata[3]); 
  //    else
  //            $display("Match hist_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.wdata[127:96], c_model_wdata[3]); 
  //    
        if(top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.wdata[95:64] != c_model_wdata[2])
                $display("Mismatch hist_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.wdata[95:64], c_model_wdata[2]); 
///     else
///             $display("Match hist_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, top_u0.top_without_mem_u0.histogram_equalizer_core_u0.histogram_data_path_u0.wdata[95:64], c_model_wdata[2]); 

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

endmodule 

