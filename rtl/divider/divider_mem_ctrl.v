module divider_mem_ctrl(
input  wire         clk,
input  wire         reset,
input  wire         enable,
input  wire         div1_done,
input  wire         div2_done,
input  wire         div3_done,
input  wire         div4_done,
input  wire         div5_done,
input  wire         div6_done,
input  wire         div7_done,
input  wire         div8_done,
output reg [15:0]   sc_mem_rd_addr1,
output reg [15:0]   sc_mem_rd_addr2,
output reg [15:0]   sc_mem_wt_addr,
output reg          sc_mem_rd_data_rdy,
output reg          div_en,
output reg          div_en_D1,
output reg          div_en_D2,
output reg          div_en_D3,
output reg          sc_mem_wt_en,
output reg          sc_mem_rd_done,
output reg          sc_mem_wt_done
);

//ALL FSM STATE PARAMETERS
parameter
  IDLE_RD        = 5'b00000,
  FIRST_RD       = 5'b00001,
  RD_IDLE1       = 5'b00010,
  RD_IDLE2       = 5'b00011,
  RD_RDY         = 5'b00100,
  DIV_EN         = 5'b00101,
  WAITFORDIV_RD  = 5'b00110,
  NEXT_RD        = 5'b00111,
  COMPLETE_RD    = 5'b01000,
  IDLE_WT        = 5'b01001,
  WAITFORDIV_WT  = 5'b01010,
  WRITE1         = 5'b01011,
  WT_IDLE1       = 5'b01100,
  WT_IDLE2       = 5'b01101,
  WRITE2         = 5'b01110,
  WT_IDLE3       = 5'b01111,
  WT_IDLE4       = 5'b10000,
  COMPLETE_WT    = 5'b10001;
  
  
reg   [4:0]   rd_state;
reg   [4:0]   wt_state;
reg           wtdiv_done;
reg           next_wtdiv_done;
reg   [4:0]   next_rd_state;
reg   [4:0]   next_wt_state;
reg   [15:0]  next_sc_mem_rd_addr1;
reg   [15:0]  next_sc_mem_rd_addr2;
reg   [15:0]  next_sc_mem_wt_addr;
reg           next_sc_mem_rd_data_rdy;
reg           next_div_en;
reg           next_sc_mem_wt_en;
reg           next_sc_mem_rd_done;
reg           next_sc_mem_wt_done;
reg   [6:0]   rd_line_count;
reg   [6:0]   wt_line_count;
reg   [6:0]   next_rd_line_count;
reg   [6:0]   next_wt_line_count;
wire          all_div_done;


assign        all_div_done   =  (div1_done & div2_done & div3_done & div4_done & div5_done & div6_done & div7_done & div8_done);


//Moore output updates
always @(posedge clk) begin

  if(reset) begin
    rd_state            <= IDLE_RD;
	wt_state            <= IDLE_WT;
	sc_mem_rd_data_rdy  <= 1'b0;
	div_en              <= 1'b0;
	sc_mem_wt_en        <= 1'b0;
	sc_mem_rd_done      <= 1'b0;
	sc_mem_wt_done      <= 1'b0;
	rd_line_count       <= 7'd0;
	wt_line_count       <= 7'd0;
	wtdiv_done          <= 1'b0;
  end
  else begin
    rd_state            <= next_rd_state;
	wt_state            <= next_wt_state;
	sc_mem_rd_addr1     <= next_sc_mem_rd_addr1;
	sc_mem_rd_addr2     <= next_sc_mem_rd_addr2;
	sc_mem_wt_addr      <= next_sc_mem_wt_addr;
	sc_mem_rd_data_rdy  <= next_sc_mem_rd_data_rdy;
	div_en              <= next_div_en;
	sc_mem_wt_en        <= next_sc_mem_wt_en;
	sc_mem_rd_done      <= next_sc_mem_rd_done;
	sc_mem_wt_done      <= next_sc_mem_wt_done;
	rd_line_count       <= next_rd_line_count;
	wt_line_count       <= next_wt_line_count;
	wtdiv_done          <= next_wtdiv_done;
  end
end

//Staging Delay for Divider Enable
always @(posedge clk) begin
	div_en_D1   <=   div_en;
	div_en_D2   <=   div_en_D1;
	div_en_D3   <=   div_en_D2;
end

//FSM LOGIC TO READ FROM SCRATCH MEM
always @(*) begin

case(rd_state)

    //IDLE state after reset and read completion
    IDLE_RD:begin
        next_sc_mem_rd_done       =  1'b0;
		next_sc_mem_rd_data_rdy   =  1'b0;
		next_div_en               =  1'b0;
		next_rd_line_count        =  7'd0;
		
		if(enable) begin
		   next_rd_state  =   FIRST_RD;
		end
		else begin
		   next_rd_state  =   IDLE_RD;
		end
	end
	
	//State entered only for the first read
	FIRST_RD:begin
		next_sc_mem_rd_addr1 =  16'd64;
		next_sc_mem_rd_addr2 =  16'd65;
		next_rd_line_count   =  7'd1;
		next_rd_state        =  RD_IDLE1;
	end
	
	//Idle state 1 to wait for read data
	RD_IDLE1:begin
		next_rd_state  =  RD_IDLE2;
	end
	
	//Idle state 2 to wait for read data
	RD_IDLE2:begin
		next_rd_state  =  RD_RDY;
	end
	
	//State to set read ready before 
	//going to wait for div
	RD_RDY:begin
		next_sc_mem_rd_data_rdy  =  1'b1;
		next_rd_state            =  DIV_EN;
	end
	
	//Enable divider after each read ready
	DIV_EN:begin
		next_div_en    =  1'b1;
		next_rd_state  =  WAITFORDIV_RD;
	end
	
	//State to wait while divider is running and complete writes
	WAITFORDIV_RD:begin
	
		next_div_en              = 1'b0;
		next_sc_mem_rd_data_rdy  = 1'b0;
		
		if(wtdiv_done && (rd_line_count < 7'd62)) begin
		   next_rd_state  =  NEXT_RD;
		end
		else if(wtdiv_done && (rd_line_count > 7'd62)) begin
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
		next_rd_line_count   =  rd_line_count + 2;
		next_rd_state        =  RD_IDLE1;
	end
	
	//All cdf values read and division is complete
    //on last read cdf values
	COMPLETE_RD:begin
	    next_sc_mem_rd_done  =  1'b1;
		next_rd_state        =  IDLE_RD;
	end
endcase
end



//FSM LOGIC TO WRITE TO SCRATCH MEM
always @(*) begin

case(wt_state)

    //IDLE state after reset and write completion
    IDLE_WT:begin
        next_sc_mem_wt_done  =  1'b0;
		next_sc_mem_wt_en    =  1'b0;
		next_sc_mem_wt_addr  =  16'd128;
		next_wt_line_count   =  7'd0;
		next_wtdiv_done      =  1'b0;
		
		if(enable) begin
		   next_wt_state  =   WAITFORDIV_WT;
		end
		else begin
		   next_wt_state  =   IDLE_WT;
		end
	end

	//State to wait while divider is running 
	WAITFORDIV_WT:begin
		next_sc_mem_wt_en    =  1'b0;
		next_wtdiv_done      =  1'b0;
		
		if(all_div_done && (wt_line_count < 7'd63)) begin
		   next_wt_state  =  WRITE1;
		end
		else if(all_div_done && (wt_line_count >= 7'd63)) begin
		   next_wt_state  =  COMPLETE_WT;
		end
		else begin
		   next_wt_state  =  WAITFORDIV_WT;
		end
	end
	
	//State to write first line of div values
	WRITE1:begin
		next_sc_mem_wt_addr  =  sc_mem_wt_addr + 1;
		next_sc_mem_wt_en    =  1'b1;
		next_wt_line_count   =  wt_line_count + 1;
		next_wt_state        =  WT_IDLE1;
	end
	
	//Write Idle state 1
	WT_IDLE1:begin
		next_sc_mem_wt_en    =  1'b0;
		next_wt_state  =  WT_IDLE2;
	end
	
	//Write Idle state 2
	WT_IDLE2:begin
		next_wt_state  = WRITE2;
	end
	
	//State to write next line of div values
	WRITE2:begin
		next_sc_mem_wt_addr  =  sc_mem_wt_addr + 1;
		next_sc_mem_wt_en    =  1'b1;
		next_wt_line_count   =  wt_line_count + 1;
		next_wt_state        =  WT_IDLE3;
	end
	
	//Write Idle state 3
	WT_IDLE3:begin
		next_sc_mem_wt_en    =  1'b0;
		next_wt_state  =  WT_IDLE4;
	end
	
	//Write Idle state 4
	WT_IDLE4:begin
		next_wt_state    = WAITFORDIV_WT;
		next_wtdiv_done  = 1'b1;
	end
	
    //All div values written and division is complete
    //on last read cdf values
	COMPLETE_WT:begin
	    next_sc_mem_wt_done  =  1'b1;
		next_wt_state        =  IDLE_WT;
	end
endcase
end

endmodule
