module top_without_mem
(
input clock, 
input reset,

//Inputs------------------------------------------------------ 
//1. from scratch memory
input scratch_rdata0,
input scratch_rdata1,

//2. from input memory
input input_rdata0,
input input_rdata1,


//Outputs------------------------------------------------------
//1. to scratch memory
output scratch_WE,
output scratch_write_addr,
output scratch_wdata,
output scratch_read_addr0,
output scratch_read_addr1,


//2. to input memory
output input_WE,
output input_write_addr,
output input_wdata,
output input_read_addr0,
output input_read_addr1, 

); 
    

wire histogram_scratch_mem_rdata0; 
wire histogram_scratch_mem_rdata1; 
wire histogram_scratch_mem_rdata0;   
wire histogram_scratch_mem_rdata1;  
wire histogram_scratch_mem_waddr; 
wire histogram_scratch_mem_wdata; 
wire histogram_scratch_mem_WE; 

wire cdf_wire_mem_rdata0;   
wire cdf_wire_mem_rdata1;   
wire cdf_scratch_mem_rdata0; 
wire cdf_scratch_mem_rdata1; 
wire cdf_scratch_mem_waddr; 
wire cdf_scratch_mem_wdata; 
wire cdf_scratch_mem_WE; 


wire divider_wire_mem_rdata0;   
wire divider_wire_mem_rdata1;   
wire divider_scratch_mem_rdata0; 
wire divider_scratch_mem_rdata1; 
wire divider_scratch_mem_waddr; 
wire divider_scratch_mem_wdata; 

/*
input_module input_module_u1
(

); 

output_module output_module_u1
(

); 
*/
mem_controller mem_controller_u0
(
    .histogram_en(histogram_en), 
    .cdf_en(cdf_en), 
    .divider_en(divider_en), 

    .histogram_input_mem_rdata0(histogram_input_mem_rdata0), 
    .histogram_input_mem_rdata1(histogram_input_mem_rdata1), 
    .histogram_scratch_mem_rdata0(histogram_scratch_mem_rdata0), 
    .histogram_scratch_mem_rdata1(histogram_scratch_mem_rdata1), 
    .histogram_scratch_mem_waddr(histogram_scratch_mem_waddr), 
    .histogram_scratch_mem_wdata(histogram_scratch_mem_wdata), 
    .histogram_scratch_mem_WE(histogram_scratch_mem_WE), 

    .cdf_input_mem_rdata0(cdf_input_mem_rdata0), 
    .cdf_input_mem_rdata1(cdf_input_mem_rdata1), 
    .cdf_scratch_mem_rdata0(cdf_scratch_mem_rdata0), 
    .cdf_scratch_mem_rdata1(cdf_scratch_mem_rdata1), 
    .cdf_scratch_mem_waddr(cdf_scratch_mem_waddr), 
    .cdf_scratch_mem_wdata(cdf_scratch_mem_wdata), 
    .cdf_scratch_mem_WE(cdf_scratch_mem_WE), 
    
    .divider_input_mem_rdata0(divider_input_mem_rdata0), 
    .divider_input_mem_rdata1(divider_input_mem_rdata1), 
    .divider_scratch_mem_rdata0(divider_scratch_mem_rdata0), 
    .divider_scratch_mem_rdata1(divider_scratch_mem_rdata1), 
    .divider_scratch_mem_waddr(divider_scratch_mem_waddr), 
    .divider_scratch_mem_wdata(divider_scratch_mem_wdata), 
    .divider_scratch_mem_WE(divider_scratch_mem_WE), 
    
    .final_input_mem_rdata0(input_read_addr0), 
    .final_input_mem_rdata1(input_read_addr1), 
    .final_scratch_mem_rdata0(scratch_read_addr0), 
    .final_scratch_mem_rdata1(scratch_read_addr1), 
    .final_scratch_mem_waddr(scratch_write_addr), 
    .final_scratch_mem_wdata(scratch_wdata), 
    .final_scratch_mem_WE(scratch_WE), 

    
); 

histogram_equalizer_core histogram_equalizer_core_u0
(

.clock(clock), 
.reset(reset),

 //scratch mem interface
.scratch_WE(histogram_scratch_mem_WE), 
.scratch_write_addr(histogram_scratch_mem_waddr), 
.scratch_wdata(histogram_scratch_mem_wdata), 
.scratch_read_addr0(histogram_scratch_mem_rdata1), 
.scratch_read_addr1(histogram_scratch_mem_rdata1), 
.scratch_rdata0(histogram_scratch_mem_rdata0), 
.scratch_rdata1(histogram_scratch_mem_rdata1),

//input mem interface
.input_WE(input_WE), 
.input_write_addr(input_write_addr), 
.input_wdata(input_wdata), 
.input_read_addr0(input_read_addr0), 
.input_read_addr1(input_read_addr1), 
.input_rdata0(input_rdata0), 
.input_rdata1(input_rdata1), 

//FSM
.start_histogram(start_histogram)
.input_memory_read_finished(input_memory_read_finished)
); 
