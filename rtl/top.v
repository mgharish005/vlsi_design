module top
(
input clock, 
input reset,
input new_image_pulse, 
input [16:0] input_mem_depth,
input [16:0] scratch_mem_depth,
input [16:0] output_mem_depth

); 

//wires-------------------------------------------
wire clock; 
//scratch mem
wire scratch_mem_WE; 
wire [15:0]  scratch_mem_waddr; 
wire [15:0]  scratch_mem_raddr1;
wire [15:0]  scratch_mem_raddr0;
wire [127:0] scratch_mem_wdata; 
wire [127:0] scratch_mem_rdata1;
wire [127:0] scratch_mem_rdata0;

//input mem
wire [15:0]  input_mem_raddr1;
wire [15:0]  input_mem_raddr0;
wire [127:0] input_mem_rdata1;
wire [127:0] input_mem_rdata0;

//output mem
wire output_mem_WE; 
wire [15:0]  output_mem_waddr; 
wire [127:0]  output_mem_wdata; 
top_without_mem top_without_mem_u0
(
//Inputs------------------------------------------------------ 
.clock(clock), 
.reset(reset),

//1. From controller (user)
.new_image_pulse(new_image_pulse), 
.input_mem_depth(input_mem_depth),
.scratch_mem_depth(scratch_mem_depth),
.output_mem_depth(output_mem_depth),

//2. from scratch memory
.scratch_mem_rdata0(scratch_mem_rdata0),
.scratch_mem_rdata1(scratch_mem_rdata1),

//1. from input memory
.input_mem_rdata0(input_mem_rdata0),
.input_mem_rdata1(input_mem_rdata1),

//Outputs------------------------------------------------------
//1. to scratch memory
.scratch_mem_WE(scratch_mem_WE), 
.scratch_mem_waddr(scratch_mem_waddr), 
.scratch_mem_wdata(scratch_mem_wdata), 
.scratch_mem_raddr1(scratch_mem_raddr1), 
.scratch_mem_raddr0(scratch_mem_raddr0), 

//2. to input mem interface
.input_mem_raddr1(input_mem_raddr1), 
.input_mem_raddr0(input_mem_raddr0), 

//3. to output memory
.output_mem_WE(output_mem_WE), 
.output_mem_waddr(output_mem_waddr),
.output_mem_wdata(output_mem_wdata) 
); 

memory scratch_memory_u0
(
.clock(clock),
.WE(scratch_mem_WE),
.WriteAddress(scratch_mem_waddr), 
.ReadBus1(scratch_mem_rdata0), 
.ReadBus2(scratch_mem_rdata1), 
.ReadAddress2(scratch_mem_raddr0), 
.ReadAddress1(scratch_mem_raddr1),  
.WriteBus(scratch_mem_wdata)
);

memory input_memory_u0
(
.clock(clock),
.WE(1'b0),
.WriteAddress(16'b0), 
.ReadBus1(input_mem_rdata0), 
.ReadBus2(input_mem_rdata1), 
.ReadAddress1(input_mem_raddr0), 
.ReadAddress2(input_mem_raddr1),  
.WriteBus(128'b0)

);

memory output_memory_u0
(
.clock(clock),
.WE(output_mem_WE),
.WriteAddress(output_mem_waddr), 
.ReadBus1(), 
.ReadBus2(), 
.ReadAddress1(16'b0), 
.ReadAddress2(16'b0),  
.WriteBus(output_mem_wdata) 
);

endmodule

