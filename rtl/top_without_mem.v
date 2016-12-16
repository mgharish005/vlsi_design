//`timescale 1 ns/ 100 ps

module top_without_mem
(
input clock, 
input reset,

//Inputs------------------------------------------------------ 

//1. From controller (user)
input new_image_pulse, 
input [16:0] input_mem_depth,
input [16:0] scratch_mem_depth,
input [16:0] output_mem_depth,

//2. from scratch memory
input [127:0] scratch_mem_rdata0,
input [127:0] scratch_mem_rdata1,

//1. from input memory
input [127:0] input_mem_rdata0,
input [127:0] input_mem_rdata1,


//Outputs------------------------------------------------------
//1. to scratch memory
output scratch_mem_WE,
output [15:0] scratch_mem_waddr,
output [127:0] scratch_mem_wdata,
output [15:0] scratch_mem_raddr0,
output [15:0] scratch_mem_raddr1,

//2. to input memory
output [15:0] input_mem_raddr0,
output [15:0] input_mem_raddr1, 

//3. to output memory
output output_mem_WE, 
output [15:0] output_mem_waddr,
output [127:0] output_mem_wdata 
); 
   
//from mem_ctrl to top_level_ctrl
wire input_mem_done; 
wire scratch_mem_overflow_fault; 
wire output_mem_overflow_fault;   

//from top_level_ctrl to mem_ctrl
wire histogram_en; 
wire cdf_en; 
wire divider_en; 
wire image_done_pulse; 

//from histogram_equalizer_core to top_level_ctrl 
wire histogram_computation_done;  
wire cdf_done; 
wire divider_done; 

//from top_level_ctrl to histogram_equalizer_core
wire histogram_start_pulse; 
wire cdf_start_pulse;
wire divider_start_pulse;
wire input_mem_read_finished; 

//from mem_ctrl to histogram_equalizer_core
wire [127:0] histogram_input_mem_rdata0;
wire [127:0] histogram_input_mem_rdata1;
wire [15:0] histogram_input_mem_raddr0;
wire [15:0] histogram_input_mem_raddr1;
wire [15:0] histogram_scratch_mem_raddr0; 
wire [15:0] histogram_scratch_mem_raddr1; 
wire [127:0] histogram_scratch_mem_rdata0;   
wire [127:0] histogram_scratch_mem_rdata1;  
wire [15:0] histogram_scratch_mem_waddr; 
wire [127:0] histogram_scratch_mem_wdata; 
wire histogram_scratch_mem_WE; 

wire [15:0] cdf_scratch_mem_raddr0;   
wire [15:0] cdf_scratch_mem_raddr1;   
wire [127:0] cdf_scratch_mem_rdata0; 
wire [127:0] cdf_scratch_mem_rdata1; 
wire [15:0] cdf_scratch_mem_waddr; 
wire [127:0] cdf_scratch_mem_wdata; 
wire cdf_scratch_mem_WE; 


wire [15:0] divider_scratch_mem_raddr0;   
wire [15:0] divider_scratch_mem_raddr1;   
wire [127:0] divider_scratch_mem_rdata0; 
wire [127:0] divider_scratch_mem_rdata1; 
wire [127:0] divider_scratch_mem_wdata; 
wire [15:0] divider_scratch_mem_waddr; 
wire [127:0] divider_input_mem_rdata0; 
wire [127:0] divider_input_mem_rdata1; 
wire [15:0] divider_input_mem_raddr0; 
wire [15:0] divider_input_mem_raddr1; 
wire divider_scratch_mem_WE; 
wire [15:0] divider_output_mem_waddr; 
wire [127:0] divider_output_mem_wdata;
wire divider_output_mem_WE;
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
    .clock(clock),
    .reset(reset),
    .histogram_en(histogram_en), 
    .cdf_en(cdf_en), 
    .divider_en(divider_en), 
    .image_done_pulse(image_done_pulse),

    .input_mem_depth(input_mem_depth), 
    .scratch_mem_depth(scratch_mem_depth), 
    .output_mem_depth(output_mem_depth),
    
    .histogram_input_mem_rdata0(histogram_input_mem_rdata0), 
    .histogram_input_mem_rdata1(histogram_input_mem_rdata1), 
    .histogram_input_mem_raddr0(histogram_input_mem_raddr0), 
    .histogram_input_mem_raddr1(histogram_input_mem_raddr1), 
    .histogram_scratch_mem_raddr0(histogram_scratch_mem_raddr0), 
    .histogram_scratch_mem_raddr1(histogram_scratch_mem_raddr1), 
    .histogram_scratch_mem_rdata0(histogram_scratch_mem_rdata0), 
    .histogram_scratch_mem_rdata1(histogram_scratch_mem_rdata1), 
    .histogram_scratch_mem_waddr(histogram_scratch_mem_waddr), 
    .histogram_scratch_mem_wdata(histogram_scratch_mem_wdata), 
    .histogram_scratch_mem_WE(histogram_scratch_mem_WE), 

    .cdf_scratch_mem_raddr0(cdf_scratch_mem_raddr0), 
    .cdf_scratch_mem_raddr1(cdf_scratch_mem_raddr1), 
    .cdf_scratch_mem_rdata0(cdf_scratch_mem_rdata0), 
    .cdf_scratch_mem_rdata1(cdf_scratch_mem_rdata1), 
    .cdf_scratch_mem_waddr(cdf_scratch_mem_waddr), 
    .cdf_scratch_mem_wdata(cdf_scratch_mem_wdata), 
    .cdf_scratch_mem_WE(cdf_scratch_mem_WE), 
    
    .divider_input_mem_rdata0(divider_input_mem_rdata0), 
    .divider_input_mem_rdata1(divider_input_mem_rdata1), 
    .divider_input_mem_raddr0(divider_input_mem_raddr0), 
    .divider_input_mem_raddr1(divider_input_mem_raddr1), 
    .divider_scratch_mem_raddr0(divider_scratch_mem_raddr0), 
    .divider_scratch_mem_raddr1(divider_scratch_mem_raddr1), 
    .divider_scratch_mem_rdata0(divider_scratch_mem_rdata0), 
    .divider_scratch_mem_rdata1(divider_scratch_mem_rdata1), 
    .divider_scratch_mem_waddr(divider_scratch_mem_waddr),
    .divider_scratch_mem_WE(divider_scratch_mem_WE),
    .divider_scratch_mem_wdata(divider_scratch_mem_wdata),
    .divider_output_mem_waddr(divider_output_mem_waddr), 
    .divider_output_mem_wdata(divider_output_mem_wdata),
    .divider_output_mem_WE(divider_output_mem_WE),
    

    .final_input_mem_raddr0(input_mem_raddr0),
    .final_input_mem_raddr1(input_mem_raddr1),
    .final_input_mem_rdata0(input_mem_rdata0), 
    .final_input_mem_rdata1(input_mem_rdata1), 
    .final_scratch_mem_rdata0(scratch_mem_rdata0), 
    .final_scratch_mem_rdata1(scratch_mem_rdata1), 
    .final_scratch_mem_raddr0(scratch_mem_raddr0),
    .final_scratch_mem_raddr1(scratch_mem_raddr1),
    .final_scratch_mem_waddr(scratch_mem_waddr), 
    .final_scratch_mem_wdata(scratch_mem_wdata), 
    .final_scratch_mem_WE(scratch_mem_WE),     
    .final_output_mem_waddr(output_mem_waddr), 
    .final_output_mem_wdata(output_mem_wdata), 
    .final_output_mem_WE(output_mem_WE),    

    .input_mem_done(input_mem_done), 
    .scratch_mem_overflow_fault(scratch_mem_overflow_fault),
    .output_mem_overflow_fault(output_mem_overflow_fault) 
); 

top_level_control top_level_control_u0
(
    .clock(clock),
    .reset(reset),
    .new_image_pulse(new_image_pulse),
    .input_mem_done(input_mem_done),
    .scratch_mem_overflow_fault(scratch_mem_overflow_fault),
    .output_mem_overflow_fault(output_mem_overflow_fault), 
    .histogram_computation_done(histogram_computation_done), 
    .cdf_done(cdf_done), 
    .divider_done(divider_done), 

    .histogram_start_pulse(histogram_start_pulse),
    .cdf_start_pulse(cdf_start_pulse),
    .divider_start_pulse(divider_start_pulse),
    .histogram_en(histogram_en),
    .cdf_en(cdf_en), 
    .divider_en(divider_en),
    .image_done_pulse(image_done_pulse),
    .input_mem_read_finished(input_mem_read_finished)

);

histogram_equalizer_core histogram_equalizer_core_u0
(

.clock(clock), 
.reset(reset),

//Inputs------------------------------------------------------ 
//1. from scratch memory
.histogram_scratch_mem_rdata0(histogram_scratch_mem_rdata0), 
.histogram_scratch_mem_rdata1(histogram_scratch_mem_rdata1), 
.cdf_scratch_mem_rdata0(cdf_scratch_mem_rdata0), 
.cdf_scratch_mem_rdata1(cdf_scratch_mem_rdata1), 
.divider_scratch_mem_rdata0(divider_scratch_mem_rdata0), 
.divider_scratch_mem_rdata1(divider_scratch_mem_rdata1), 

//2. from input memory
.histogram_input_mem_rdata0(histogram_input_mem_rdata0), 
.histogram_input_mem_rdata1(histogram_input_mem_rdata1), 
.divider_input_mem_rdata0(divider_input_mem_rdata0), 
.divider_input_mem_rdata1(divider_input_mem_rdata1), 


//3. from master FSM
.start_histogram(histogram_start_pulse),
.start_cdf(cdf_start_pulse),
.start_divider(divider_start_pulse),
.input_mem_read_finished(input_mem_done),

//Outputs------------------------------------------------------
//1.1 to scratch memory - write
.histogram_scratch_mem_WE(histogram_scratch_mem_WE), 
.cdf_scratch_mem_WE(cdf_scratch_mem_WE), 
.divider_scratch_mem_WE(divider_scratch_mem_WE), 

.histogram_scratch_mem_waddr(histogram_scratch_mem_waddr), 
.cdf_scratch_mem_waddr(cdf_scratch_mem_waddr), 
.divider_scratch_mem_waddr(divider_scratch_mem_waddr), 

.histogram_scratch_mem_wdata(histogram_scratch_mem_wdata), 
.cdf_scratch_mem_wdata(cdf_scratch_mem_wdata), 
.divider_scratch_mem_wdata(divider_scratch_mem_wdata), 


//1.2 to scratch memory - read
.histogram_scratch_mem_raddr0(histogram_scratch_mem_raddr0), 
.histogram_scratch_mem_raddr1(histogram_scratch_mem_raddr1), 
.cdf_scratch_mem_raddr0(cdf_scratch_mem_raddr0), 
.cdf_scratch_mem_raddr1(cdf_scratch_mem_raddr1), 
.divider_scratch_mem_raddr0(divider_scratch_mem_raddr0), 
.divider_scratch_mem_raddr1(divider_scratch_mem_raddr1), 


//2. to input memory
.histogram_input_mem_raddr0(histogram_input_mem_raddr0), 
.histogram_input_mem_raddr1(histogram_input_mem_raddr1), 
.divider_input_mem_raddr0(divider_input_mem_raddr0), 
.divider_input_mem_raddr1(divider_input_mem_raddr1), 

//3. to output memory, 
.divider_output_mem_waddr(divider_output_mem_waddr), 
.divider_output_mem_wdata(divider_output_mem_wdata), 
.divider_output_mem_WE(divider_output_mem_WE), 


//4. to master FSM
.histogram_computation_done(histogram_computation_done) , 
.cdf_done(cdf_done), 
.divider_done(divider_done)
); 


endmodule
