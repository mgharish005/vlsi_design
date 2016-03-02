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
output input_rdata0,
output input_rdata1, 

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

    .histogram_scratch_mem_raddr0(histogram_scratch_mem_raddr0), 
    .histogram_scratch_mem_raddr1(histogram_scratch_mem_raddr1), 
    .histogram_scratch_mem_rdata0(histogram_scratch_mem_rdata0), 
    .histogram_scratch_mem_rdata1(histogram_scratch_mem_rdata1), 
    .histogram_scratch_mem_waddr(histogram_scratch_mem_waddr), 
    .histogram_scratch_mem_wdata(histogram_scratch_mem_wdata), 
    .histogram_scratch_mem_WE(histogram_scratch_mem_WE), 

    .cdf_scratch_mem_read_addr0(cdf_scratch_mem_read_addr0), 
    .cdf_scratch_mem_read_addr1(cdf_scratch_mem_read_addr1), 
    .cdf_scratch_mem_rdata0(cdf_scratch_mem_rdata0), 
    .cdf_scratch_mem_rdata1(cdf_scratch_mem_rdata1), 
    .cdf_scratch_mem_waddr(cdf_scratch_mem_waddr), 
    .cdf_scratch_mem_wdata(cdf_scratch_mem_wdata), 
    .cdf_scratch_mem_WE(cdf_scratch_mem_WE), 
    
    .divider_scratch_mem_read_addr0(cdf_scratch_mem_read_addr0), 
    .divider_scratch_mem_read_addr1(cdf_scratch_mem_read_addr1), 
    .divider_scratch_mem_rdata0(divider_scratch_mem_rdata0), 
    .divider_scratch_mem_rdata1(divider_scratch_mem_rdata1), 
    
    .final_input_mem_rdata0(input_read_addr0), 
    .final_input_mem_rdata1(input_read_addr1), 
    .final_scratch_mem_rdata0(scratch_read_addr0), 
    .final_scratch_mem_rdata1(scratch_read_addr1), 
    .final_scratch_mem_waddr(scratch_write_addr), 
    .final_scratch_mem_wdata(scratch_wdata), 
    .final_scratch_mem_WE(scratch_WE),     
); 

/*
sram_2R1W input_mem
(
    .clock(clock), 
    .WE(0), 
    .WriteAddress(16'b0), 
    .WriteBus(128'b0), 
    .ReadAddress1(histogram_input_mem_raddr0), 
    .ReadAddress2(histogram_input_mem_raddr1), 
    .ReadBus1(histogram_input_mem_rdata0), 
    .ReadBus2(histogram_input_mem_rdata1), 

);

*/



histogram_equalizer_core histogram_equalizer_core_u0
(

.clock(clock), 
.reset(reset),

.histogram_input_mem_raddr0(input_mem_raddr0), 
.histogram_input_mem_raddr1(input_mem_raddr1), 
.histogram_input_mem_rdata0(input_mem_rdata0), 
.histogram_input_mem_rdata1(input_mem_rdata1), 

.histogram_scratch_mem_raddr0(histogram_scratch_mem_raddr0), 
.histogram_scratch_mem_raddr1(histogram_scratch_mem_raddr1), 
.histogram_scratch_mem_rdata0(histogram_scratch_mem_rdata0), 
.histogram_scratch_mem_rdata1(histogram_scratch_mem_rdata1), 
.histogram_scratch_mem_waddr(histogram_scratch_mem_waddr), 
.histogram_scratch_mem_wdata(histogram_scratch_mem_wdata), 
.histogram_scratch_mem_WE(histogram_scratch_mem_WE), 

.cdf_scratch_mem_read_addr0(cdf_scratch_mem_raddr0), 
.cdf_scratch_mem_read_addr1(cdf_scratch_mem_raddr1), 
.cdf_scratch_mem_rdata0(cdf_scratch_mem_rdata0), 
.cdf_scratch_mem_rdata1(cdf_scratch_mem_rdata1), 
.cdf_scratch_mem_waddr(cdf_scratch_mem_waddr), 
.cdf_scratch_mem_wdata(cdf_scratch_mem_wdata), 
.cdf_scratch_mem_WE(cdf_scratch_mem_WE), 


.divider_output_mem_rdata0(divider_output_mem_rdata0), 
.divider_output_mem_rdata1(divider_output_mem_rdata1), 
.divider_scratch_mem_read_addr0(cdf_scratch_mem_read_addr0), 
.divider_scratch_mem_read_addr1(cdf_scratch_mem_read_addr1), 
.divider_scratch_mem_rdata0(divider_scratch_mem_rdata0), 
.divider_scratch_mem_rdata1(divider_scratch_mem_rdata1), 



//FSM interface
.start_histogram(start_histogram)
.histogram_computation_done(histogram_computation_done), 
.input_memory_read_finished(input_memory_read_finished)
); 
