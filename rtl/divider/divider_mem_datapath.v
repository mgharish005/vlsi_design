module divider_mem_datapath(
input  wire         clk,
input  wire         reset,
input  wire         enable,
input  wire         sc_mem_rd_data_rdy,
input  wire [127:0] sc_mem_rd_data1,
input  wire [127:0] sc_mem_rd_data2,
output reg  [31:0]  cdfval_todiv1,
output reg  [31:0]  cdfval_todiv2,
output reg  [31:0]  cdfval_todiv3,
output reg  [31:0]  cdfval_todiv4,
output reg  [31:0]  cdfval_todiv5,
output reg  [31:0]  cdfval_todiv6,
output reg  [31:0]  cdfval_todiv7,
output reg  [31:0]  cdfval_todiv8
);

//ALL FSM STATE PARAMETERS
parameter
  IDLE        = 1'b0,
  CDFLATCH    = 1'b1;
  
reg              state;
reg              next_state;
reg     [31:0]   next_cdfval_todiv1;
reg     [31:0]   next_cdfval_todiv2;
reg     [31:0]   next_cdfval_todiv3;
reg     [31:0]   next_cdfval_todiv4;
reg     [31:0]   next_cdfval_todiv5;
reg     [31:0]   next_cdfval_todiv6;
reg     [31:0]   next_cdfval_todiv7;
reg     [31:0]   next_cdfval_todiv8;

//Moore output updates
always @(posedge clk) begin

  if(reset) begin
	state           <=   IDLE;
  end
  else begin
	state           <=   next_state;
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

case(state)

    //IDLE state after reset and wait for read rdy
    IDLE:begin
		
		if(sc_mem_rd_data_rdy) begin
		next_state   =   CDFLATCH;
		end
		else begin
		next_state   =   IDLE;
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
		next_state          =  IDLE;
	end
endcase
end


endmodule
	