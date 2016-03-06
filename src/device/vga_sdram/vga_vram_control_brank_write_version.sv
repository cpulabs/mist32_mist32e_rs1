

`default_nettype none


//vga_vram_interrconnect
module vga_vram_control(
		//System
		input wire iCLOCK,
		input wire iVGA_CLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//Read Port
		input wire iREAD_ENABLE,
		input wire iREAD_REQ,
		input wire [18:0] iREAD_ADDR,
		output wire oREAD_BUSY,
		output wire oREAD_VALID,
		output wire [15:0] oREAD_DATA,
		//Write Port
		input wire iWRITE_REQ,
		input wire [18:0] iWRITE_ADDR,
		input wire [15:0] iWRITE_DATA,
		output wire oWRITE_BUSY,
		//Memory IF
		output wire oMEM_VALID,
		output wire [1:0] oMEM_BYTEENA,
		output wire oMEM_RW,
		output wire [24:0] oMEM_ADDR,
		output wire [15:0] oMEM_DATA,
		input wire iMEM_BUSY,
		input wire iMEM_VALID,
		input wire [15:0] iMEM_DATA,
		output wire oMEM_BUSY
	);

	assign oREAD_VALID = iMEM_VALID;
	assign oREAD_DATA = iMEM_DATA;

	assign oREAD_BUSY = iMEM_BUSY;
	assign oWRITE_BUSY = iMEM_BUSY || iREAD_ENABLE; 

	reg b_req;
	reg b_rw;
	reg [18:0] b_addr;
	reg [15:0] b_data;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_req <= 1'b0;
			b_rw <= 1'b0;
			b_addr <= 19'h0;
			b_data <= 16'h0;
		end
		else if(iRESET_SYNC)begin
			b_req <= 1'b0;
			b_rw <= 1'b0;
			b_addr <= 19'h0;
			b_data <= 16'h0;
		end
		else begin
			b_req <= (iREAD_ENABLE && iREAD_REQ) || (!iREAD_ENABLE && iWRITE_REQ);
			b_rw <= !iREAD_ENABLE;
			b_addr <= (iREAD_ENABLE)? iREAD_ADDR : iWRITE_ADDR;
			b_data <= iWRITE_DATA;
		end
	end
	
	assign oMEM_VALID = b_req;
	assign oMEM_BYTEENA = 2'b00;
	assign oMEM_RW = b_rw;
	assign oMEM_ADDR = {6'h0, b_addr};
	assign oMEM_DATA = b_data;

	assign oMEM_BUSY = 1'b0;



	
endmodule



`default_nettype wire
