

`default_nettype none


module vga_vram_control_write_pixel(
		//System
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC_IF,
		//IF	
		input wire iPIXEL_REQ,
		input wire [18:0] iPIXEL_ADDR,
		input wire [15:0] iPIXEL_DATA,
		output wire oPIXEL_FULL,
		//MEM
		output wire oMEM_REQ,
		output wire [18:0] oMEM_ADDR,
		output wire [15:0] oMEM_DATA,
		input wire iMEM_BUSY
	);

	//Write FIFO Wire
	wire writefifo_empty;
	wire writefifo_almost_empty;
	wire [18:0] writefifo_addr;
	wire [15:0] writefifo_data;

	vga_sync_fifo #(35, 64, 6) VRAMWRITE_FIFO(
		.inRESET(inRESET),
		.iCLOCK(iCLOCK),
		.iREMOVE(iRESET_SYNC_IF),
		.oCOUNT(),
		.iWR_EN(iPIXEL_REQ),
		.iWR_DATA({iPIXEL_ADDR, iPIXEL_DATA}),
		.oWR_FULL(oPIXEL_FULL),

		.iRD_EN(!iMEM_BUSY && !writefifo_empty),
		.oRD_DATA({writefifo_addr, writefifo_data}),
		.oRD_EMPTY(writefifo_empty),
		.oRD_ALMOST_EMPTY(writefifo_almost_empty)
	);


	assign oMEM_REQ = !writefifo_empty;
	assign oMEM_ADDR = writefifo_addr;
	assign oMEM_DATA = writefifo_data;


endmodule // vga_vram_control_write_pixel

`default_nettype wire


