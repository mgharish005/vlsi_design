`include "../../rtl/cdf/cdf_control.v"
`include "../../rtl/cdf/cdf_datapath.v"
`include "../../rtl/memory.v"

//`timescale 1 ns/ 100 ps

module cdf_control_tb; 

    // inputs from tb to RTL
	reg clock , reset, cdf_start;
	// cdf control RTL outputs
	wire rfv, smrr, cdf_cd, rnv, cdf_d;
	// cdf datapath RTL outputs
	wire [127:0] smi1, smi2;
	wire [127:0] wbus;
	wire [15:0] wAdd, rAdd1, rAdd2;
	wire WE;

    integer c_model_waddr; 
    reg [31:0] c_model_wdata[0:3]; 
    integer cdf_cmodel_waddr; 
    reg [31:0] cdf_cmodel_wdata[0:3]; 

    integer cdf_wdata_file;
    integer cdf_waddr_file; 
    integer cdf_scan_file1 , cdf_scan_file2; 
	  

    initial
    begin
        $dumpfile("cdf_control_tb.vcd"); 
        $dumpvars(0, cdf_control_tb) ;
		$readmemh("scratchmem_dump_for_cdf.txt", scratch_u0.Register);
        clock = 1; 
        reset = 1; 
        cdf_start = 0; 
        cdf_waddr_file   = $fopen("cdf_scratch_waddr.txt", "r"); 
        cdf_wdata_file   = $fopen("cdf_scratch_wdata.txt", "r"); 
		
		//smi1 = 128'd0;
		//smi2 = 128'd0;
		
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
		.WE(WE),
		.WriteAddress(wAdd), 
		.WriteBus(wbus), 
		.ReadAddress1(rAdd1), 
		.ReadAddress2(rAdd2)
	);
	
	memory scratch_u0
	(
		.clock(clock), 
		.WE(WE), 
		.WriteAddress(wAdd),
		.ReadAddress1(rAdd1),
		.ReadAddress2(rAdd2), 
		.WriteBus(wbus), 
		.ReadBus1(smi1),
		.ReadBus2(smi2)
	);
    
  /* Make a regular pulsing clock. */
  always #5 clock = !clock;

  //CDF checker------------------------------------------------
  always@(posedge cdf_datapath_t1.WE)
  begin
    #2; 

    //read from file and compare the write address and wdata
    cdf_scan_file1 = $fscanf(cdf_waddr_file, "%d\n", cdf_cmodel_waddr) ;  
    cdf_scan_file2 = $fscanf(cdf_wdata_file, "%032x%32x%032x%032x\n", cdf_cmodel_wdata[3], cdf_cmodel_wdata[2], cdf_cmodel_wdata[1], cdf_cmodel_wdata[0]) ;  

 // $display("[checker] waddr from pli = %x", cdf_cmodel_waddr); 
 // $display("[checker] wdata from pli = %x", cdf_cmodel_wdata[3]); 
 // $display("[checker] wdata from pli = %x", cdf_cmodel_wdata[2]); 
 // $display("[checker] wdata from pli = %x", cdf_cmodel_wdata[1]); 
 // $display("[checker] wdata from pli = %x", cdf_cmodel_wdata[0]); 



    if(!$feof(cdf_waddr_file)) 
    begin
        if(cdf_datapath_t1.WriteAddress != cdf_cmodel_waddr)
                $display("Mismatch cdf_scratch_waddr @ %0t ckt = %x | pli = %x", $stime, cdf_datapath_t1.WriteAddress, c_model_waddr); 
     // else
     //         $display("Match cdf_scratch_waddr @ %0t ckt = %x | pli = %x", $stime, cdf_datapath_t1.WriteAddress, cdf_cmodel_waddr); 
    end

    if(!$feof(cdf_wdata_file)) 
    begin
        if(cdf_datapath_t1.WriteBus[127:96] != cdf_cmodel_wdata[3])
            $display("Mismatch cdf_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, cdf_datapath_t1.WriteBus[127:96], cdf_cmodel_wdata[3]); 
     // else
     //     $display("Match cdf_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, cdf_datapath_t1.WriteBus[127:96], cdf_cmodel_wdata[3]); 

        if(cdf_datapath_t1.WriteBus[95:64] != cdf_cmodel_wdata[2])
            $display("Mismatch cdf_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, cdf_datapath_t1.WriteBus[95:64], cdf_cmodel_wdata[2]); 
     // else
     //     $display("Match cdf_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, cdf_datapath_t1.WriteBus[95:64], cdf_cmodel_wdata[2]); 

        if(cdf_datapath_t1.WriteBus[63:32] != cdf_cmodel_wdata[1])
            $display("Mismatch cdf_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, cdf_datapath_t1.WriteBus[63:32], cdf_cmodel_wdata[1]); 
     // else
     //     $display("Match cdf_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, cdf_datapath_t1.WriteBus[63:32], cdf_cmodel_wdata[1]); 

        if(cdf_datapath_t1.WriteBus[31:0] != cdf_cmodel_wdata[0])
            $display("Mismatch cdf_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, cdf_datapath_t1.WriteBus[31:0], cdf_cmodel_wdata[0]); 
     // else
     //     $display("Match cdf_scratch_wdata @ %0t ckt = %x | pli = %x", $stime, cdf_datapath_t1.WriteBus[63:32], cdf_cmodel_wdata[1]); 
    end


    
   end
endmodule 
