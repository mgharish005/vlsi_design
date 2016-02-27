`include "../histogram_control.v"

`timescale 1 ns/ 100 ps
module histogram_control_tb; 

    reg clock , reset, start_histogram, input_memory_read_finished, all_pixel_written; 

    initial
    begin
        $dumpfile("histogram_control_tb.vcd"); 
        $dumpvars(0, histogram_control_tb) ;
        clock = 1; 
        reset = 1; 
        start_histogram = 0; 
        input_memory_read_finished = 0; 
        all_pixel_written = 0; 

        //sequence
        #10 reset = 0 ;
        #20 start_histogram = 1 ;

        #500 $finish; 
    end

    histogram_control histogram_control_t0 
    (
        .clock(clock), 
        .reset(reset), 
        .start_histogram(start_histogram),
        .input_memory_read_finished(input_memory_read_finished), 
        .all_pixel_written(all_pixel_written)
    );
    
  /* Make a regular pulsing clock. */
  always #5 clock = !clock;


endmodule 
