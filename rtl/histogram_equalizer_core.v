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
output histogram_computation_done,  
output cdf_done  
); 

//wires
wire all_pixel_written; 
wire set_read_address_input_mem; 
wire set_read_address_scratch_mem; 
wire set_write_address_scratch_mem; 
wire shift_scratch_memory_rw_address; 
wire read_data_ready_input_mem; 
wire read_data_ready_scratch_mem; 
//cdf
wire read_first_value; 
wire read_next_value; 
wire scratch_mem_read_ready; 
wire cdf_computation_done; 
wire cdf_done_in; 

//control path
histogram_data_path histogram_data_path_u0 
(
.clock(clock), 
.reset(reset),

.input_memory_rdata0(histogram_input_mem_rdata0), 
.input_memory_rdata1(histogram_input_mem_rdata1), 
.scratch_memory_rdata0(histogram_scratch_mem_rdata1), 

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

cdf_control cdf_control_u0
(
.clk(clock),
.reset(reset), 
.cdf_start_in(cdf_start), 

.read_first_value(read_first_value),
.scratch_mem_read_ready(scratch_mem_read_ready),
.cdf_computation_done(cdf_computation_done),
.read_next_value(read_next_value),
.cdf_done(cdf_done)
);

cdf_datapath cdf_datapath_u0
(
.clk(clock),
.reset(reset), 
.scratchmem_input1(cdf_scratch_mem_rdata0),
.scratchmem_input2(cdf_scratch_mem_rdata1),
.read_first_value_in(read_first_value),
.scratch_mem_read_ready_in(scratch_mem_read_ready),
.cdf_computation_done_in(cdf_computation_done),
.read_next_value_in(read_next_value),
.cdf_done_in(cdf_done),

.WE(cdf_scratch_mem_WE),
.WriteAddress(cdf_scratch_mem_waddr),
.WriteBus(cdf_scratch_mem_wdata),
.ReadAddress1(cdf_scratch_mem_raddr0),
.ReadAddress2(cdf_scratch_mem_raddr1) 
); 



endmodule
