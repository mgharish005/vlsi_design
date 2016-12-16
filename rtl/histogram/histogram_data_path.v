module histogram_data_path
(

input clock, 
input reset, 

//memory interfaces inputs
input  [127:0] input_memory_rdata0, 
input  [127:0] input_memory_rdata1, 
input  [127:0] scratch_memory_rdata0, 

//memory interfaces outputs
output reg [15:0]  input_memory_address_pointer0, 
output reg [15:0]  input_memory_address_pointer1, 
output reg [15:0]  scratch_memory_address_pointer0,  
output reg write_enable, 
output reg [127:0] scratch_memory_wdata, 
output reg [15:0]  write_address, 
output all_lines_written,

//control interface inputs
input set_read_address_input_mem, 
input set_read_address_scratch_mem, 
input set_write_address_scratch_mem, 
input shift_scratch_memory_rw_address, 
input read_data_ready_input_mem, 
input read_data_ready_scratch_mem,  
input extra_writes_en,

//control interface outputs
output all_pixel_written  

); 


reg first_time ; 
reg [7:0] offset ; 
reg [5:0] counter ; 
reg [255:0] scratch_memory_rw_address ; 
reg [255:0] offset_reg ; 
reg [127:0] local_scratch_memory_data ; 
reg [127:0] wdata ; 
reg [5:0]   has_nz_data_counter;
reg [63:0] has_nz_data;

wire scratch_memory_read_out_data_is_not_x ; 
wire temp; 


//address pointer logic for input_memory read
always@(posedge clock)
begin
    if(reset)
    begin
        input_memory_address_pointer0 <= 16'b0;
        input_memory_address_pointer1 <= 16'b1;
        first_time <= 1'b1; 
    end
    else
    begin
        if(set_read_address_input_mem)
        begin
            if(!first_time)
            begin
            input_memory_address_pointer0 <= input_memory_address_pointer0 + 16'd2;  
            input_memory_address_pointer1 <= input_memory_address_pointer1 + 16'd2;  
            end
            first_time <= 1'b0; 
        end
    end

end


//address pointer logic for scratch_memory read
always@(posedge clock)
begin
    if(reset)
    begin
        scratch_memory_address_pointer0 <= 16'b0;
        offset <= 8'b0;
    end

    else
    begin
        if(set_read_address_scratch_mem)
        begin
            scratch_memory_address_pointer0 <= {8'b0, scratch_memory_rw_address[7:0]};
        //  offset  <= {8'b0, offset_reg[7:0]}; //commented out for lint 
            offset  <=  offset_reg[7:0]; 
        end
    end
end


assign all_pixel_written = counter[5];  

//pixel process counter
always@(posedge clock)
begin
    if(reset | set_read_address_input_mem)
    begin
        counter <= 6'b0; 
    end
    else if(set_write_address_scratch_mem)
    begin
            counter <= counter + 1;  
    end
end

//get offset_reg
always@(posedge clock)
begin
    if(reset)
    begin
        offset_reg  <= 256'b0;  
    end
    else if(read_data_ready_input_mem) 
    begin 
        offset_reg <= {{input_memory_rdata1 & 128'h03030303_03030303_03030303_03030303}, {input_memory_rdata0 & 128'h03030303_03030303_03030303_03030303} }; 
    end
    else if(shift_scratch_memory_rw_address)
    begin
        offset_reg                <= (offset_reg >> 8); 
    end
end

//Get bin address for scratch rw. 
always@(posedge clock) 
begin
    if(reset)
    begin
        scratch_memory_rw_address <= 256'b0;  
    end
    else if(read_data_ready_input_mem) 
    begin 
        scratch_memory_rw_address[255:128] <= {input_memory_rdata1[127:120] >> 2,
                                               input_memory_rdata1[119:112] >> 2, 
                                               input_memory_rdata1[111:104] >> 2, 
                                               input_memory_rdata1[103: 96] >> 2, 
                                               input_memory_rdata1[95 : 88] >> 2, 
                                               input_memory_rdata1[87 : 80] >> 2, 
                                               input_memory_rdata1[79 : 72] >> 2, 
                                               input_memory_rdata1[71 : 64] >> 2, 
                                               input_memory_rdata1[63 : 56] >> 2, 
                                               input_memory_rdata1[55 : 48] >> 2, 
                                               input_memory_rdata1[47 : 40] >> 2, 
                                               input_memory_rdata1[39 : 32] >> 2, 
                                               input_memory_rdata1[31 : 24] >> 2, 
                                               input_memory_rdata1[23 : 16] >> 2, 
                                               input_memory_rdata1[15 :  8] >> 2, 
                                               input_memory_rdata1[ 7 :  0] >> 2  
                                               };

        scratch_memory_rw_address[127:  0] <= {input_memory_rdata0[127:120] >> 2,
                                               input_memory_rdata0[119:112] >> 2, 
                                               input_memory_rdata0[111:104] >> 2, 
                                               input_memory_rdata0[103: 96] >> 2, 
                                               input_memory_rdata0[95 : 88] >> 2, 
                                               input_memory_rdata0[87 : 80] >> 2, 
                                               input_memory_rdata0[79 : 72] >> 2, 
                                               input_memory_rdata0[71 : 64] >> 2, 
                                               input_memory_rdata0[63 : 56] >> 2, 
                                               input_memory_rdata0[55 : 48] >> 2, 
                                               input_memory_rdata0[47 : 40] >> 2, 
                                               input_memory_rdata0[39 : 32] >> 2, 
                                               input_memory_rdata0[31 : 24] >> 2, 
                                               input_memory_rdata0[23 : 16] >> 2, 
                                               input_memory_rdata0[15 :  8] >> 2, 
                                               input_memory_rdata0[ 7 :  0] >> 2  
                                               };
    end    
    else if(shift_scratch_memory_rw_address)
    begin
        scratch_memory_rw_address <= (scratch_memory_rw_address >> 8); 
    end 
end 

assign temp = |(1 << scratch_memory_address_pointer0 & has_nz_data); 
assign scratch_memory_read_out_data_is_not_x = (read_data_ready_scratch_mem) ? |(1<< scratch_memory_address_pointer0 & has_nz_data) : 1'b0;  

//read from scratch memory
always@(posedge clock) 
begin
    if(reset)
    begin
        local_scratch_memory_data <= 128'b0;  
    end
    else if(read_data_ready_scratch_mem)
    begin
        if(scratch_memory_read_out_data_is_not_x)
        begin
            local_scratch_memory_data <= scratch_memory_rdata0; 
        end
        else
        begin
            local_scratch_memory_data <= 128'b0; 
        end
    end     
end 

reg [32:0] a,b,c,d; 
always@(*) 
begin
  //a = scratch_memory_rdata[127:96] + 1'b1; 
  //b = scratch_memory_rdata[95:64]  + 1'b1; 
  //c = scratch_memory_rdata[63:31]  + 1'b1;   
  //d = scratch_memory_rdata[31: 0]  + 1'b1;   

    case({offset,extra_writes_en})
    9'bxxxxxxxx_1 : wdata = 128'b0;  
    9'b00000000_0 : wdata = {{local_scratch_memory_data[127:96] + 1'b1} , local_scratch_memory_data[95:0]};
    9'b00000001_0 : wdata = {local_scratch_memory_data[127:96], {local_scratch_memory_data[95:64] + 1'b1}, local_scratch_memory_data[63:0]};  
    9'b00000010_0 : wdata = {local_scratch_memory_data[127:64], {local_scratch_memory_data[63:32] + 1'b1}, local_scratch_memory_data[31:0]}; 
    9'b00000011_0 : wdata = {local_scratch_memory_data[127:32], {local_scratch_memory_data[31: 0] + 1'b1} };  

    default : wdata = 128'b0; //scratch_memory_rdata0; 
    endcase
end

//local_scratch_rdata process and write
always@(posedge clock) 
begin
    if(reset)
    begin
        write_enable            <= 1'b0; 
        scratch_memory_wdata    <= 128'b0;  
        write_address           <= 16'b0;  
    end
    else if(set_read_address_scratch_mem)
    begin
        write_enable <= 1'b0; 
        scratch_memory_wdata    <= 128'b0;  
        write_address           <= 16'b0;  
    end 

    else if(set_write_address_scratch_mem)
    begin
        write_enable            <= 1'b1; 
        scratch_memory_wdata    <= wdata;  
        write_address           <= {8'b0, scratch_memory_rw_address[7:0]};  
    end
    else if (extra_writes_en && !has_nz_data[0])
    begin
        write_enable            <= 1'b1; 
        scratch_memory_wdata    <= 128'b0;  
        write_address           <= has_nz_data_counter; 
    end
end

always@(posedge clock)
begin
    if(reset)
    begin
        has_nz_data <= 64'b0; 
    end
    else if(set_write_address_scratch_mem)
    begin
        has_nz_data <= has_nz_data | (1<<scratch_memory_rw_address[7:0]); 
    end
    else if(extra_writes_en)
    begin
        has_nz_data <= {has_nz_data,has_nz_data} >> 1; 
    end
end

always@(posedge clock)
begin
    if(reset)
    begin
        has_nz_data_counter <= 6'b0; 
    end
    else if(extra_writes_en)
    begin
        has_nz_data_counter <= has_nz_data_counter + 1'b1; 
    end
end

assign all_lines_written = (has_nz_data_counter==6'd63);
endmodule









