//--------------------------------------------
// Datapath functionality for cdf.
// Author : Kaushik Gopalakrishnan
// Rev : 01
// cdf_control.v
//--------------------------------------------

module cdf_control(clk, reset, input1, input2, state);

parameter START = 0, COMPUTE = 1, WRITE = 2, IMAGE_DONE = 3, STOP = 4;

// inputs
input clk;
input reset;
input input1;
input input2;

// outputs
output [1:0] state;

reg [1:0] state;
reg nextState;
reg [7:0] count;

always @(posedge clk)
	begin
		if(reset) begin
			state <= START;
			count <= 0;
			end
		else begin
			state <= nextState;
			count <= count + 1;
		end	
	end
	
// State Machine
always @(*)
	begin
		case (state) 
			START : nextState = COMPUTE;
			COMPUTE : if (count == 31) 
										begin
											nextState = WRITE;
											count = 0;
										end
									else	
										begin
											nextState = COMPUTE;
										end
			WRITE : if (count == 1)
									begin
										nextState = IMAGE_DONE;
										count = 0;
									end
								else
									begin
										nextState	= WRITE;
									end
			IMAGE_DONE : if ( 1/* some input to know there is another image */ )
											 nextState = START;
										 else
										 	 nextState = STOP;
			STOP : nextState = STOP;
			default : $display("Error in selecting correct CDF state");
		endcase	
	end										 		 						
								
endmodule												
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
														
