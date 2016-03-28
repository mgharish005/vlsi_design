//--------------------------------------------
// Datapath functionality for cdf.
// Author : Kaushik Gopalakrishnan
// Rev : 01
// cdf_memcontroller.v
//--------------------------------------------
module cdf_memcontroller (clk, reset, WE, WriteAddress,ReadAddress1,ReadAddress2, WriteBus, ReadBus1,ReadBus2);

// inputs
input clk;
input reset;
input [127:0] ReadBus1;
input [127:0] ReadBus2;

// outputs
output WE;
output [15:0] WriteAddress;
output [127:0] WriteBus;
output [15:0] ReadAddress1;
output [15:0] ReadAddress2;

// declarations



// startup conditions
always @(posedge clk)
	begin
		if(reset)
			begin
				WE <= 1'b0;
				ReadAddress1 <= 16'd400;
				ReadAddress2 <= 16'd401;
				WriteAddress <= 0;
				WriteBus < = 0;			
			end
		else	// flop outputs
			begin
				WE <= WE_gen;
				ReadAddress1 <= ReadAddress1_gen;
				ReadAddress2 <= ReadAddress2_gen;
				WriteAddress <= WriteAddress_gen;
				WriteBus <= WriteBus_gen; 
			end
	end			
	
// Actual address generation logic
always @(*)
	begin
		if(state == S0)
			begin
				ReadAddress1_gen = 16'd64;
				ReadAddress2_gen = 16'd65;
				






























