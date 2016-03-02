
module memory (clock, WE, WriteAddress,ReadAddress1,ReadAddress2, WriteBus, ReadBus1,ReadBus2);

input  clock, WE; 
input  [15:0] WriteAddress, ReadAddress1,ReadAddress2; 
input  [127:0] WriteBus;
output [127:0] ReadBus1, ReadBus2;

reg [127:0] Register [0:65535];   // 65536 words, with each 128 bits wide
reg [127:0] ReadBus1;
reg [127:0] ReadBus2;
// provide one write enable line per register
reg [65535:0] WElines;
integer i;

// Write '1' into write enable line for selected register
// Note the 2 ns delay - THIS IS THE INPUT DELAY FOR THE MEMORY FOR SYNTHESIS

always@(*)
#2 WElines = (WE << WriteAddress);
always@(posedge clock)
    for (i=0; i<=65535; i=i+1)
      if (WElines[i]) Register[i] <= WriteBus;

// Note the 2 ns delay - this is the OUTPUT DELAY FOR THE MEMORY FOR SYNTHESIS
always@(*) 
  begin 
    #2 ReadBus1  =  Register[ReadAddress1];
    ReadBus2  =  Register[ReadAddress2];
  end


always @ (posedge clock)
	begin
	//	$display("\n Within sram : read address %h", ReadAddress1);	
	end

endmodule
