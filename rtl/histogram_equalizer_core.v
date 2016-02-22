module histogram_equalizer_core
(

//Inputs------------------------------------------------------ 
//1. from scratch memory
scratch_rdata1,
scratch_rdata2,

//1. from input memory
input_rdata1,
input_rdata2,

//Outputs------------------------------------------------------
//1. to scratch memory
scratch_WE,
scratch_write_addr,
scratch_wdata,
scratch_read_addr1,
scratch_read_addr2,

//2. to input memory
input_WE,
input_write_addr,
input_wdata,
input_read_addr1,
input_read_addr2 
); 

//inputs
input start_histogram; 
input [127:0] scratch_rdata1; 
input [127:0] scratch_rdata2; 
input [127:0] input_rdata1; 
input [127:0] input_rdata2; 

//outputs
output         scratch_WE; 
output [15:0]  scratch_write_addr; 
output [15:0]  scratch_read_addr1; 
output [15:0]  scratch_read_addr2;
output [127:0] scratch_wdata; 
output         input_WE; 
output [15:0]  input_write_addr; 
output [15:0]  input_read_addr1; 
output [15:0]  input_read_addr2;

//wires
reg all_pixel_written; 


//control path
histogram_data_path histogram_data_path_u0 
(
.clock(clock), 
.reset(reset), 
.input_memory_rdata0(input_rdata0), 
.input_memory_rdata1(input_rdata0), 
.scratch_memory_rdata0(scratch_rdata0), 
.input_memory_address_pointer0(input_read_addr1), 
.input_memory_address_pointer1(input_read_addr1), 
.scratch_memory_address_pointer0(scratch_read_addr1), 
); 


histogram_control histogram_control_u0 
(
.clock(clock), 
.reset(reset), 
.start_histogram(start_histogram), 
.input_memory_read_finished(), 
.all_pixel_written(all_pixel_written), 
.set_read_address_input_mem(), 
.set_read_address_scratch_mem(), 
.set_write_address_scratch_mem(), 
.read_data_ready_input_mem(), 
.read_data_ready_scratch_mem  
); 

endmodule
