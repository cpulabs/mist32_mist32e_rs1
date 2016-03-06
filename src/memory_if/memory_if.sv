


module memory_if(
		/****************************************
		System
		****************************************/
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		/****************************************
		Processor BUS
		****************************************/
		//Req
		input wire iCPU_REQ,
		output wire oCPU_BUSY,
		input wire [3:0] iCPU_MASK,
		input wire iCPU_RW,						//1:Write | 0:Read
		input wire [31:0] iCPU_ADDR,
		//This -> Data RAM
		input wire [31:0] iCPU_DATA,
		//Data RAM -> This
		output wire oCPU_VALID,
		input wire iCPU_BUSY,
		output wire [63:0] oCPU_DATA,
		/****************************************
		Memory
		****************************************/
		output wire oMEM_WR,
		output wire [7:0] oMEM_BYTEENA,
		output wire [31:0] oMEM_ADDR,
		output wire [63:0] oMEM_DATA,
		input wire [63:0] iMEM_DATA
	);



	wire get_fifo_wr_stop;

	/*****************************************************************
	Request Queue
	*****************************************************************/
	wire req_fifo_wr_almost_full;
	wire req_fifo_rd_empty;

	wire [3:0] req_fifo_rd_mask;
	wire req_fifo_rd_rw;
	wire [31:0] req_fifo_rd_addr;
	wire [31:0] req_fifo_rd_data;

	memory_if_sync_fifo
	#(
		.N(4+1+32+32),
		.DEPTH(8),
		.D_N(3)
	)REQ_FIFO(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iREMOVE(iRESET_SYNC),
		//Counter
		.oCOUNT(),
		//WR
		.iWR_EN(iCPU_REQ && !req_fifo_wr_almost_full),
		.iWR_DATA({iCPU_MASK, iCPU_RW, iCPU_ADDR, iCPU_DATA}),
		.oWR_FULL(),
		.oWR_ALMOST_FULL(req_fifo_wr_almost_full),
		//RD
		.iRD_EN(!get_fifo_wr_stop && !req_fifo_rd_empty),
		.oRD_DATA({req_fifo_rd_mask, req_fifo_rd_rw, req_fifo_rd_addr, req_fifo_rd_data}),
		.oRD_EMPTY(req_fifo_rd_empty),
		.oRD_ALMOST_EMPTY()
	);

	assign oCPU_BUSY = req_fifo_wr_almost_full;

	assign oMEM_WR = !req_fifo_rd_empty && req_fifo_rd_rw;
	assign oMEM_BYTEENA = {8{!req_fifo_rd_rw}} | (req_fifo_rd_addr[0])? {~req_fifo_rd_mask, 4'h0} : {4'h0, ~req_fifo_rd_mask};
	assign oMEM_ADDR = {1'b0, req_fifo_rd_addr[31:1]};
	assign oMEM_DATA = {req_fifo_rd_data, req_fifo_rd_data};


	/*****************************************************************
	Request Buffer
	*****************************************************************/
	reg request_rd_delay0;
	reg request_rd_delay1;

	always_ff@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			request_rd_delay0 <= 1'b0;
			request_rd_delay1 <= 1'b0;
		end
		else if(iRESET_SYNC)begin
			request_rd_delay0 <= 1'b0;
			request_rd_delay1 <= 1'b0;
		end
		else begin
			request_rd_delay0 <= !get_fifo_wr_stop && !req_fifo_rd_empty && !req_fifo_rd_rw;
			request_rd_delay1 <= request_rd_delay0;
		end
	end

	/*****************************************************************
	Request Queue
	*****************************************************************/
	wire [3:0] get_fifo_count;
	assign get_fifo_wr_stop = !(get_fifo_count < 4'hb);

	wire get_fifo_rd_empty;

	memory_if_sync_fifo
	#(
		.N(64),
		.DEPTH(16),
		.D_N(4)
	)GET_FIFO(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iREMOVE(iRESET_SYNC),
		//Counter
		.oCOUNT(get_fifo_count),
		//WR
		.iWR_EN(request_rd_delay1),
		.iWR_DATA(iMEM_DATA),
		.oWR_FULL(),
		.oWR_ALMOST_FULL(),
		//RD
		.iRD_EN(!iCPU_BUSY && !get_fifo_rd_empty),
		.oRD_DATA(oCPU_DATA),
		.oRD_EMPTY(get_fifo_rd_empty),
		.oRD_ALMOST_EMPTY()
	);

	assign oCPU_VALID = !get_fifo_rd_empty;


endmodule // memory_if

`default_nettype wire

