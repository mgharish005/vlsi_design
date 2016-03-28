//--------------------------------------------
// Datapath functionality for cdf.
// Author : Kaushik Gopalakrishnan
// Rev : 01
// cdf_datapath.v
//--------------------------------------------

module cdf_datapath ( clk,reset,scratchmem_input1,scratchmem_input2,histogram_done,scratchmem_output,cdf_done );

// inputs
input clk;
input reset;
input [127:0] scratchmem_input1;
input [127:0] scracthmem_input2;
input histogram_done;
// some control inputs also needed
		
// outputs
output [127:0] scratchmem_output;
output cdf_done;

reg [127:0] scratchmem_output;
reg cdf_done;
reg [127:0] scratchmem_data1;
reg [127:0] scratchmem_data2;
wire [31:0] histogram[8];
reg [31:0] cdf[8];


// flop the inputs
always @(posedge clk)
	begin
		if (reset || !histogram_done)
			begin
				scratchmem_data1 <= 0;
				scratchmem_data2 <= 0;
			end
		else	
			begin
				scratchmem_data1 <= scratchmem_input1;
				scratchmem_data2 <= scratchmem_input2;
			end
	end
				
// Use scratchmem inputs as histogram. Requires efficient way of computing cdf					
assign histogram[0] = scratchmem_data1[31:0];
assign histogram[1] = scratchmem_data1[63:32];
assign histogram[2] = scratchmem_data1[95:64];
assign histogram[3] = scratchmem_data1[127:96];
assign histogram[4] = scratchmem_data2[31:0];
assign histogram[5] = scratchmem_data2[63:32];
assign histogram[6] = scratchmem_data2[95:64];
assign histogram[7] = scratchmem_data2[127:96];
		      	
// Compute cdf. Store the last cdf to be re-used in next iteration.
// We don't have to worry about carry_out while adding, because it automatically stored within the 32-bit result. 
// The largest value of histogram = 8294400 which can be represented in 24 bits. 
always @(posedge clk)
	begin
		cdf[0] <= histogram[0];
	end							
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
