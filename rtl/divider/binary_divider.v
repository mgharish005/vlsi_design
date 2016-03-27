module  binary_divider(
input  wire         clk,
input  wire         reset,
input  wire         enable,
input  wire [15:0]  g_dividend_Q,
input  wire [15:0]  g_divider_Q,
output reg  [7:0]   quotient,
output reg          done
);

//FSM STATE PARAMETERS
parameter
  IDLE      = 2'b00,
  RUN       = 2'b01,
  COMPLETE  = 2'b11;

reg   [1:0]   state;
reg   [1:0]   next_state;
reg   [15:0]  rem;
reg   [15:0]  next_rem;
reg   [31:0]  prod;
reg   [31:0]  next_prod;
reg   [15:0]  term;
reg   [15:0]  next_term;
reg   [7:0]   next_q;
reg           next_done;

//Moore output updates
always @(posedge clk) begin

  if(reset) begin
    state     <= IDLE;
	quotient  <= 8'd0;
    rem       <= 16'd0;
	prod      <= 32'd0;
	term      <= 16'd0;
	done      <= 1'b0;
  end
  else begin
    state     <= next_state;
	quotient  <= next_q;
	rem       <= next_rem;
	prod      <= next_prod;
	term      <= next_term;
	done      <= next_done;
  end
end


//FSM LOGIC FOR DIVISION CORE
always @(*) begin

case(state)

   IDLE:begin  //Waits for Enable to begin division
    next_q      = 8'd0;
	next_rem    = g_dividend_Q;
	next_prod   = g_divider_Q << 15;
	next_term   = 16'h8000;
	next_done   = 1'b0;
	
	if(enable) begin
	  next_state = RUN;
	end
	else begin
	  next_state = IDLE;
	end
   end

   RUN:begin  //Runs division for 16 cycles
    if(~term[0]) begin
	  next_prod  = prod >> 1;
	  next_term  = term >> 1;
	  next_state = RUN;
	  
	  if(prod <= rem) begin
	    next_q   = quotient + term;
		next_rem = rem - prod;
	  end
	end
    else begin
      next_state = COMPLETE;
    end	  
   end

   COMPLETE:begin  
   //End of 16 cycles, Indicates DONE and goes back to IDLE 
   //and waits for next enable
    next_done  = 1'b1;
	next_state = IDLE;
   end
   
endcase
end
	
endmodule
	