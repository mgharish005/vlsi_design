module divider_mem_datapath(
input  wire         clk,
input  wire         reset,
input  wire         enable,
input  wire         sc_mem_rd_data_rdy,
input  wire [127:0] sc_mem_rd_data1,
input  wire [127:0] sc_mem_rd_data2,
input  wire         div1_done,
input  wire         div2_done,
input  wire         div3_done,
input  wire         div4_done,
input  wire         div5_done,
input  wire         div6_done,
input  wire         div7_done,
input  wire         div8_done,
input  wire [31:0]  div1_value,
input  wire [31:0]  div2_value,
input  wire [31:0]  div3_value,
input  wire [31:0]  div4_value,
input  wire [31:0]  div5_value,
input  wire [31:0]  div6_value,
input  wire [31:0]  div7_value,
input  wire [31:0]  div8_value,
output reg  [31:0]  cdfval_todiv1,
output reg  [31:0]  cdfval_todiv2,
output reg  [31:0]  cdfval_todiv3,
output reg  [31:0]  cdfval_todiv4,
output reg  [31:0]  cdfval_todiv5,
output reg  [31:0]  cdfval_todiv6,
output reg  [31:0]  cdfval_todiv7,
output reg  [31:0]  cdfval_todiv8,
output reg  [127:0] sc_mem_wt_data
);

//ALL FSM STATE PARAMETERS
parameter
  IDLE_RD     = 4'b0000,
  CDFLATCH    = 4'b0001,
  IDLE_WT     = 4'b0010,
  WRITE1      = 4'b0011,
  WT_IDLE1    = 4'b0100,
  WT_IDLE2    = 4'b0101,
  WRITE2      = 4'b0110,
  WT_IDLE3    = 4'b0111,
  WT_IDLE4    = 4'b1000;
  
reg     [3:0]    rd_state;
reg     [3:0]    next_rd_state;
reg     [3:0]    wt_state;
reg     [3:0]    next_wt_state;
reg     [31:0]   next_cdfval_todiv1;
reg     [31:0]   next_cdfval_todiv2;
reg     [31:0]   next_cdfval_todiv3;
reg     [31:0]   next_cdfval_todiv4;
reg     [31:0]   next_cdfval_todiv5;
reg     [31:0]   next_cdfval_todiv6;
reg     [31:0]   next_cdfval_todiv7;
reg     [31:0]   next_cdfval_todiv8;
reg     [127:0]  next_sc_mem_wt_data;
wire             all_div_done;
wire    [127:0]  wt_data1;
wire    [127:0]  wt_data2;

assign   all_div_done     =  (div1_done & div2_done & div3_done & div4_done & div5_done & div6_done & div7_done & div8_done);
assign   wt_data1[127:0]  =  {div4_value, div3_value, div2_value, div1_value};
assign   wt_data2[127:0]  =  {div8_value, div7_value, div6_value, div5_value};

//Moore output updates
always @(posedge clk) begin

  if(reset) begin
	rd_state        <=   IDLE_RD;
	wt_state        <=   IDLE_WT;
	sc_mem_wt_data  <=   128'd0;
  end
  else begin
	rd_state        <=   next_rd_state;
	wt_state        <=   next_wt_state;
	sc_mem_wt_data  <=   next_sc_mem_wt_data;
    cdfval_todiv1   <=   next_cdfval_todiv1;
	cdfval_todiv2   <=   next_cdfval_todiv2;
	cdfval_todiv3   <=   next_cdfval_todiv3;
	cdfval_todiv4   <=   next_cdfval_todiv4;
	cdfval_todiv5   <=   next_cdfval_todiv5;
	cdfval_todiv6   <=   next_cdfval_todiv6;
	cdfval_todiv7   <=   next_cdfval_todiv7;
	cdfval_todiv8   <=   next_cdfval_todiv8;
  end
end

//FSM LOGIC TO LATCH DATA ONTO DIVIDER UNITS
always @(*) begin

case(rd_state)

    //IDLE state after reset and wait for read rdy
    IDLE_RD:begin
		
		if(sc_mem_rd_data_rdy) begin
		next_rd_state   =   CDFLATCH;
		end
		else begin
		next_rd_state   =   IDLE_RD;
		end
	end
	
	//State to latch inputs to divider units
	CDFLATCH:begin
		next_cdfval_todiv1  =  sc_mem_rd_data1[31:0];
		next_cdfval_todiv2  =  sc_mem_rd_data1[63:32];
		next_cdfval_todiv3  =  sc_mem_rd_data1[95:64];
		next_cdfval_todiv4  =  sc_mem_rd_data1[127:96];
		next_cdfval_todiv5  =  sc_mem_rd_data2[31:0];
		next_cdfval_todiv6  =  sc_mem_rd_data2[63:32];
		next_cdfval_todiv7  =  sc_mem_rd_data2[95:64];
		next_cdfval_todiv8  =  sc_mem_rd_data2[127:96];
		next_rd_state       =  IDLE_RD;
	end
endcase
end

//FSM LOGIC TO SWITCH WRITE DATA
always @(*) begin

case(wt_state)

    //IDLE state after reset and wait for all_div_done
    IDLE_WT:begin
		
		next_sc_mem_wt_data   =  128'd0;
		
		if(all_div_done) begin
		next_wt_state  =  WRITE1;
		end
		else begin
		next_wt_state  =  IDLE_WT;
		end
	end
	
	//Write for 1st line into scratch mem
	WRITE1:begin
		next_sc_mem_wt_data  =  wt_data1;
		next_wt_state        =  WT_IDLE1;
	end
	
	//Idle write state 1
	WT_IDLE1:begin
	
		next_wt_state  =  WT_IDLE2;
	end
	
	//Idle write state 2
	WT_IDLE2:begin
	
		next_wt_state  =  WRITE2;
	end
	
	//Write for second line into scratch mem
	WRITE2:begin
		next_sc_mem_wt_data  =  wt_data2;
		next_wt_state        =  WT_IDLE3;
	end
	
	//Idle write state 3
	WT_IDLE3:begin
	
		next_wt_state  =  WT_IDLE4;
	end
	
	//Idle write state 4
	WT_IDLE4:begin
	
		next_wt_state  =  IDLE_WT;
	end	
endcase
end

	
endmodule
	