module histogram_equalizer_core
(
input clock, 
input reset, 

//Inputs------------------------------------------------------ 
//1. from scratch memory
input [127:0] histogram_scratch_mem_rdata0,
input [127:0] histogram_scratch_mem_rdata1,
input [127:0] cdf_scratch_mem_rdata0,
input [127:0] cdf_scratch_mem_rdata1,
input [127:0] divider_scratch_mem_rdata0,
input [127:0] divider_scratch_mem_rdata1,


//2. from input memory
input [127:0] histogram_input_mem_rdata0,
input [127:0] histogram_input_mem_rdata1,
input [127:0] divider_input_mem_rdata0,
input [127:0] divider_input_mem_rdata1,


//3. from master FSM
input start_histogram, 
input start_cdf,
input start_divider,
input input_mem_read_finished, 

//Outputs------------------------------------------------------
//1.1 to scratch memory - write
output histogram_scratch_mem_WE,
output cdf_scratch_mem_WE,
output divider_scratch_mem_WE,

output [15:0]  histogram_scratch_mem_waddr,
output [15:0]  cdf_scratch_mem_waddr,
output [15:0]  divider_scratch_mem_waddr,

output [127:0] histogram_scratch_mem_wdata, 
output [127:0] cdf_scratch_mem_wdata, 
output [127:0] divider_scratch_mem_wdata, 

//1.2 to scratch memory - read
output [15:0] histogram_scratch_mem_raddr0,
output [15:0] histogram_scratch_mem_raddr1,
output [15:0] cdf_scratch_mem_raddr0,
output [15:0] cdf_scratch_mem_raddr1,
output [15:0] divider_scratch_mem_raddr0,
output [15:0] divider_scratch_mem_raddr1,


//2. to input memory
output [15:0] histogram_input_mem_raddr0,
output [15:0] histogram_input_mem_raddr1, 
output [15:0] divider_input_mem_raddr0,
output [15:0] divider_input_mem_raddr1, 

//3. to output memory, 
output [127:0] divider_output_mem_wdata, 
output divider_output_mem_WE, 
output [15:0] divider_output_mem_waddr, 

//4. to master FSM
output histogram_computation_done  
); 

//wires
wire all_pixel_written; 
wire set_read_address_input_mem; 
wire set_read_address_scratch_mem; 
wire set_write_address_scratch_mem; 
wire shift_scratch_memory_rw_address; 
wire read_data_ready_input_mem; 
wire read_data_ready_scratch_mem; 

//control path
histogram_data_path histogram_data_path_u0 
(
.clock(clock), 
.reset(reset),

.input_memory_rdata0(histogram_input_mem_rdata0), 
.input_memory_rdata1(histogram_input_mem_rdata1), 
.scratch_memory_rdata0(histogram_scratch_mem_rdata0), 

.input_memory_address_pointer0(histogram_input_mem_raddr0), 
.input_memory_address_pointer1(histogram_input_mem_raddr1), 
.scratch_memory_address_pointer0(histogram_scratch_mem_raddr0), 
.write_enable(histogram_scratch_mem_WE), 
.scratch_memory_wdata(histogram_scratch_mem_wdata), 
.write_address(histogram_scratch_mem_waddr), 

.set_read_address_input_mem(set_read_address_input_mem), 
.set_read_address_scratch_mem(set_read_address_scratch_mem), 
.set_write_address_scratch_mem(set_write_address_scratch_mem), 
.shift_scratch_memory_rw_address(shift_scratch_memory_rw_address), 
.read_data_ready_input_mem(read_data_ready_input_mem), 
.read_data_ready_scratch_mem(read_data_ready_scratch_mem), 
.all_pixel_written(all_pixel_written)  

); 


histogram_control histogram_control_u0 
(
.clock(clock), 
.reset(reset), 
.start_histogram(start_histogram), 
.input_memory_read_finished(input_mem_read_finished), 
.all_pixel_written(all_pixel_written), 

.set_read_address_input_mem(set_read_address_input_mem), 
.set_read_address_scratch_mem(set_read_address_scratch_mem), 
.set_write_address_scratch_mem(set_write_address_scratch_mem), 
.shift_scratch_memory_rw_address(shift_scratch_memory_rw_address), 
.read_data_ready_input_mem(read_data_ready_input_mem), 
.histogram_computation_done(histogram_computation_done),
.read_data_ready_scratch_mem(read_data_ready_scratch_mem)  
); 


endmodule
