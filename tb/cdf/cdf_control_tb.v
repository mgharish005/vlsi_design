`timescale 1 ns/ 100 ps
module cdf_control_tb; 

    // inputs from tb to RTL
	reg clock , reset, cdf_start;
	// cdf control RTL outputs
	wire rfv, smrr, cdf_cd, rnv, cdf_d;
	// cdf datapath RTL outputs
	reg [127:0] smi1, smi2;
	wire [127:0] smo, wbus;
	wire [15:0] wAdd, rAdd1, rAdd2;
	wire WE;
	  

    initial
    begin
        $dumpfile("cdf_control_tb.vcd"); 
        $dumpvars(0, cdf_control_tb) ;
        clock = 1; 
        reset = 1; 
        cdf_start = 0; 
		
		smi1 = 128'd0;
		smi2 = 128'd0;
		
        //sequence
        #10 reset = 0 ;
        #20 cdf_start = 1 ;
		#30 cdf_start = 0;

        #500 $finish; 
    end

    cdf_control cdf_control_t0 
    (
        .clk(clock), 
        .reset(reset), 
        .cdf_start_in(cdf_start),
        .read_first_value(rfv), 
        .scratch_mem_read_ready(smrr),
		.cdf_computation_done(cdf_cd),
		.read_next_value(rnv),
		.cdf_done(cdf_d)
    );
	
	cdf_datapath cdf_datapath_t1
	(
		.clk(clock),
		.reset(reset),
		.scratchmem_input1(smi1),
		.scratchmem_input2(smi2),
		.read_first_value_in(rfv),
		.read_next_value_in(rnv),
		.scratch_mem_read_ready_in(smrr),
		.cdf_computation_done_in(cdf_cd),
		.cdf_done_in(cdf_d),
		.scratchmem_output(smo),
		.WE(WE),
		.WriteAddress(wAdd), 
		.WriteBus(wbus), 
		.ReadAddress1(rAdd1), 
		.ReadAddress2(rAdd2)
	);
    
  /* Make a regular pulsing clock. */
  always #5 clock = !clock;

endmodule 
