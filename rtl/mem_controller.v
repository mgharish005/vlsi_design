module mem_controller
(
    input clock, 
    input reset, 
    input histogram_en, 
    input cdf_en, 
    input divider_en,
    input image_done_pulse,

    input [16:0] input_mem_depth, 
    input [16:0] scratch_mem_depth, 
    input [16:0] output_mem_depth, 
 
    output reg [127:0] histogram_input_mem_rdata0, 
    output reg [127:0] histogram_input_mem_rdata1, 
    input [15:0] histogram_input_mem_raddr0, 
    input [15:0] histogram_input_mem_raddr1, 

    output reg [127:0] histogram_scratch_mem_rdata0, 
    output reg [127:0] histogram_scratch_mem_rdata1, 
    input [15:0] histogram_scratch_mem_raddr0, 
    input [15:0] histogram_scratch_mem_raddr1, 
    input [15:0] histogram_scratch_mem_waddr, 
    input [127:0] histogram_scratch_mem_wdata, 
    input histogram_scratch_mem_WE, 


    output reg [127:0] cdf_scratch_mem_rdata0, 
    output reg [127:0] cdf_scratch_mem_rdata1, 
    input [15:0] cdf_scratch_mem_raddr0, 
    input [15:0] cdf_scratch_mem_raddr1, 
    input [15:0] cdf_scratch_mem_waddr, 
    input [127:0] cdf_scratch_mem_wdata, 
    input cdf_scratch_mem_WE, 


    output reg [127:0] divider_input_mem_rdata0, 
    output reg [127:0] divider_input_mem_rdata1, 
    input [15:0] divider_input_mem_raddr0, 
    input [15:0] divider_input_mem_raddr1, 
    output reg [127:0] divider_scratch_mem_rdata0, 
    output reg [127:0] divider_scratch_mem_rdata1, 
    input [15:0] divider_scratch_mem_raddr0, 
    input [15:0] divider_scratch_mem_raddr1, 
    input [15:0] divider_scratch_mem_waddr, 
    input [127:0] divider_scratch_mem_wdata, 
    input divider_scratch_mem_WE, 


    input [15:0] divider_output_mem_waddr, 
    input [127:0] divider_output_mem_wdata, 
    input divider_output_mem_WE, 

    input [127:0] final_input_mem_rdata0, 
    input [127:0] final_input_mem_rdata1, 
    output reg [15:0] final_input_mem_raddr0, 
    output reg [15:0] final_input_mem_raddr1, 

    input [127:0] final_scratch_mem_rdata0, 
    input [127:0] final_scratch_mem_rdata1, 
    output reg [15:0] final_scratch_mem_raddr0, 
    output reg [15:0] final_scratch_mem_raddr1,
    output reg [15:0] final_scratch_mem_waddr, 
    output reg [127:0] final_scratch_mem_wdata, 
    output reg final_scratch_mem_WE, 
    output reg [15:0] final_output_mem_waddr, 
    output reg [127:0] final_output_mem_wdata, 
    output reg final_output_mem_WE,  

    output reg input_mem_done, 
    output reg scratch_mem_overflow_fault,
    output reg output_mem_overflow_fault    
); 


always@(posedge clock)
begin
    
casex({reset, histogram_en, cdf_en, divider_en}) 
    4'b1xxx : 
    begin
        histogram_input_mem_rdata0 <= 0; 
        histogram_input_mem_rdata1 <= 0; 
        histogram_scratch_mem_rdata0 <= 0; 
        histogram_scratch_mem_rdata1 <= 0; 
        cdf_scratch_mem_rdata0 <= 0; 
        cdf_scratch_mem_rdata1 <= 0; 
        divider_scratch_mem_rdata0 <= 0; 
        divider_scratch_mem_rdata1 <= 0; 
        final_input_mem_raddr0 <= 0; 
        final_input_mem_raddr1 <= 0; 
        final_scratch_mem_raddr0 <= 0; 
        final_scratch_mem_raddr1 <= 0; 
        final_scratch_mem_waddr <= 0; 
        final_scratch_mem_wdata <= 0; 
        final_scratch_mem_WE <= 0; 
        final_output_mem_waddr <= 0; 
        final_output_mem_wdata <= 0; 
        final_output_mem_WE <= 0; 
    end 
    4'b0100 : 
    begin
        histogram_input_mem_rdata0 <= final_input_mem_rdata0; 
        histogram_input_mem_rdata1 <= final_input_mem_rdata1; 
        final_input_mem_raddr0 <= histogram_input_mem_raddr0; 
        final_input_mem_raddr1 <= histogram_input_mem_raddr1; 

        histogram_scratch_mem_rdata0 <= final_scratch_mem_rdata0; 
        histogram_scratch_mem_rdata1 <= final_scratch_mem_rdata1; 
        final_scratch_mem_raddr0 <= histogram_scratch_mem_raddr0; 
        final_scratch_mem_raddr1 <= histogram_scratch_mem_raddr1; 
        final_scratch_mem_waddr <= histogram_scratch_mem_waddr; 
        final_scratch_mem_wdata <= histogram_scratch_mem_wdata; 
        final_scratch_mem_WE <= histogram_scratch_mem_WE;
    end
    4'b0010 : 
    begin
        cdf_scratch_mem_rdata0 <= final_scratch_mem_rdata0; 
        cdf_scratch_mem_rdata1 <= final_scratch_mem_rdata1; 
        final_scratch_mem_raddr0 <= cdf_scratch_mem_raddr0; 
        final_scratch_mem_raddr1 <= cdf_scratch_mem_raddr1; 
        final_scratch_mem_waddr <= cdf_scratch_mem_waddr; 
        final_scratch_mem_wdata <= cdf_scratch_mem_wdata; 
        final_scratch_mem_WE <= cdf_scratch_mem_WE;
    end
    4'b0001 : 
    begin
        divider_input_mem_rdata0 <= final_input_mem_rdata0; 
        divider_input_mem_rdata1 <= final_input_mem_rdata1; 
        final_input_mem_raddr0 <= divider_input_mem_raddr0; 
        final_input_mem_raddr1 <= divider_input_mem_raddr1; 

        divider_scratch_mem_rdata0 <= final_scratch_mem_rdata0; 
        divider_scratch_mem_rdata1 <= final_scratch_mem_rdata1; 
        final_scratch_mem_raddr0 <= divider_scratch_mem_raddr0; 
        final_scratch_mem_raddr1 <= divider_scratch_mem_raddr1; 
        final_scratch_mem_waddr <= 0; 
        final_scratch_mem_wdata <= 0; 
        final_scratch_mem_WE <= 0; 
        final_output_mem_waddr <= divider_output_mem_waddr; 
        final_output_mem_wdata <= divider_output_mem_wdata; 
        final_output_mem_WE <= divider_output_mem_WE; 
    end
//  default : 
//  begin
//      histogram_scratch_mem_rdata0 <= 127'b0; 
//      histogram_scratch_mem_rdata0 <= 127'b0; 
//      final_scratch_mem_rdata1 <= histogram_scratch_mem_rdata1; 
//      final_scratch_mem_raddr0 <= histogram_scratch_mem_raddr0; 
//      final_scratch_mem_raddr1 <= histogram_scratch_mem_raddr1; 
//      final_scratch_mem_waddr <= histogram_scratch_mem_waddr; 
//      final_scratch_mem_wdata <= histogram_scratch_mem_wdata; 
//      final_scratch_mem_WE <= histogram_scratch_mem_WE;
//  end
    endcase
end

//input address pointer overflow protection
always@(posedge clock)
begin
    if(reset)
    begin
        input_mem_done <= 0; 
    end
    else if(histogram_en)
    begin
        if(histogram_input_mem_raddr1 > input_mem_depth)
        input_mem_done <= 1;  
    end
end

//scratch address pointer overflow protection
always@(posedge clock)
begin
    if(reset)
    begin
    end
    else if(image_done_pulse)
    begin
        scratch_mem_overflow_fault <= 0; 
    end
    else if(histogram_en)
    begin
        if ( (histogram_scratch_mem_raddr1 > scratch_mem_depth) || (histogram_scratch_mem_waddr> scratch_mem_depth) )
            scratch_mem_overflow_fault <= 1; 
        else
            scratch_mem_overflow_fault <= 0; 
    end
    else if(cdf_en)
    begin
        if ( (cdf_scratch_mem_raddr1 > scratch_mem_depth) || (cdf_scratch_mem_waddr> scratch_mem_depth) )
            scratch_mem_overflow_fault <= 1; 
        else
            scratch_mem_overflow_fault <= 0; 
    end
    else if(divider_en)
    begin
        if ( (divider_scratch_mem_raddr1 > scratch_mem_depth) || (divider_scratch_mem_waddr> scratch_mem_depth) )
            scratch_mem_overflow_fault <= 1; 
        else
            scratch_mem_overflow_fault <= 0; 
    end
end

//output address pointer overflow protection
always@(posedge clock)
begin
    if(reset)
    begin
    end
    else if(image_done_pulse)
    begin
        output_mem_overflow_fault <= 0; 
    end
    else if(divider_en)
    begin
        if ( divider_output_mem_waddr > output_mem_depth)
            output_mem_overflow_fault <= 1; 
        else
            output_mem_overflow_fault <= 0; 
    end
end
endmodule
