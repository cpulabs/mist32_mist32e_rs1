

`default_nettype none


module vga_vram_control_read_pixel(
		//System
		input wire iCLOCK,
		input wire iVGA_CLOCK,
		input wire inRESET,
		input wire iRESET_SYNC_IF,
		//MEM
		output wire oMEM_READSTATE,
		output wire oMEM_REQ,
		output wire [19:0] oMEM_ADDR,
		input wire iMEM_BUSY,
		input wire iMEM_VALID,
		input wire [15:0] iMEM_DATA,
		//iBMP Read
		input wire iPIXEL_VSYNC,
		input wire iPIXEL_DATA_REQ,
		output wire [15:0] oPIXEL_DATA_DATA,
		output wire oPIXEL_DATA_EMPTY
	);


	/********************************************
	//Synchronizer
	********************************************/
	reg b_buffer_vsync0;
	reg b_buffer_vsync1;
	reg b_buffer_vsync2;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_buffer_vsync0 <= 1'b0;
			b_buffer_vsync1 <= 1'b0;
			b_buffer_vsync2 <= 1'b0;
		end
		else if(iRESET_SYNC_IF)begin
			b_buffer_vsync0 <= 1'b0;
			b_buffer_vsync1 <= 1'b0;
			b_buffer_vsync2 <= 1'b0;
		end
		else begin
			b_buffer_vsync0 <= iPIXEL_VSYNC;
			b_buffer_vsync1 <= b_buffer_vsync0;
			b_buffer_vsync2 <= b_buffer_vsync1;
		end
	end

	reg b_syngle_shot_vsync;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_syngle_shot_vsync <= 1'b0;
		end
		else if(iRESET_SYNC_IF)begin
			b_syngle_shot_vsync <= 1'b0;
		end
		else begin
			b_syngle_shot_vsync <= !b_buffer_vsync2 && b_buffer_vsync1;
		end
	end



	/********************************************
	//Make Timing
	********************************************/
	reg [2:0] b_timing_reset_counter;				//@Disp Clock = 25MHz, IF Clock = 50MHz, Async FIFO latency = 2, so delay is over 4

	reg [1:0] b_timing_state;
	localparam PL_TIMING_STT_STOP = 2'h0;
	localparam PL_TIMING_STT_RESET_FIFO = 2'h1;
	localparam PL_TIMING_STT_IDLE = 2'h2;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_timing_reset_counter <= 3'h0;
		end
		else if(iRESET_SYNC_IF || b_syngle_shot_vsync)begin
			b_timing_reset_counter <= 3'h0;
		end
		else begin
			if(b_timing_state == PL_TIMING_STT_RESET_FIFO)begin
				b_timing_reset_counter <= (b_timing_reset_counter == 3'h7)? b_timing_reset_counter : b_timing_reset_counter + 3'h1;
			end
		end
	end

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_timing_state <= PL_TIMING_STT_STOP;
		end
		else if(iRESET_SYNC_IF || b_syngle_shot_vsync)begin
			b_timing_state <= PL_TIMING_STT_STOP;
		end
		else begin
			case(b_timing_state)
				PL_TIMING_STT_STOP:
					begin
						b_timing_state <= PL_TIMING_STT_RESET_FIFO;
					end
				PL_TIMING_STT_RESET_FIFO:
					begin
						if(b_timing_reset_counter == 3'h7)begin
							b_timing_state <= PL_TIMING_STT_IDLE;
						end
					end
				PL_TIMING_STT_IDLE:
					begin
						b_timing_state <= PL_TIMING_STT_IDLE;
					end
				default:
					begin
						b_timing_state <= PL_TIMING_STT_STOP;
					end
			endcase
		end
	end


	wire if_synth_read_accept = (b_timing_state == PL_TIMING_STT_IDLE);
	wire if_synth_fifo_reset = (b_timing_state == PL_TIMING_STT_RESET_FIFO);

	reg b_buffer_fifo_reset0;
	reg b_buffer_fifo_reset1;
	always@(posedge iVGA_CLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_buffer_fifo_reset0 <= 1'b0;
			b_buffer_fifo_reset1 <= 1'b0;
		end
		/*
		else if(iRESET_SYNC_VGA)begin
			b_buffer_fifo_reset0 <= 1'b0;
			b_buffer_fifo_reset1 <= 1'b0;
		end
		*/
		else begin
			b_buffer_fifo_reset0 <= if_synth_fifo_reset;
			b_buffer_fifo_reset1 <= b_buffer_fifo_reset0;
		end
	end

	wire vga_synth_fifo_reset = b_buffer_fifo_reset1;

	//assign oMEM_READSTATE = !(b_read_state == LPARAM_STT_READ_RD_FINISH) || !(b_timing_state == PL_TIMING_STT_RESET_FIFO);
	assign oMEM_READSTATE = (b_read_state == LPARAM_STT_READ_RD_BLOCK);


	/********************************************
	//Read
	********************************************/
	wire arbiter_matching_queue_full;

	//Condition
	//wire condition_read_block_start = (b_read_addr < 20'h4b000) && (b_read_state == LPARAM_STT_READ_IDLE) && (fifo_count[4:0] < 5'd20) && if_synth_read_accept;
	wire condition_read_block_start = (b_read_addr < 20'h4b000) && (b_read_state == LPARAM_STT_READ_IDLE) && (fifo_count[6:0] < 7'd100) && if_synth_read_accept;

	wire condition_reqd_req = (b_read_state == LPARAM_STT_READ_RD_BLOCK) && (b_read_block_state == LPARAM_STT_READ_BLOBK_READING) && !arbiter_matching_queue_full;
	wire condition_reqd_req_accept = condition_reqd_req && !iMEM_BUSY;
	wire condition_read_finished = b_read_addr == 20'h4b000;


	wire from_memory_data_valid;
	//vga_arbiter_matching_queue #(32, 5, 1) BUS_MATCHING_QUEUE(
	vga_arbiter_matching_queue #(128, 7, 1) BUS_MATCHING_QUEUE(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC_IF),
		//Flash
		.iFLASH(b_syngle_shot_vsync),
		//Write
		.iWR_REQ(condition_reqd_req_accept),
		.iWR_FLAG(1'h0),
		.oWR_FULL(arbiter_matching_queue_full),
		//Read
		.iRD_REQ(iMEM_VALID),
		.oRD_VALID(from_memory_data_valid),
		.oRD_FLAG(),
		.oRD_EMPTY()
	);

	//Read state
	reg [1:0] b_read_state;	
	//Request State
	localparam LPARAM_STT_READ_IDLE = 2'h0;
	localparam LPARAM_STT_READ_RD_BLOCK = 2'h1;
	localparam LPARAM_STT_READ_RD_FINISH = 2'h2;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_read_state <= LPARAM_STT_READ_IDLE;
		end
		else if(iRESET_SYNC_IF)begin
			b_read_state <= LPARAM_STT_READ_IDLE;
		end
		else if(b_syngle_shot_vsync)begin
			b_read_state <= LPARAM_STT_READ_IDLE;
		end
		else begin
			case(b_read_state)
				LPARAM_STT_READ_IDLE:
					begin
						if(condition_read_block_start)begin
							b_read_state <= LPARAM_STT_READ_RD_BLOCK;
						end
					end
				LPARAM_STT_READ_RD_BLOCK:
					begin
						if(b_read_block_state == LPARAM_STT_READ_BLOBK_DONE)begin
							if(condition_read_finished)begin
								b_read_state <= LPARAM_STT_READ_RD_FINISH;
							end
							else begin
								b_read_state <= LPARAM_STT_READ_IDLE;
							end
						end
					end
				LPARAM_STT_READ_RD_FINISH:
					begin
						b_read_state <= LPARAM_STT_READ_RD_FINISH;
					end
				default:
					begin
						b_read_state <= LPARAM_STT_READ_IDLE;
					end
			endcase
		end
	end



	//Read Block State : 8
	reg [1:0] b_read_block_state;
	localparam LPARAM_STT_READ_BLOBK_IDLE = 2'h0;
	localparam LPARAM_STT_READ_BLOBK_READING = 2'h1;
	localparam LPARAM_STT_READ_BLOBK_DONE = 2'h2;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_read_block_state <= LPARAM_STT_READ_IDLE;
		end
		else if(iRESET_SYNC_IF)begin
			b_read_block_state <= LPARAM_STT_READ_IDLE;
		end
		else if(b_syngle_shot_vsync)begin
			b_read_block_state <= LPARAM_STT_READ_IDLE;
		end
		else begin
			case(b_read_block_state)
				LPARAM_STT_READ_BLOBK_IDLE:
					begin
						if(condition_read_block_start)begin
							b_read_block_state <= LPARAM_STT_READ_BLOBK_READING;
						end
					end
				LPARAM_STT_READ_BLOBK_READING:
					begin
						if(b_read_block_count == 4'h8)begin
							b_read_block_state <= LPARAM_STT_READ_BLOBK_DONE;
						end
					end
				LPARAM_STT_READ_BLOBK_DONE:
					begin
						b_read_block_state <= LPARAM_STT_READ_BLOBK_IDLE;
					end
				default:
					begin
						b_read_block_state <= LPARAM_STT_READ_BLOBK_IDLE;
					end
			endcase
		end
	end


	function [19:0] func_read_next_addr_640x480;
		input [19:0] func_now_addr;
		begin
			if(func_now_addr < 20'h4b000)begin
				func_read_next_addr_640x480 = func_now_addr + 20'h1;
			end
			else begin
				func_read_next_addr_640x480 = func_now_addr;//20'h0;
			end
		end
	endfunction
	

	//Read Address
	reg [19:0] b_read_addr;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_read_addr <= 20'h0;
		end
		else if(iRESET_SYNC_IF)begin
			b_read_addr <= 20'h0;
		end
		else if(b_syngle_shot_vsync)begin
			b_read_addr <= 20'h0;
		end
		else begin
			if(condition_reqd_req_accept)begin
				b_read_addr <= func_read_next_addr_640x480(b_read_addr);
			end
		end
	end

	//Read Address
	reg [3:0] b_read_block_count;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_read_block_count <= 4'h0;
		end
		else if(iRESET_SYNC_IF)begin
			b_read_block_count <= 4'h0;
		end
		else if(b_syngle_shot_vsync)begin
			b_read_block_count <= 4'h0;
		end
		else begin
			if(b_read_block_state == LPARAM_STT_READ_BLOBK_DONE)begin
				b_read_block_count <= 4'h0;
			end
			else if(condition_reqd_req_accept)begin
				b_read_block_count <= b_read_block_count + 4'h1;
			end
		end
	end

	assign oMEM_REQ = condition_reqd_req;
	assign oMEM_ADDR = b_read_addr;



	//wire [5:0] fifo_count;
	wire [7:0] fifo_count;
	wire fifo_empty;
	wire [15:0] fifo_data;
	//vga_async_fifo #(16, 64, 5)	VRAMREAD_FIFO1(
	vga_async_fifo #(16, 256, 7)	VRAMREAD_FIFO1(
		.inRESET(inRESET),
		.iRESET_SYNC_WR(iRESET_SYNC_IF || if_synth_fifo_reset),
		.iRESET_SYNC_RD(vga_synth_fifo_reset),
		.iWR_CLOCK(iCLOCK),
		.iWR_EN(iMEM_VALID && from_memory_data_valid),
		.iWR_DATA(iMEM_DATA),
		.oWR_FULL(),
		.oWR_COUNT(fifo_count),
		.iRD_CLOCK(iVGA_CLOCK),
		.iRD_EN(iPIXEL_DATA_REQ && !vga_synth_fifo_reset && !fifo_empty),
		.oRD_DATA(fifo_data),
		.oRD_EMPTY(fifo_empty),
		.oRD_COUNT()
	);
	
	assign oPIXEL_DATA_DATA = /*16'hffff;*/fifo_data;

	assign oPIXEL_DATA_EMPTY = fifo_empty;




endmodule

`default_nettype wire

