//--------------------------------------------
// Datapath functionality for cdf.
// Author : Kaushik Gopalakrishnan
// Rev : 01
// cdf_datapath.v
//--------------------------------------------

module cdf_datapath (clk, reset, scratchmem_input1, scratchmem_input2, read_first_value_in, scratch_mem_read_ready_in, cdf_computation_done_in, read_next_value_in, cdf_done_in,  WE, WriteAddress, WriteBus, ReadAddress1, ReadAddress2, cdf_min);

// inputs
input clk;
input reset;

// outputs
output WE;
output [15:0] WriteAddress;
output [127:0] WriteBus;
output [15:0] ReadAddress1;
output [15:0] ReadAddress2;
output [31:0] cdf_min;


input [127:0] scratchmem_input1;
input [127:0] scratchmem_input2;
input read_first_value_in;
input read_next_value_in;
input scratch_mem_read_ready_in;
input cdf_computation_done_in;
input cdf_done_in;

// output reg declarations
reg WE;
reg [15:0] WriteAddress;
reg [127:0] WriteBus;
reg [15:0] ReadAddress1;
reg [15:0] ReadAddress2;
reg [31:0] cdf_min; 
reg read_first_value;
reg scratch_mem_read_ready;
reg cdf_computation_done;
reg cdf_done;
reg read_next_value;
reg [127:0] scratchmem_data1;
reg [127:0] scratchmem_data2;
wire [31:0] histogram[0:7];
// Not using array here since arrays are not displayed on GTKWave vcd waveform
reg [31:0] cdf0;
reg [31:0] cdf1;
reg [31:0] cdf2;
reg [31:0] cdf3;
reg [31:0] cdf4;
reg [31:0] cdf5;
reg [31:0] cdf6;
reg [31:0] cdf7;
reg [31:0] cdf_prev;

// flop the inputs
always @(posedge clk)
begin
	if (reset) begin
		scratchmem_data1 <= 0;
		scratchmem_data2 <= 0;
		read_first_value <= 0;
		read_next_value <= 0;
		cdf_computation_done <= 0;
		cdf_done <= 0;
	end
	else begin
		scratchmem_data1 <= scratchmem_input1;
		scratchmem_data2 <= scratchmem_input2;
		read_first_value <= read_first_value_in;
		scratch_mem_read_ready <= scratch_mem_read_ready_in;
		read_next_value <= read_next_value_in;
		cdf_computation_done <= cdf_computation_done_in;
		cdf_done <= cdf_done_in;
	end
end

// Use scratchmem inputs as histogram. Requires efficient way of computing cdf					
assign histogram[0] = scratchmem_data1[127:96];
assign histogram[1] = scratchmem_data1[95:64];
assign histogram[2] = scratchmem_data1[63:32];
assign histogram[3] = scratchmem_data1[31:0];
assign histogram[4] = scratchmem_data2[127:96];
assign histogram[5] = scratchmem_data2[95:64];
assign histogram[6] = scratchmem_data2[63:32];
assign histogram[7] = scratchmem_data2[31:0];
		      	
		      	
// Read Address generator for CDF
always @(posedge clk)
begin
    if(reset)
    begin
		ReadAddress1 <= 16'd0;	// some arbitrary address
		ReadAddress2 <= 16'd1;
    end
	else if (read_first_value == 1'b1) 
    begin
		ReadAddress1 <= 16'd0;
		ReadAddress2 <= 16'd1;

	end
    else if (read_next_value == 1'b1)
    begin
		ReadAddress1 <= ReadAddress1 + 16'd2;
		ReadAddress2 <= ReadAddress2 + 16'd2;
    end
end

reg cdf_select; 


always @(posedge clk)
begin
    if(reset)
    begin
        cdf_select <= 1'b0;  
    end
    else if(cdf_computation_done)
    begin
        cdf_select <= !cdf_select; 
    end
end

always @(posedge clk)
begin
    if(reset)
    begin
		WE <= 1'b0;
        WriteBus<= 16'b0; 
		WriteAddress <= 128'b0;
    end
    else if (read_first_value)
    begin
		WriteAddress <= 16'd63;
    end
	else if (cdf_computation_done) 
    begin
		WriteAddress <= WriteAddress + 16'd1;
        if(cdf_select == 1'b0)
            WriteBus <= {cdf0,cdf1,cdf2,cdf3};
        else
            WriteBus <= {cdf4,cdf5,cdf6,cdf7};
		WE <= 1'b1;
	end
    else 
    begin
		WE <= 1'b0;
    end
end		

// Compute cdf. Store the last cdf to be re-used in next iteration.
// We don't have to worry about carry_out while adding, because it automatically stored within the 32-bit result. 
// The largest value of histogram = 8294400 which can be represented in 24 bits. 
always @(posedge clk)
begin
	// start with a zero cdf_prev
	if (reset) begin
		cdf_prev <= 32'd0;
	end	
	else if (scratch_mem_read_ready) begin
		cdf0 <= cdf_prev + histogram[0];
		cdf1 <= cdf_prev + histogram[0] + histogram[1];
		cdf2 <= cdf_prev + histogram[0] + histogram[1] + histogram[2];
		cdf3 <= cdf_prev + histogram[0] + histogram[1] + histogram[2] + histogram[3];
		cdf4 <= cdf_prev + histogram[0] + histogram[1] + histogram[2] + histogram[3] + histogram[4];
		cdf5 <= cdf_prev + histogram[0] + histogram[1] + histogram[2] + histogram[3] + histogram[4] + histogram[5];
		cdf6 <= cdf_prev + histogram[0] + histogram[1] + histogram[2] + histogram[3] + histogram[4] + histogram[5] + histogram[6];
		cdf7 <= cdf_prev + histogram[0] + histogram[1] + histogram[2] + histogram[3] + histogram[4] + histogram[5] + histogram[6] + histogram[7];
	end
	else if (cdf_computation_done) begin
		cdf_prev <= cdf7;
	end
end						
	
always @(posedge clk)
begin
    if(reset)
    begin
        cdf_min <= 32'b0; 
    end
    if(WE == 1'b1 && cdf_min == 32'b0)
    begin
        if (WriteBus[127:96] != 32'b0)
            cdf_min <= WriteBus[128:96]; 
        else if (WriteBus[95:64] !=32'b0)
            cdf_min <= WriteBus[95:64]; 
        else if (WriteBus[63:32] !=32'b0)
            cdf_min <= WriteBus[63:32]; 
        else if (WriteBus[31:0] !=32'b0)
            cdf_min <= WriteBus[31:0]; 
    end
end


endmodule						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
