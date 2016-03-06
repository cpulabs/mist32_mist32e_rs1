/**************************************************************************
Async Fifo
	
-parameter N
	Queue data vector width
	Example : DATA[3:0] is N=4

-parameter DEPTH
	Queue entry depth
	Example DEPTH 16 is DEPTH=16

-parameter D_N
	Queue entry depth n size
	Example PARAMETER_DEPTH16 is 4
	
-SDF Settings
	Asynchronus Clock : iWR_CLOCK - iRD_CLOCK
	
-Make	: 2013/2/13
-Update	: 

Takahiro Ito
**************************************************************************/

`default_nettype none

module vga_async_fifo
	#(
		parameter N = 16,
		parameter DEPTH = 4,
		parameter D_N = 2
	)
	(
		//System
		input wire inRESET,
		//Remove
		input wire iRESET_SYNC_WR,
		input wire iRESET_SYNC_RD,
		//WR
		input wire iWR_CLOCK,
		input wire iWR_EN,
		input wire [N-1:0] iWR_DATA,
		output wire oWR_FULL,
		output wire [D_N:0] oWR_COUNT,
		//RD
		input wire iRD_CLOCK,
		input wire iRD_EN,
		output wire [N-1:0] oRD_DATA,
		output wire oRD_EMPTY,
		output wire [D_N:0] oRD_COUNT
	);	

	//Full
	wire [D_N:0] full_count;
	wire full;
	wire [D_N:0] empty_count;
	wire empty;
	//Memory
	reg [N-1:0] b_memory[0:DEPTH-1];
	//Counter
	reg [D_N:0] b_wr_counter/* synthesis preserve = 1 */;		//Altera QuartusII Option
	reg [D_N:0] b_rd_counter/* synthesis preserve = 1 */;		//Altera QuartusII Option
	wire [D_N:0] gray_d_fifo_rd_counter;
	wire [D_N:0] binary_d_fifo_rd_counter;
	wire [D_N:0] gray_d_fifo_wr_counter;
	wire [D_N:0] binary_d_fifo_wr_counter;
	
	//Assign
	assign full_count = b_wr_counter - binary_d_fifo_rd_counter;
	assign full = full_count[D_N] || (full_count[D_N-1:0] == {D_N{1'b1}})? 1'b1 : 1'b0;
	//Empty
	assign empty_count = binary_d_fifo_wr_counter - (b_rd_counter);	
	assign empty = (empty_count == {D_N+1{1'b0}})? 1'b1 : 1'b0;
	//Count
	assign oWR_COUNT = full_count;
	assign oRD_COUNT = empty_count;
	

	/***************************************************
	Reset Signal
	***************************************************/	
	wire reset_read_synch;
	vga_async_fifo_double_flipflop #(1) SYNTH_RESET_READ(
		.iCLOCK(iRD_CLOCK),
		.inRESET(inRESET),
		.iREQ_DATA(iRESET_SYNC_WR),
		.oOUT_DATA(reset_read_synch)
	);

	wire reset_write_synch;
	vga_async_fifo_double_flipflop #(1) SYNTH_RESET_WRITE(
		.iCLOCK(iWR_CLOCK),
		.inRESET(inRESET),
		.iREQ_DATA(iRESET_SYNC_RD),
		.oOUT_DATA(reset_write_synch)
	);



	/***************************************************
	Memory
	***************************************************/	
	//Write
	always@(posedge iWR_CLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_wr_counter <= {D_N{1'b0}};
		end
		else if(iRESET_SYNC_WR || reset_write_synch)begin
			b_wr_counter <= {D_N{1'b0}};
		end
		else begin
			if(iWR_EN && !full)begin
				b_memory[b_wr_counter[D_N-1:0]] <= iWR_DATA;
				b_wr_counter <= b_wr_counter + {{D_N-1{1'b0}}, 1'b1};
			end
		end
	end
	
	//Read Pointer
	always@(posedge iRD_CLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_rd_counter <= {D_N{1'b0}};
		end
		else if(iRESET_SYNC_RD || reset_read_synch)begin
			b_rd_counter <= {D_N{1'b0}};
		end
		else begin
			if(iRD_EN && !empty)begin
				b_rd_counter <= b_rd_counter + {{D_N-1{1'b0}}, 1'b1};
			end
		end
	end
	
	
	/***************************************************
	Counter Buffer
	***************************************************/	
	vga_async_fifo_double_flipflop #(D_N+1) D_FIFO_READ(
		.iCLOCK(iWR_CLOCK),
		.inRESET(inRESET),
		.iREQ_DATA(bin2gray(b_rd_counter)),
		.oOUT_DATA(gray_d_fifo_rd_counter)
	);
	assign binary_d_fifo_rd_counter = gray2bin(gray_d_fifo_rd_counter);
	
	
	vga_async_fifo_double_flipflop #(D_N+1) D_FIFO_WRITE(
		.iCLOCK(iRD_CLOCK),
		.inRESET(inRESET),
		.iREQ_DATA(bin2gray(b_wr_counter)),
		.oOUT_DATA(gray_d_fifo_wr_counter)
	);
	assign binary_d_fifo_wr_counter = gray2bin(gray_d_fifo_wr_counter);
	
	/***************************************************
	Function
	***************************************************/
	function [D_N:0] bin2gray;
		input [D_N:0] binary;
		begin
			bin2gray = binary ^ (binary >> 1'b1);
		end
	endfunction
	

	function[D_N:0] gray2bin(input[D_N:0] gray);
		integer i;
		for(i=D_N; i>=0; i=i-1)begin
			if(i==D_N)begin
				gray2bin[i] = gray[i];
			end
			else begin
				gray2bin[i] = gray[i] ^ gray2bin[i+1];
			end
		end
	endfunction
	
	
	/***************************************************
	Output Assign
	***************************************************/	
	assign oWR_FULL = full;
	assign oRD_EMPTY = empty;
	assign oRD_DATA = b_memory[b_rd_counter[D_N-1:0]];
	
				
endmodule

`default_nettype wire
