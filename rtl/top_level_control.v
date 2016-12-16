module top_level_control
(

//input---------------------------------
input clock, 
input reset,
input new_image_pulse, 
input input_mem_done, 
input scratch_mem_overflow_fault, 
input output_mem_overflow_fault, 

input histogram_computation_done, 
input cdf_done, 
input divider_done, 

//output---------------------------------
output reg histogram_start_pulse, 
output reg cdf_start_pulse, 
output reg divider_start_pulse, 
output reg histogram_en,
output reg cdf_en, 
output reg divider_en, 
output reg image_done_pulse, 
output reg input_mem_read_finished   
); 


parameter [2:0]
S0 = 3'b000, 
S1 = 3'b001, 
S2 = 3'b010, 
S3 = 3'b011, 
S4 = 3'b100, 
S5 = 3'b101, 
S6 = 3'b110, 
S7 = 3'b111; 

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

    //defaults
    histogram_start_pulse = 0; 
    cdf_start_pulse = 0 ; 
    divider_start_pulse = 0; 
    image_done_pulse = 0; 
    case(current_state)
    S0 : 
    begin

       if(reset)
            next_state = S0; 
        else if(new_image_pulse)
            next_state = S1;  
    end
    S1 : 
    begin
       input_mem_read_finished = 0 ; 
       histogram_start_pulse = 1;
       if(reset)
            next_state = S0; 
        else
            next_state = S2;   
    end
    S2 : 
    begin   
        histogram_en = 1; 
        cdf_en = 0; 
        divider_en = 0; 

        if(reset)
            next_state = S0; 
        else if(input_mem_done == 1'b0 && histogram_computation_done == 1'b0)
            next_state = S2; 
        else if(histogram_computation_done == 1'b1) 
            next_state = S3; 
    end
    S3 : 
    begin
        input_mem_read_finished = 1;  
        cdf_start_pulse = 1; 
        if(reset)
            next_state = S0; 
        else
            next_state = S4;  
    end
    S4 : 
    begin
        cdf_start_pulse = 0; 
        histogram_en = 0; 
        cdf_en = 1; 
        divider_en = 0; 
        if(reset)
            next_state = S0; 
        else if(scratch_mem_overflow_fault == 0 | cdf_done == 0)
            next_state = S4; 
        else
            next_state = S5; 
    end
    S5 :  
    begin
        divider_start_pulse = 1; 
        if(reset)
            next_state = S0; 
        else
            next_state = S6;  
    end
    S6 :  
    begin
        divider_start_pulse = 0;   
        histogram_en = 0; 
        cdf_en = 0; 
        divider_en = 1; 
        if(reset)
            next_state = S0; 
        else if(output_mem_overflow_fault == 0 | divider_done == 0)
            next_state = S6; 
        else
            next_state = S7; 
    end
    S7 : 
    begin
        image_done_pulse = 1; 
        next_state = S0; 
    end

    endcase
end


endmodule
