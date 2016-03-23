
`include "../../rtl/histogram/histogram_control.v"
`include "../../rtl/histogram/histogram_data_path.v"
`include "../../rtl/memory.v"

//`timescale 1 ns/ 100 ps
module histogram_top_tb; 

    reg clock , reset, start_histogram, input_memory_read_finished;
    wire all_pixel_written; 
    wire set_read_address_input_mem; 
    wire set_write_address_scratch_mem; 
    wire shift_scratch_memory_rw_address; 
    wire read_data_ready_input_mem; 
    wire histogram_computation_done; 
    wire read_data_ready_scratch_mem; 

    wire [127:0] input_memory_rdata0; 
    wire [127:0] input_memory_rdata1; 
    wire [127:0] scratch_memory_rdata0; 
    wire [127:0] scratch_memory_rdata1; 
    wire [15:0]  input_memory_address_pointer1; 
    wire [15:0]  input_memory_address_pointer0; 
    wire [15:0]  scratch_memory_address_pointer0;  
    wire write_enable; 
    wire [127:0] scratch_memory_wdata; 
    wire [15:0]  write_address; 

    initial
    begin
        $dumpfile("histogram_top_tb.vcd"); 
        $dumpvars(0, histogram_top_tb) ;
        $readmemh("input_image.txt", scratch_m0.Register);  
        clock = 1; 
        reset = 1; 
        start_histogram = 0; 
        input_memory_read_finished = 0; 

        //sequence
        #10 reset = 0 ;
        #20 start_histogram = 1 ;

        #500 $finish; 
    end

    histogram_control histogram_control_t0 
    (
        //input
        .clock(clock), 
        .reset(reset), 
        .start_histogram(start_histogram),
        .input_memory_read_finished(input_memory_read_finished), 
        .all_pixel_written(all_pixel_written),

        //output
        .set_read_address_input_mem(set_read_address_input_mem),
        .set_read_address_scratch_mem(set_read_address_scratch_mem),
        .set_write_address_scratch_mem(set_write_address_scratch_mem),
        .shift_scratch_memory_rw_address(shift_scratch_memory_rw_address),
        .histogram_computation_done(histogram_computation_done),
        .read_data_ready_input_mem(read_data_ready_input_mem),
        .read_data_ready_scratch_mem(read_data_ready_scratch_mem) 

    );

    histogram_data_path histogram_data_path_t0
    (
        //input
        .clock(clock), 
        .reset(reset), 
        .input_memory_rdata0(input_memory_rdata0),
        .input_memory_rdata1(input_memory_rdata1),
        .scratch_memory_rdata0(scratch_memory_rdata0),

        //output
        .input_memory_address_pointer0(input_memory_address_pointer0), 
        .input_memory_address_pointer1(input_memory_address_pointer1), 
        .scratch_memory_address_pointer0(scratch_memory_address_pointer0), 
        .write_enable(write_enable),
        .scratch_memory_wdata(scratch_memory_wdata),
        .write_address(write_address),
    
        //input
        .set_read_address_input_mem(set_read_address_input_mem),
        .set_read_address_scratch_mem(set_read_address_scratch_mem),
        .set_write_address_scratch_mem(set_write_address_scratch_mem),
        .read_data_ready_input_mem(read_data_ready_input_mem),
        .read_data_ready_scratch_mem(read_data_ready_scratch_mem),
        
        //output
        .all_pixel_written(all_pixel_written)

    );     

    memory input_m0
    (
        .clock(clock),
        .WE(0),
        .WriteAddress(0),
        .ReadAddress1(input_memory_address_pointer0),
        .ReadAddress2(input_memory_address_pointer1),
        .WriteBus(128'b0),
        .ReadBus1(input_memory_rdata0),
        .ReadBus2(input_memory_rdata1)  
    ); 
    memory scratch_m0
    (
        .clock(clock),
        .WE(write_enable),
        .WriteAddress(write_address),
        .ReadAddress1(scratch_memory_address_pointer0),
        .ReadAddress2(0),
        .WriteBus(128'b0),
        .ReadBus1(scratch_memory_rdata0),
        .ReadBus2(scratch_memory_rdata1)  
    ); 

  /* Make a regular pulsing clock. */
  always #5 clock = !clock;


endmodule 
