//--------------------------------------------
// Control functionality for cdf.
// Author : Kaushik Gopalakrishnan
// Rev : 01
// cdf_control.v
//--------------------------------------------

module cdf_control(clk, reset, cdf_start_in, read_first_value, scratch_mem_read_ready, cdf_computation_done, cdf_done);

parameter WAIT = 0, START = 1, READ_READY = 2, COMPUTE = 3, WRITE = 4, IMAGE_DONE = 5;

// inputs
input clk;
input reset;
input cdf_start_in;

// outputs
output cdf_done;

reg cdf_start;
reg cdf_done;
reg cdf_done_out;
reg cdf_computation_done;
reg cdf_computation_done_out;
reg scratch_mem_read_ready;
reg scratch_mem_read_ready_out;

wire cdf_start_in;

// Variables
reg [1:0] state;
reg nextState;
reg [7:0] count;


// Flop inputs
always @(posedge clk)
begin
	cdf_start <= cdf_start_in;
end

// Flop outputs
always @(posedge clk)
begin
	cdf_done <= cdf_done_out;
	read_first_value <= read_first_value_out;
	cdf_computation_done <= cdf_computation_done_out;
	scratch_mem_read_ready <= scratch_mem_read_ready_out;
end	


// Counter of number of lines of histogram (usually 64)
// Also update state to nextState at each posedge of clk
always @(posedge clk) begin
	if(reset) begin
		state <= WAIT;
	    count <= 0;
  	end
  else begin
	  state <= nextState;
	  if (reset_counter == 1'b1)
		  count <= 8'd0;
	  else	
		  count <= count + 1;
  end	
end

// Overall cdf counter
always @(posedge clk) begin
	if (reset) begin
		cdf_counter <= 0;
	end
	else begin
		if (reset_cdf_counter == 1'b1) begin
			cdf_counter <= 8'd0;
		end		
		else begin
			cdf_counter <= cdf_counter + 1;
		end	
	end	

end

	
// State Machine
always @(*)
	begin
		read_first_value_out = 1'b0;
		reset_counter = 1'b0;
		cdf_computation_done_out = 1'b0;
		cdf_done_out = 1'b0;
		scratch_mem_read_ready_out = 1'b0;
	
		case (state)
			WAIT : 
			begin
				if (cdf_start) 
					nextState = START;
				else
					nextState = WAIT;
			end

			START :
			begin
				if (cdf_counter == 8'd0) begin
					read_first_value_out = 1'b1;
				end
				else begin
					read_next_value = 1'b1;
				end		
				nextState = EMPTY1;
			end

			EMPTY1 :
			begin
				nextState = READ_READY;
				reset_counter = 1'b1;
			end
				
			READ_READY :
			begin
				read_first_value_out = 1'b0;
				scratch_mem_read_ready_out = 1'b1;
				nextState = COMPUTE;
				reset_counter = 1'b0;
				end	
			end
			
			COMPUTE :
			begin
				scratch_mem_read_ready_out = 1'b0;
				if (count == 8'd1) begin
					nextState = WRITE;
					reset_counter = 1'b1;
				end	
				else begin
					nextState = COMPUTE;
					reset_counter = 1'b0;
				end
			end

			WRITE :
			begin
				cdf_computation_done = 1'b1;
				if (cdf_count == 8'd63) begin
					nextState = IMAGE_DONE;
					reset_counter = 1'b1;
				end
				else begin
					if (count == 8'd1) begin
						nextState = WRITE;
						reset_counter = 1'b1;
					end
					else begin
						nextState = START;
						reset_counter = 1'b0;
					end			
				end							 			 

			IMAGE_DONE :
			begin
				reset_counter = 1'b1;
				cdf_done_out = 1'b1;
				nextState = WAIT;
			end
		endcase	
	end										 		 						
								
endmodule												
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
														
