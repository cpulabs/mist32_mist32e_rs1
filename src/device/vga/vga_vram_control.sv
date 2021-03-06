

`default_nettype none


module vga_vram_control(
		//System
		input wire iCLOCK,
		input wire iVGA_CLOCK,
		input wire inRESET,
		input wire iRESET_SYNC_IF,
		input wire iRESET_SYNC_VGA,
		//IF	
		input wire iBMP_WRITE_REQ,
		input wire [18:0] iBMP_WRITE_ADDR,
		input wire [15:0] iBMP_WRITE_DATA,
		output wire oBMP_WRITE_FULL,
		input wire iBMP_READ_REQ,
		output wire [15:0] oBMP_READ_DATA,
		output wire oBMP_READ_EMPTY,
		//SRAM
		output wire onSRAM_CE,
		output wire onSRAM_WE,
		output wire onSRAM_OE,
		output wire onSRAM_UB,
		output wire onSRAM_LB,
		output wire [19:0] oSRAM_ADDR,
		inout wire [15:0] ioSRAM_DATA
	);
	
	localparam L_PARAM_MAIN_STT_IDLE = 2'h0;
	localparam L_PARAM_MAIN_STT_READ = 2'h1;
	localparam L_PARAM_MAIN_STT_WRITE = 2'h2;
	
	reg [1:0] b_main_state;
	reg b_main_wait;	
	reg b_main_req;

	//Request State
	localparam L_PARAM_READ_REQ_STT_IDLE = 2'h0;
	localparam L_PARAM_READ_REQ_STT_ADDR_SET = 2'h1;
	localparam L_PARAM_READ_REQ_STT_RD_END = 2'h2;
	
	
	reg [1:0] b_rd_req_state;
	reg [19:0] b_rd_req_addr;
	reg b_rd_req_end;



	localparam L_PARAM_WRITE_STT_IDLE = 3'h0;	
	localparam L_PARAM_WRITE_STT_ADDR_SET = 3'h1;			//CE=H, WE=H, Addr=Active
	localparam L_PARAM_WRITE_STT_LATCH_CONDITION = 3'h2;	//CE=L, WE=L
	localparam L_PARAM_WRITE_STT_DATA_SET = 3'h3;			//CE=L, WE=L, Data=Active
	localparam L_PARAM_WRITE_STT_END = 3'h4;
	
	reg [2:0] b_wr_state;
	reg b_wr_end;

	//Write FIFO Wire
	wire writefifo_empty;
	wire writefifo_almost_empty;
	wire [18:0] writefifo_addr;
	wire [15:0] writefifo_data;
	//Read FIFO Wire
	wire vramfifo0_full;
	wire [15:0] vramfifo0_data;
	wire vramfifo0_empty;
	wire vramfifo1_full;
	
	/********************************************
	//Memory Assignment
	********************************************/
	//Assignment Buffer
	reg b_buff_osram_rw;		//R=0 | W=1
	reg b_buff_onsram_we;
	reg b_buff_onsram_oe;
	reg b_buff_onsram_ub;
	reg b_buff_onsram_lb;
	reg [19:0] b_buff_osram_addr;
	reg [15:0] b_buff_osram_data;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_buff_osram_rw <= 1'b0;
			b_buff_onsram_we <= 1'b0;
			b_buff_onsram_oe <= 1'b0;
			b_buff_onsram_ub <= 1'b0;
			b_buff_onsram_lb <= 1'b0;
			b_buff_osram_addr <= 20'h0;
			b_buff_osram_data <= 16'h0;
		end
		else if(iRESET_SYNC_IF)begin
			b_buff_osram_rw <= 1'b0;
			b_buff_onsram_we <= 1'b0;
			b_buff_onsram_oe <= 1'b0;
			b_buff_onsram_ub <= 1'b0;
			b_buff_onsram_lb <= 1'b0;
			b_buff_osram_addr <= 20'h0;
			b_buff_osram_data <= 16'h0;
		end
		else begin
			b_buff_onsram_oe <= 1'b0;
			case(b_main_state)
				L_PARAM_MAIN_STT_READ:
					begin
						case(b_rd_req_state)
							L_PARAM_READ_REQ_STT_ADDR_SET:
								begin
									b_buff_osram_rw <= 1'b0;
									b_buff_onsram_we <= 1'b1;
									b_buff_onsram_ub <= 1'b0;
									b_buff_onsram_lb <= 1'b0;
									b_buff_osram_addr <= b_rd_req_addr;
									b_buff_osram_data <= b_buff_osram_data;
								end
							default:
								begin
									b_buff_osram_rw <= 1'b0;
									b_buff_onsram_we <= 1'b1;
									b_buff_onsram_ub <= 1'b1;
									b_buff_onsram_lb <= 1'b1;
									b_buff_osram_addr <= 20'h0;
									b_buff_osram_data <= 16'h0;
								end
						endcase
					end
				L_PARAM_MAIN_STT_WRITE:
					begin
						case(b_wr_state)
							L_PARAM_WRITE_STT_ADDR_SET:
								begin	//CE=H, WE=H, Addr=Active
									b_buff_osram_rw <= 1'b0;
									b_buff_onsram_we <= 1'b1;
									b_buff_onsram_ub <= 1'b1;
									b_buff_onsram_lb <= 1'b1;
									b_buff_osram_addr <= writefifo_addr;
									b_buff_osram_data <= writefifo_data;
								end
							L_PARAM_WRITE_STT_LATCH_CONDITION:
								begin	//CE=L, WE=L
									b_buff_osram_rw <= 1'b1;
									b_buff_onsram_we <= 1'b0;
									b_buff_onsram_ub <= 1'b0;
									b_buff_onsram_lb <= 1'b0;
									b_buff_osram_addr <= b_buff_osram_addr;
									b_buff_osram_data <= b_buff_osram_data;
								end
							L_PARAM_WRITE_STT_DATA_SET:
								begin	//CE=L, WE=L, Data=Active
									b_buff_osram_rw <= 1'b1;
									b_buff_onsram_we <= 1'b0;
									b_buff_onsram_ub <= 1'b0;
									b_buff_onsram_lb <= 1'b0;
									b_buff_osram_addr <= b_buff_osram_addr;
									b_buff_osram_data <= b_buff_osram_data;
								end
							default:	//Idle or other
								begin
									b_buff_osram_rw <= 1'b0;
									b_buff_onsram_we <= 1'b1;
									b_buff_onsram_ub <= 1'b1;
									b_buff_onsram_lb <= 1'b1;
									b_buff_osram_addr <= 20'h0;
									b_buff_osram_data <= 16'h0;
								end
						endcase
					end
				default:
					begin
						b_buff_osram_rw <= 1'b0;
						b_buff_onsram_we <= 1'b1;
						b_buff_onsram_ub <= 1'b1;
						b_buff_onsram_lb <= 1'b1;
						b_buff_osram_addr <= 20'h0;
						b_buff_osram_data <= 16'h0;
					end
			endcase
		end
	end
	
	
	assign onSRAM_CE = 1'b0;//b_buff_onsram_ce;
	assign onSRAM_WE = b_buff_onsram_we;
	assign onSRAM_OE = b_buff_onsram_oe;
	assign onSRAM_UB = b_buff_onsram_ub;
	assign onSRAM_LB = b_buff_onsram_lb;
	assign oSRAM_ADDR = b_buff_osram_addr;
	assign ioSRAM_DATA = (b_buff_osram_rw)? b_buff_osram_data : 16'hzzzz;
	
	
	/********************************************
	//Main State
	********************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_main_state <= L_PARAM_MAIN_STT_IDLE;
			b_main_wait <= 1'b0;
			b_main_req <= 1'b0;
		end
		else if(iRESET_SYNC_IF)begin
			b_main_state <= L_PARAM_MAIN_STT_IDLE;
			b_main_wait <= 1'b0;
			b_main_req <= 1'b0;
		end
		else if(b_main_wait)begin
			b_main_req <= 1'b0;
			if(b_wr_end || b_rd_req_end)begin
				b_main_state <= L_PARAM_MAIN_STT_IDLE;
				b_main_wait <= 1'b0;
			end
		end
		else begin
			case(b_main_state)
				L_PARAM_MAIN_STT_IDLE:
					begin
						if(vramfifo0_empty)begin
							b_main_state <= L_PARAM_MAIN_STT_READ;
							b_main_req <= 1'b1;
						end
						else if(!writefifo_empty)begin
							b_main_state <= L_PARAM_MAIN_STT_WRITE;
							b_main_req <= 1'b1;
						end
						else begin
							b_main_state <= L_PARAM_MAIN_STT_IDLE;
							b_main_wait <= 1'b0;
							b_main_req <= 1'b0;
						end
					end
				L_PARAM_MAIN_STT_READ:
					begin
						b_main_state <= L_PARAM_MAIN_STT_READ;
						b_main_wait <= 1;
						b_main_req <= 1'b0;
					end
				L_PARAM_MAIN_STT_WRITE:
					begin
						b_main_state <= L_PARAM_MAIN_STT_WRITE;
						b_main_wait <= 1;
						b_main_req <= 1'b0;
					end
				default:
					begin
						b_main_state <= L_PARAM_MAIN_STT_IDLE;
						b_main_wait <= 1'b0;
						b_main_req <= 1'b0;
					end
			endcase
		end
	end
		
	/********************************************
	//Write State
	********************************************/	
	vga_sync_fifo #(35, 64, 6) VRAMWRITE_FIFO(
		.inRESET(inRESET),
		.iCLOCK(iCLOCK),
		.iREMOVE(iRESET_SYNC_IF),
		.oCOUNT(),
		.iWR_EN(iBMP_WRITE_REQ),
		.iWR_DATA({iBMP_WRITE_ADDR, iBMP_WRITE_DATA}),
		.oWR_FULL(oBMP_WRITE_FULL),
		.iRD_EN(b_wr_state == L_PARAM_WRITE_STT_DATA_SET && !writefifo_empty),
		.oRD_DATA({writefifo_addr, writefifo_data}),
		.oRD_EMPTY(writefifo_empty),
		.oRD_ALMOST_EMPTY(writefifo_almost_empty)
	);
	
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_wr_state <= L_PARAM_WRITE_STT_IDLE;
			b_wr_end <= 1'b0;
		end
		else if(iRESET_SYNC_IF)begin
			b_wr_state <= L_PARAM_WRITE_STT_IDLE;
			b_wr_end <= 1'b0;
		end
		else begin
			case(b_wr_state)
				L_PARAM_WRITE_STT_IDLE:
					begin
						if(b_main_req && (b_main_state == L_PARAM_MAIN_STT_WRITE))begin
							b_wr_state <= L_PARAM_WRITE_STT_ADDR_SET;
						end
						b_wr_end <= 1'b0;
					end
				L_PARAM_WRITE_STT_ADDR_SET:
					begin
						b_wr_state <= L_PARAM_WRITE_STT_LATCH_CONDITION;
					end
				L_PARAM_WRITE_STT_LATCH_CONDITION:
					begin
						b_wr_state <= L_PARAM_WRITE_STT_DATA_SET;
					end
				L_PARAM_WRITE_STT_DATA_SET:
					begin
						if(/*writefifo_empty*/writefifo_almost_empty || vramfifo0_empty)begin
							b_wr_state <= L_PARAM_WRITE_STT_END;
						end
						else begin
							b_wr_state <= L_PARAM_WRITE_STT_ADDR_SET;
						end
					end
				L_PARAM_WRITE_STT_END:
					begin
						b_wr_state <= L_PARAM_WRITE_STT_IDLE;
						b_wr_end <= 1'b1;
					end
				default:
					begin
						b_wr_state <= L_PARAM_WRITE_STT_IDLE;
					end
			endcase
		end
	end
	
	
	/********************************************
	//Read State (RD FIFO)
	********************************************/	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_rd_req_state <= L_PARAM_READ_REQ_STT_IDLE;
			b_rd_req_addr <= 20'h0;
			b_rd_req_end <= 1'b0;
		end
		else if(iRESET_SYNC_IF)begin
			b_rd_req_state <= L_PARAM_READ_REQ_STT_IDLE;
			b_rd_req_addr <= 20'h0;
			b_rd_req_end <= 1'b0;
		end
		else begin
			case(b_rd_req_state)
				L_PARAM_READ_REQ_STT_IDLE:
					begin
						if(b_main_req && (b_main_state == L_PARAM_MAIN_STT_READ))begin
							b_rd_req_state <= L_PARAM_READ_REQ_STT_ADDR_SET;
						end
						b_rd_req_end <= 1'b0;
					end
				L_PARAM_READ_REQ_STT_ADDR_SET:
					begin
						if(vramfifo0_full)begin
							//b_rd_req_addr <= func_read_next_addr_640x480(b_rd_req_addr);
							b_rd_req_state <= L_PARAM_READ_REQ_STT_RD_END;
						end
						else begin
							b_rd_req_addr <= func_read_next_addr_640x480(b_rd_req_addr);
							b_rd_req_state <= L_PARAM_READ_REQ_STT_ADDR_SET;
						end
					end
				L_PARAM_READ_REQ_STT_RD_END:
					begin
						b_rd_req_state <= L_PARAM_READ_REQ_STT_IDLE;
						b_rd_req_end <= 1'b1;
					end
				default:
					begin
						b_rd_req_state <= L_PARAM_READ_REQ_STT_IDLE;
						b_rd_req_end <= 1'b0;
					end
			endcase
		end
	end
	

	
	function [19:0] func_read_next_addr_640x480;
		input [19:0] func_now_addr;
		begin
			if(func_now_addr < 20'h4b000 - 20'h1)begin
				func_read_next_addr_640x480 = func_now_addr + 20'h1;
			end
			else begin
				func_read_next_addr_640x480 = 20'h0;
			end
		end
	endfunction
	
	//latch State
	localparam L_PARAM_READ_LATCH_STT_IDLE = 2'h0;
	localparam L_PARAM_READ_LATCH_STT_ADDR_SET = 2'h1;
	localparam L_PARAM_READ_LATCH_STT_RD = 2'h2;
	localparam L_PARAM_READ_LATCH_STT_RD_END = 2'h3;
	
	reg b_rd_latch_condition;
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_rd_latch_condition <= 1'b0;
		end
		else if(iRESET_SYNC_IF)begin
			b_rd_latch_condition <= 1'b0;
		end
		else begin
			b_rd_latch_condition <= (b_rd_req_state == L_PARAM_READ_REQ_STT_ADDR_SET) && !vramfifo0_full;
		end
	end

	vga_sync_fifo #(16, 16, 4)	VRAMREAD_FIFO0(
		.inRESET(inRESET),
		.iREMOVE(iRESET_SYNC_IF),
		.iCLOCK(iCLOCK),
		.iWR_EN(b_rd_latch_condition),
		.iWR_DATA(ioSRAM_DATA),
		.oWR_FULL(/*vramfifo0_full*/),
		.oWR_ALMOST_FULL(vramfifo0_full),
		.iRD_EN(!vramfifo0_empty && !vramfifo1_full),
		.oRD_DATA(vramfifo0_data),
		.oRD_EMPTY(vramfifo0_empty)
	);
	vga_async_fifo #(16, 16, 4)	VRAMREAD_FIFO1(
		.inRESET(inRESET),
		.iRESET_SYNC_WR(iRESET_SYNC_IF),
		.iRESET_SYNC_RD(iRESET_SYNC_VGA),
		.iWR_CLOCK(iCLOCK),
		.iWR_EN(!vramfifo0_empty && !vramfifo1_full),
		.iWR_DATA(vramfifo0_data),
		.oWR_FULL(vramfifo1_full),
		.iRD_CLOCK(iVGA_CLOCK),
		.iRD_EN(iBMP_READ_REQ),
		.oRD_DATA(oBMP_READ_DATA),
		.oRD_EMPTY(oBMP_READ_EMPTY)
	);
	
	
endmodule



`default_nettype wire
