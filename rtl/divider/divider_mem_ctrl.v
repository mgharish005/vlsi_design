module divider_mem_ctrl(
input  wire         clk,
input  wire         reset,
input  wire         enable,
input  wire         div_done,
output reg [15:0]   sc_mem_rdaddr,
output reg          sc_mem_rd_en,
output reg          sc_mem_rd_done
);

//FSM STATE PARAMETERS
parameter
  IDLE        = 3'b000,
  FIRST_RD    = 3'b001,
  WAITFORDIV  = 3'b010,
  NEXT_RD     = 3'b011,
  COMPLETE    = 3'b100;
  
  
reg   [2:0]   state;
reg   [2:0]   next_state;
reg   [15:0]  next_sc_mem_rdaddr;
reg           next_sc_mem_rd_en;
reg           next_sc_mem_rd_done;
reg   [6:0]   rd_line_count;

//Moore output updates
always @(posedge clk) begin

  if(reset) begin
    state               <= IDLE;
	sc_mem_rdaddr       <= 16'd0;
	sc_mem_rd_en        <= 1'b0;
	sc_mem_rd_done      <= 1'b0;
  end
  else begin
    state               <= next_state;
	sc_mem_rdaddr       <= next_sc_mem_rdaddr;
	sc_mem_rd_en        <= next_sc_mem_rd_en;
	sc_mem_rd_done      <= next_sc_mem_rd_done;
  end
end

//FSM LOGIC FOR DIVISION CORE
always @(*) begin

case(state)


    IDLE:begin
        next_sc_mem_rd_done  =  1'b0;
		next_sc_mem_rd_en    =  1'b0;
		next_sc_mem_rdaddr   =  16'd0;
		rd_line_count        =  7'd0;
		
		if(enable) begin
		   next_state  =   FIRST_RD;
		end
		else begin
		   next_state  =   IDLE;
		end
	end
	
	FIRST_RD:begin
		next_sc_mem_rdaddr   =  16'd64;
		next_sc_mem_rd_en    =  1'b1;
		rd_line_count        =  7'd1;
		next_state           =  WAITFORDIV;
	end
	
	WAITFORDIV:begin
		next_sc_mem_rd_en    =  1'b0;
		
		if(div_done && (rd_line_count < 7'd64)) begin
		   next_state  =  NEXT_RD;
		end
		else if(div_done && (rd_line_count > 7'd64)) begin
		   next_state  =  COMPLETE;
		end
		else begin
		   next_state  = WAITFORDIV;
		end
	end
	
	NEXT_RD:begin
	    next_sc_mem_rdaddr  =  sc_mem_rdaddr + 2;
		next_sc_mem_rd_en   =  1'b1;
		rd_line_count       =  rd_line_count + 2;
		next_state          =  WAITFORDIV;
	end
	
	COMPLETE:begin
	    next_sc_mem_rd_done  =  1'b1;
		next_state           =  IDLE;
	end
endcase
end

endmodule
