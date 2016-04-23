module divider_mem_ctrl(
input  wire         clk,
input  wire         reset,
input  wire         enable,
input  wire         div_done,
output reg [15:0]   sc_mem_rd_addr1,
output reg [15:0]   sc_mem_rd_addr2,
output reg [15:0]   sc_mem_wt_addr,
output reg          sc_mem_rd_en,
output reg          sc_mem_wt_en,
output reg          sc_mem_rd_done,
output reg          sc_mem_wt_done
);

//ALL FSM STATE PARAMETERS
parameter
  IDLE           = 3'b000,
  FIRST_RD       = 3'b001,
  WAITFORDIV_RD  = 3'b010,
  NEXT_RD        = 3'b011,
  COMPLETE_RD    = 3'b100,
  WAITFORDIV_WT  = 3'b101,
  WRITE          = 3'b110,
  COMPLETE_WT    = 3'b111;
  
  
reg   [2:0]   rd_state;
reg   [2:0]   wt_state;
reg   [2:0]   next_rd_state;
reg   [2:0]   next_wt_state;
reg   [15:0]  next_sc_mem_rd_addr1;
reg   [15:0]  next_sc_mem_rd_addr2;
reg   [15:0]  next_sc_mem_wt_addr;
reg           next_sc_mem_rd_en;
reg           next_sc_mem_wt_en;
reg           next_sc_mem_rd_done;
reg           next_sc_mem_wt_done;
reg   [6:0]   rd_line_count;
reg   [6:0]   wt_line_count;
reg   [6:0]   next_rd_line_count;
reg   [6:0]   next_wt_line_count;

//Moore output updates
always @(posedge clk) begin

  if(reset) begin
    rd_state            <= IDLE;
	wt_state            <= IDLE;
	sc_mem_rd_en        <= 1'b0;
	sc_mem_wt_en        <= 1'b0;
	sc_mem_rd_done      <= 1'b0;
	sc_mem_wt_done      <= 1'b0;
	rd_line_count       <= 7'd0;
	wt_line_count       <= 7'd0;
  end
  else begin
    rd_state            <= next_rd_state;
	wt_state            <= next_wt_state;
	sc_mem_rd_addr1     <= next_sc_mem_rd_addr1;
	sc_mem_rd_addr2     <= next_sc_mem_rd_addr2;
	sc_mem_wt_addr      <= next_sc_mem_wt_addr;
	sc_mem_rd_en        <= next_sc_mem_rd_en;
	sc_mem_wt_en        <= next_sc_mem_wt_en;
	sc_mem_rd_done      <= next_sc_mem_rd_done;
	sc_mem_wt_done      <= next_sc_mem_wt_done;
	rd_line_count       <= next_rd_line_count;
	wt_line_count       <= next_wt_line_count;
  end
end

//FSM LOGIC TO READ FROM SCRATCH MEM
always @(*) begin

case(rd_state)

    //IDLE state after reset and read completion
    IDLE:begin
        next_sc_mem_rd_done  =  1'b0;
		next_sc_mem_rd_en    =  1'b0;
		next_rd_line_count   =  7'd0;
		
		if(enable) begin
		   next_rd_state  =   FIRST_RD;
		end
		else begin
		   next_rd_state  =   IDLE;
		end
	end
	
	//State entered only for the first read
	FIRST_RD:begin
		next_sc_mem_rd_addr1 =  16'd64;
		next_sc_mem_rd_addr2 =  16'd65;
		next_sc_mem_rd_en    =  1'b1;
		next_rd_line_count   =  7'd1;
		next_rd_state        =  WAITFORDIV_RD;
	end
	
	//State to wait while divider is running 
	WAITFORDIV_RD:begin
		next_sc_mem_rd_en    =  1'b0;
		
		if(div_done && (rd_line_count < 7'd62)) begin
		   next_rd_state  =  NEXT_RD;
		end
		else if(div_done && (rd_line_count > 7'd62)) begin
		   next_rd_state  =  COMPLETE_RD;
		end
		else begin
		   next_rd_state  =  WAITFORDIV_RD;
		end
	end
	
	//State to read from scratch after 1st read
	NEXT_RD:begin
	    next_sc_mem_rd_addr1 =  sc_mem_rd_addr1 + 2;
		next_sc_mem_rd_addr2 =  sc_mem_rd_addr2 + 2;
		next_sc_mem_rd_en    =  1'b1;
		next_rd_line_count   =  rd_line_count + 2;
		next_rd_state        =  WAITFORDIV_RD;
	end
	
	//All cdf values read and division is complete
    //on last read cdf values
	COMPLETE_RD:begin
	    next_sc_mem_rd_done  =  1'b1;
		next_rd_state        =  IDLE;
	end
endcase
end



//FSM LOGIC TO WRITE TO SCRATCH MEM
always @(*) begin

case(wt_state)

    //IDLE state after reset and write completion
    IDLE:begin
        next_sc_mem_wt_done  =  1'b0;
		next_sc_mem_wt_en    =  1'b0;
		next_sc_mem_wt_addr  =  16'd128;
		next_wt_line_count   =  7'd0;
		
		if(enable) begin
		   next_wt_state  =   WAITFORDIV_WT;
		end
		else begin
		   next_wt_state  =   IDLE;
		end
	end

	//State to wait while divider is running 
	WAITFORDIV_WT:begin
		next_sc_mem_wt_en    =  1'b0;
		
		if(div_done && (wt_line_count < 7'd63)) begin
		   next_wt_state  =  WRITE;
		end
		else if(div_done && (wt_line_count >= 7'd63)) begin
		   next_wt_state  =  COMPLETE_WT;
		end
		else begin
		   next_wt_state  =  WAITFORDIV_WT;
		end
	end
	
	//State to generate write en and wr addr
	WRITE:begin
		next_sc_mem_wt_addr  =  sc_mem_wt_addr + 1;
		next_sc_mem_wt_en    =  1'b1;
		next_wt_line_count   =  wt_line_count + 1;
		next_wt_state        =  WAITFORDIV_WT;
	end
	
    //All div values written and division is complete
    //on last read cdf values
	COMPLETE_WT:begin
	    next_sc_mem_wt_done  =  1'b1;
		next_wt_state        =  IDLE;
	end
endcase
end

endmodule
