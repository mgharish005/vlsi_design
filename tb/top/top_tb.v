
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
    integer scan_file; 

    initial
    begin
        wdata_file = $fopen("hist_scratch_wdata.txt", "r"); 
        $dumpfile("top_tb.vcd"); 
        $dumpvars(0, top_tb) ;
        $readmemh("input_image.txt", top_u0.input_memory_u0.Register);  
        clock = 1; 
        reset = 1; 

        input_mem_depth = 1<<16; 
        scratch_mem_depth = 1<<16; 
        output_mem_depth = 1<<16; 
        //sequence
        #30 reset = 0 ;
        #10 new_image_pulse = 1; 
        #20 new_image_pulse = 0; 


        #1500 $finish; 
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

  

endmodule 

