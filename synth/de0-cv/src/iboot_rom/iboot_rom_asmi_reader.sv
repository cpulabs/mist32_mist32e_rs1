


`default_nettype none

module iboot_rom_asmi_reader
	#(
		parameter AN = 23,
		parameter DN = 8,
		parameter QUEUE = 8,
		parameter QUEUE_N = 3
	)(
		//iCLOCK
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//ASMI 
		input wire iCLOCK_ASMI,
		input wire iRESET_ASMI_SYNC,
		//CPU-Request
		input wire iCPU_RQ_REQ,
		output wire oCPU_RQ_BUSY,
		input wire [AN-1:0] iCPU_RQ_ADDR,		
		//CPU-Output
		input wire iCPU_RD_REQ,
		output wire oCPU_RD_BUSY,
		output wire [DN-1:0] oCPU_RD_DATA
	);
				
	localparam PL_STT_IDLE = 2'h0;
	localparam PL_STT_READ = 2'h1;
	localparam PL_STT_WAIT = 2'h2;

	/****************************************
	Wire & Register
	****************************************/
	//Request Queue
	wire [AN-1:0] req_queue_addr;
	wire req_queue_empty;
	wire rq_busy;
	//Output Queue
	wire out_queue_full;
	wire rd_busy;
	//State Register
	reg [1:0] b_state;
	
	wire asmi_req_busy;
	
	/****************************************
	Request Queue
	****************************************/
	wire asmi_req = !req_queue_empty && !asmi_req_busy && b_state == PL_STT_IDLE;
	iboot_rom_showahead_async_fifo #(AN, QUEUE, QUEUE_N) REQUEST_QUEUE(
		.inRESET(inRESET), 
		.iRESET_SYNC_WR(iRESET_SYNC),
		.iRESET_SYNC_RD(iRESET_ASMI_SYNC),
		.iWR_CLOCK(iCLOCK),	
		.iWR_EN(iCPU_RQ_REQ && !rq_busy), 
		.iWR_DATA(iCPU_RQ_ADDR), 
		.oWR_FULL(rq_busy),
		.iRD_CLOCK(iCLOCK_ASMI),	
		.iRD_EN(asmi_req), 
		.oRD_DATA(req_queue_addr), 
		.oRD_EMPTY(req_queue_empty)
	);
	
	
	/****************************************
	ASMI
	****************************************/
	wire asmi_data_valid;
	wire [7:0] asmi_data;

	altera_asmi_rom ASMI(
		.addr(24'h400000 + {1'h0, req_queue_addr[22:0]}),         //         addr.addr
		.busy(asmi_req_busy),         //         busy.busy
		.clkin(iCLOCK_ASMI),        //        clkin.clk
		.data_valid(asmi_data_valid),   //   data_valid.data_valid
		.dataout(asmi_data),      //      dataout.dataout
		.rden(asmi_req),         //         rden.rden
		.read(asmi_req),         //         read.read
		.read_address(), // read_address.read_address
		.reset(iRESET_ASMI_SYNC)         //        reset.reset
	);


	/****************************************
	State
	****************************************/
	always@(posedge iCLOCK_ASMI or negedge inRESET)begin
		if(!inRESET)begin
			b_state <= PL_STT_IDLE;
		end
		else if(iRESET_ASMI_SYNC)begin
			b_state <= PL_STT_IDLE;
		end
		else begin
			case(b_state)
				PL_STT_IDLE:
					begin
						if(asmi_req)begin
							b_state <= PL_STT_READ;
						end
					end
				PL_STT_READ:
					begin
						if(asmi_data_valid)begin
							if(out_queue_full)begin
								b_state <= PL_STT_WAIT;
							end
							else begin
								b_state <= PL_STT_IDLE;
							end
						end
					end
				PL_STT_WAIT:
					begin
						if(!out_queue_full)begin
							b_state <= PL_STT_IDLE;
						end
					end
			endcase
		end
	end
	
	/****************************************
	Output Queue
	****************************************/
	iboot_rom_showahead_async_fifo #(DN, QUEUE, QUEUE_N) OUTPUT_QUEUE(
		.inRESET(inRESET), 
		.iRESET_SYNC_WR(iRESET_ASMI_SYNC),
		.iRESET_SYNC_RD(iRESET_SYNC),
		.iWR_CLOCK(iCLOCK_ASMI),		
		.iWR_EN(!out_queue_full && asmi_data_valid), 
		.iWR_DATA(asmi_data), 
		.oWR_FULL(out_queue_full),
		.iRD_CLOCK(iCLOCK),
		.iRD_EN(iCPU_RD_REQ && !rd_busy), 
		.oRD_DATA(oCPU_RD_DATA), 
		.oRD_EMPTY(rd_busy)
	);
	
	
	/****************************************
	Assign
	****************************************/
	//CPU
	assign oCPU_RQ_BUSY = rq_busy;
	assign oCPU_RD_BUSY = rd_busy;
	
	
endmodule

`default_nettype wire



