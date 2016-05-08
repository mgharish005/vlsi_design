module img_map_ctrl(
input  wire          clk,
input  wire          reset,
input  wire          enable,
input  wire          div_sc_mem_wt_done,
input  wire [127:0]  inp_mem_rd_data1,
input  wire [127:0]  inp_mem_rd_data2,
input  wire [127:0]  sc_mem_rd_data1,
input  wire [127:0]  sc_mem_rd_data2,
output reg  [15:0]   inp_mem_rd_addr1,
output reg  [15:0]   inp_mem_rd_addr2,
output reg  [15:0]   sc_mem_rd_addr1,
output reg  [15:0]   sc_mem_rd_addr2,
output reg  [127:0]  out_mem_wt_data,
output reg  [15:0]   out_mem_wt_addr,
output reg           out_mem_wt_en,
output reg           output_wt_done
);


//ALL FSM STATE PARAMETRS
parameter
  IDLE          = 4'b0000,
  FIRST_INP_RD  = 4'b0001,
  IDLE_RD1      = 4'b0010,
  IDLE_RD2      = 4'b0011,
  NEXT_INP_RD   = 4'b0100,
  SCMEM_RD      = 4'b0101,
  IDLE_RD3      = 4'b0110,
  IDLE_RD4      = 4'b0111,
  OP_MAP        = 4'b1000,
  WTDATA_1      = 4'b1001,
  IDLE_WT1      = 4'b1010,
  IDLE_WT2      = 4'b1011,
  WTDATA_2      = 4'b1100,
  IDLE_WT3      = 4'b1101,
  IDLE_WT4      = 4'b1110,
  COMPLETE      = 4'b1111;
  
  
reg   [3:0]   state;
reg   [6:0]   inp_rd_line_count;
reg   [6:0]   out_wt_line_count;
reg   [3:0]   pixel_map_count;
reg   [7:0]   index_range_select;
reg   [1:0]   offset_range_select0;
reg   [1:0]   offset_range_select1;
reg   [127:0] out_wt_data1;
reg   [127:0] out_wt_data2;

reg   [3:0]   next_state;
reg   [6:0]   next_inp_rd_line_count;
reg   [6:0]   next_out_wt_line_count;
reg   [3:0]   next_pixel_map_count;
reg   [15:0]  next_inp_mem_rd_addr1;
reg   [15:0]  next_inp_mem_rd_addr2;
reg   [15:0]  next_sc_mem_rd_addr1;
reg   [15:0]  next_sc_mem_rd_addr2;
reg   [7:0]   next_index_range_select;
reg   [1:0]   next_offset_range_select0;
reg   [1:0]   next_offset_range_select1;
reg   [15:0]  next_out_mem_wt_addr;
reg           next_out_mem_wt_en;
reg   [127:0] next_out_mem_wt_data;
reg           next_output_wt_done;

//Moore output updates
always @(posedge clk) begin

  if(reset) begin
	state                  <=  IDLE;
	inp_rd_line_count      <=  7'd0;
	out_wt_line_count      <=  7'd0;
	pixel_map_count        <=  7'd0;
	index_range_select     <=  7'd0;
	offset_range_select0   <=  2'd0;
	offset_range_select1   <=  2'd0;
	out_mem_wt_en          <=  1'b0;
	out_mem_wt_data        <=  128'd0;
	output_wt_done         <=  1'b0;
  end
  else begin
	state                  <=  next_state;
	inp_rd_line_count      <=  next_inp_rd_line_count;
	out_wt_line_count      <=  next_out_wt_line_count;
	pixel_map_count        <=  next_pixel_map_count;
	inp_mem_rd_addr1       <=  next_inp_mem_rd_addr1;
	inp_mem_rd_addr2       <=  next_inp_mem_rd_addr2;
	sc_mem_rd_addr1        <=  next_sc_mem_rd_addr1;
	sc_mem_rd_addr2        <=  next_sc_mem_rd_addr2;
	index_range_select     <=  next_index_range_select;
	offset_range_select0   <=  next_offset_range_select0;
	offset_range_select1   <=  next_offset_range_select1;
	out_mem_wt_addr        <=  next_out_mem_wt_addr;
	out_mem_wt_en          <=  next_out_mem_wt_en;
	out_mem_wt_data        <=  next_out_mem_wt_data;
	output_wt_done         <=  next_output_wt_done;
  end
end

//FSM LOGIC TO CONTROL IMAGE MAPPING
always @(*) begin

case(state)

    //IDLE state after reset and/or output write completion
    IDLE:begin
		next_inp_rd_line_count    <=  7'd0;
		next_out_wt_line_count    <=  7'd0;
		next_pixel_map_count      <=  7'd0;
		next_index_range_select   <=  8'd0;
		next_offset_range_select0 <=  2'd0;
		next_offset_range_select1 <=  2'd0;
		next_out_mem_wt_addr      <=  16'd0;
		next_out_mem_wt_en        <=  1'b0;
		next_out_mem_wt_data      <=  128'd0;
		next_output_wt_done       <=  1'b0;
		
		if(div_sc_mem_wt_done) begin
			next_state    <=   FIRST_INP_RD;
		end
		else begin
			next_state    <=   IDLE;
		end
	end
	
	//First state to read from input memory
	FIRST_INP_RD:begin
		next_inp_mem_rd_addr1   <=  16'd0;
		next_inp_mem_rd_addr2   <=  16'd1;
		next_inp_rd_line_count  <=  7'd2;
		next_state              <=  IDLE_RD1;
	end
	
	//Idle state 1 for input mem rd data
	IDLE_RD1:begin
		next_state   <=  IDLE_RD2;
	end
	
	//Idle state 2 for input mem rd data
	IDLE_RD2:begin
		next_state   <=  SCMEM_RD;
	end
	
	//State to set scratch read address
	//based on pixel value from input mem
	SCMEM_RD:begin
		next_sc_mem_rd_addr1   	  <=  {10'b0000000000, inp_mem_rd_data1[index_range_select+7 : index_range_select+2]};
		next_sc_mem_rd_addr2 	  <=  {10'b0000000000, inp_mem_rd_data2[index_range_select+7 : index_range_select+2]};
		next_offset_range_select0 <=  inp_mem_rd_data1[index_range_select+1 : index_range_select];
		next_offset_range_select1 <=  inp_mem_rd_data2[index_range_select+1 : index_range_select];
		next_pixel_map_count      <=  pixel_map_count + 7'd2;
		next_state                <=  IDLE_RD3;
	end
	
	//Idle state 3 for sc mem rd data
	IDLE_RD3:begin
		next_state    <=   IDLE_RD4;
	end
	
	//Idle state 4 for sc mem rd data
	IDLE_RD4:begin
		next_state    <=   MAPPING;
	end
	
	//State to map and form the output
	//wire data
	OP_MAP:begin
		out_wt_data1[index_range_select+7 : index_range_select]   <=  sc_mem_rd_data1[(offset_range_select0<<5)+7 :(offset_range_select0<<5)];
		out_wt_data2[index_range_select+7 : index_range_select]   <=  sc_mem_rd_data2[(offset_range_select1<<5)+7 :(offset_range_select1<<5)];
		next_index_range_select     <=  index_range_select + 8'd8;
		
		if(pixel_map_count >= 7'd64) begin
			next_state    <=  WTDATA_1;
		end
		else begin
			next_state    <=  SCMEM_RD;
		end
		
	end
	
		
	//Write state for first line
	WTDATA_1:begin
		next_out_mem_wt_data        <=  out_wt_data1;
		next_out_mem_wt_addr        <=  {9'b000000000, out_wt_line_count};
		next_out_mem_wt_en          <=  1'b1;
		next_out_wt_line_count      <=  out_wt_line_count + 7'd1;
		next_state                  <=  IDLE_WT1;
	end
	
	//Idle state for write to finish
	IDLE_WT1:begin
		next_out_mem_wt_en  <=  1'b0;
		next_state          <=  IDLE_WT2;
	end
	
	//Idle state for write to finish
	IDLE_WT2:begin
		next_state    <=  WTDATA_2;
	end
	
	//Write state for next line
	WTDATA_2:begin
		next_out_mem_wt_data        <=  out_wt_data2;
		next_out_mem_wt_addr        <=  {9'b000000000, out_wt_line_count};
		next_out_mem_wt_en          <=  1'b1;
		next_out_wt_line_count      <=  out_wt_line_count + 7'd1;
		next_state                  <=  IDLE_WT3;
	end
	
	//Idle state for write to finish
	IDLE_WT3:begin
		next_out_mem_wt_en   <=  1'b0;
		next_state           <=  IDLE_WT4;
	end
	
	//Idle state for write to finish
	IDLE_WT4:begin
	
	if(out_wt_line_count == 7'd64) begin
		next_state    <=  COMPLETE;
	end
	else begin
		next_state    <=  NEXT_INP_RD;
	end
	end
	
	//State for next input reads
	NEXT_INP_RD:begin
		next_inp_mem_rd_addr1   <=   inp_mem_rd_addr1 + 16'd2;
		next_inp_mem_rd_addr2   <=   inp_mem_rd_addr2 + 16'd2;
		next_inp_rd_line_count  <=   inp_rd_line_count + 7'd2;
		next_state              <=   IDLE_RD1;
	end
	
	//Completion state to report 
	//output image map done
	COMPLETE:begin
		next_output_wt_done  <=  1'b1;
		next_state           <=  IDLE;
	end
endcase
end

endmodule
	