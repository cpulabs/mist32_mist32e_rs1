/**************************************************************************
Sync FIFO
	
-parameter N
	Queue data vector width
	Example : DATA[3:0] is N=4

-parameter DEPTH
	Queue entry depth
	Example DEPTH 16 is DEPTH=16

-parameter D_N
	Queue entry depth n size
	Example PARAMETER_DEPTH16 is 4
	
-Make	: 2013/2/13
-Update	: 

Takahiro Ito
**************************************************************************/


`default_nettype none

module vga_sync_fifo
	#(
		parameter N = 16,
		parameter DEPTH = 4,
		parameter D_N = 2
	)	
	(
		//System
		input wire iCLOCK,
		input wire inRESET,
		input wire iREMOVE,
		//Counter
		output wire [D_N-1:0] oCOUNT,
		//WR
		input wire iWR_EN,
		input wire [N-1:0] iWR_DATA,
		output wire oWR_FULL,
		output wire oWR_ALMOST_FULL,
		//RD
		input wire iRD_EN,
		output wire [N-1:0] oRD_DATA,
		output wire oRD_EMPTY,
		output wire oRD_ALMOST_EMPTY
	);
	
	//Count - Wire
	wire [D_N:0] count, almost_full_count;
	
	wire full = count[D_N];
	wire empty = (count == {D_N+1{1'b0}})? 1'b1 : 1'b0;
	wire almost_full = full || (count[D_N-1:0] == {D_N{1'b1}});
	wire almost_empty = empty || (count[D_N:0] == {{D_N{1'b0}}, 1'b1});
	
	//Reg
	reg [D_N:0] b_write_pointer;
	reg [D_N:0] b_read_pointer;
	reg [N-1:0] b_memory [0 : DEPTH-1];
	
	assign count = b_write_pointer - b_read_pointer;
	assign almost_full_count = (b_write_pointer + {{D_N{1'b0}}, 1'b1}) - b_read_pointer;
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_write_pointer <= {D_N+1{1'b0}};
			b_read_pointer <= {D_N+1{1'b0}};
		end
		else if(iREMOVE)begin
			b_write_pointer <= {D_N+1{1'b0}};
			b_read_pointer <= {D_N+1{1'b0}};
		end
		else begin
			if(iWR_EN)begin
				b_write_pointer <= b_write_pointer + {{D_N-1{1'b0}}, 1'b1};
				b_memory [b_write_pointer[D_N-1:0]] <= iWR_DATA;
			end
			if(iRD_EN)begin
				b_read_pointer <= b_read_pointer + {{D_N-1{1'b0}}, 1'b1};
			end
		end
	end //always
	
	//Assign
	assign oRD_DATA = b_memory	[b_read_pointer[D_N-1:0]];
	assign oRD_EMPTY = (count == {D_N+1{1'b0}})? 1'b1 : 1'b0;	//((b_write_pointer - b_read_pointer) ==  {D_N+1{1'b0}})? 1'b1 : 1'b0;
	assign oRD_ALMOST_EMPTY = (count == {D_N+1{1'b0}} || count == {{D_N{1'b0}}, 1'b1})? 1'b1 : 1'b0;//((b_write_pointer - b_read_pointer) ==  {{D_N{1'b0}}, 1'b1})? 1'b1 : 1'b0;
	
	assign oWR_FULL = count[D_N];
	assign oWR_ALMOST_FULL = almost_full_count[D_N] || count[D_N];//(count [D_N-1:0] == {D_N{1'b1}})? 1'b1 : 1'b0;
	assign oCOUNT = count [D_N-1:0];
	
endmodule


`default_nettype wire

