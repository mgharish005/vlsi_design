module histogram_control
(
//input---------------------------------
input clock, 
input reset,
input start_histogram, 
input input_memory_read_finished, 
input all_pixel_written,
input all_lines_written,

//output---------------------------------
output reg set_read_address_input_mem, 
output reg set_read_address_scratch_mem, 
output reg set_write_address_scratch_mem, 
output reg shift_scratch_memory_rw_address,
output reg read_data_ready_input_mem, 
output reg histogram_computation_done,   
output reg extra_writes_en,   
output reg read_data_ready_scratch_mem  
); 


parameter [3:0]
S0 = 4'b0000, 
S1 = 4'b0001, 
S2 = 4'b0010, 
S3 = 4'b0011, 
S4 = 4'b0100, 
S5 = 4'b0101, 
S6 = 4'b0110, 
S7 = 4'b0111, 
S8 = 4'b1000, 
S9 = 4'b1001, 
S10 = 4'b1010, 
S11 = 4'b1011; 


reg [3:0] current_state; 
reg [3:0] next_state; 

always@(posedge clock)
begin
    if(reset)
    begin
        current_state <= S0; 
    end
    else
    begin
        current_state <= next_state; 
    end
end

always@(*)
begin
    set_read_address_input_mem = 1'b0; 
    set_read_address_scratch_mem = 1'b0; 
    set_write_address_scratch_mem = 1'b0; 
    shift_scratch_memory_rw_address = 1'b0; 
    read_data_ready_input_mem = 1'b0; 
    read_data_ready_scratch_mem = 1'b0; 
    extra_writes_en = 1'b0; 

    case(current_state)
    S0 :
    //starting stat 
    begin
        //reset control parameters (local reset) ?
        if(start_histogram)
            next_state = S1; 
        else
            next_state = S0; 
    end
    S1 :
    //set read address
    begin
        set_read_address_input_mem = 1'b1; 
        next_state = S2; 
    end
    S2 : 
    //empty clock 
    begin
        next_state = S3; 
    end
    S3 : 
    //empty clock 
    begin
        next_state = S4; 
    end
    S4 : 
    //empty clock - read from input memory
    begin
        read_data_ready_input_mem = 1'b1; 
        if(input_memory_read_finished == 1)
        begin
            next_state = S11; // go to complete writes
        end
        else
        begin
            histogram_computation_done = 0; 
            next_state = S5; 
        end
    end
    S5 : 
    begin
    //take each pixel and compute scratch memory address and set read address (from scratch memory)
        set_read_address_scratch_mem = 1'b1; 
        next_state = S6; 
    end 
    S6 : 
    //empty clock 
    begin
        next_state = S7; 
    end
    S7 : 
    //empty clock 
    begin
        next_state = S8; 
    end
    S8 : 
    //empty clock 
    begin
        read_data_ready_scratch_mem = 1'b1; 
        next_state = S9; 
    end
    S9 : 
    //for write, set write addresses, WE, wdata
    begin
        set_write_address_scratch_mem = 1'b1; 
        next_state = S10; 
    end  
    S10 : 
    //shift the rw_memory array, offset and check if all pixel done
    begin
        shift_scratch_memory_rw_address = 1'b1; 
        if(all_pixel_written)
            next_state = S1; 
        else
            next_state = S5;  
    end  
    S11: 
    //write zeros to those lines which have not been written. 
    begin
        if(all_lines_written)
        begin
            histogram_computation_done = 1; 
            next_state = S0; 
        end
        else
        begin
            histogram_computation_done = 0; 
            next_state = S11; 
            extra_writes_en = 1; 
        end
    end
    default : 
    begin
        $display("[histogram_control] @%0tns  Invalid state", $stime);
        next_state = S0; 
    end
    endcase
end
endmodule
