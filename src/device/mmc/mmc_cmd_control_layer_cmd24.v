`default_nettype none

//Write Command
module mmc_cmd_control_layer_cmd24(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//
		input wire iCMD_START,
		input wire [31:0] iCMD_ADDR,
		output wire oCMD_END,
		//Buffer
		output [6:0] oBUFF_ADDR,
		input [31:0] iBUFF_DATA,
		//Write
		output wire oMMC_REQ,
		input wire iMMC_BUSY,
		output wire oMMC_CS,
		output wire [7:0] oMMC_DATA,
		//Read
		input wire iMMC_VALID,
		input wire [7:0] iMMC_DATA,
		input wire iMMC_INFO_MISO
	);

	localparam PL_MAIN_STT_IDLE = 4'h0;
	localparam PL_MAIN_STT_CMD = 4'h1;
	localparam PL_MAIN_STT_RESP_REQ = 4'h2;
	localparam PL_MAIN_STT_RESP_GET = 4'h3;
	localparam PL_MAIN_STT_WAIT_REQ = 4'h4;
	localparam PL_MAIN_STT_WAIT_GET = 4'h5;
	localparam PL_MAIN_STT_STBLOCK_WRITE = 4'h6;
	localparam PL_MAIN_STT_DATA_WRITE = 4'h7;
	localparam PL_MAIN_STT_CRC_WRITE = 4'h8;
	localparam PL_MAIN_STT_DATARESP_REQ = 4'h9;
	localparam PL_MAIN_STT_DATARESP_GET = 4'ha;
	localparam PL_MAIN_STT_BUSYCHECK_REQ = 4'hb;
	localparam PL_MAIN_STT_BUSYCHECK_GET = 4'hc;
	localparam PL_MAIN_STT_DUMMY_REQ = 4'hd;
	localparam PL_MAIN_STT_DUMMY_GET = 4'he;
	localparam PL_MAIN_STT_END = 4'hf;

	function [7:0] func_cmd_flame;
		input [2:0] func_select;
		input [31:0] func_addr;
		begin
			case(func_select)
				3'h0 : func_cmd_flame = 8'h58;
				3'h1 : func_cmd_flame = func_addr[31:24];
				3'h2 : func_cmd_flame = func_addr[23:16];
				3'h3 : func_cmd_flame = func_addr[15:8];
				3'h4 : func_cmd_flame = func_addr[7:0];
				3'h5 : func_cmd_flame = 8'h01;
				default : func_cmd_flame = 8'h00;
			endcase
		end
	endfunction

	reg [3:0] b_main_state;
	reg [9:0] b_main_count;
	reg [31:0] b_main_addr;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_main_state <= PL_MAIN_STT_IDLE;
			b_main_count <= 10'h0;
			b_main_addr <= 32'h0;
		end
		else if(iRESET_SYNC)begin
			b_main_state <= PL_MAIN_STT_IDLE;
			b_main_count <= 10'h0;
			b_main_addr <= 32'h0;
		end
		else begin
			case(b_main_state)
				PL_MAIN_STT_IDLE:
					begin
						if(iCMD_START)begin
							b_main_state <= PL_MAIN_STT_CMD;
							b_main_count <= 10'h0;
							b_main_addr <= iCMD_ADDR;
						end
					end
				PL_MAIN_STT_CMD:
					begin
						if(b_main_count >= 10'h6)begin
							b_main_state <= PL_MAIN_STT_RESP_REQ;
						end
						else begin
							if(!iMMC_BUSY)begin
								b_main_count <= b_main_count + 10'h1;
							end
						end
					end
				PL_MAIN_STT_RESP_REQ:
					begin
						if(!iMMC_BUSY)begin
							b_main_count <= 10'h0;
							b_main_state <= PL_MAIN_STT_RESP_GET;
						end
					end
				PL_MAIN_STT_RESP_GET:
					begin
						if(iMMC_VALID)begin
							if(iMMC_DATA == 8'h00)begin
								b_main_state <= PL_MAIN_STT_WAIT_REQ;
							end
							else begin
								b_main_state <= PL_MAIN_STT_RESP_REQ;
							end
						end
					end
				PL_MAIN_STT_WAIT_REQ:
					begin
						if(!iMMC_BUSY)begin
							b_main_count <= 10'h0;
							b_main_state <= PL_MAIN_STT_WAIT_GET;
						end
					end
				PL_MAIN_STT_WAIT_GET:
					begin
						if(iMMC_VALID)begin
							b_main_state <= PL_MAIN_STT_STBLOCK_WRITE;
						end
					end
				PL_MAIN_STT_STBLOCK_WRITE:
					begin
						if(!iMMC_BUSY)begin
							b_main_count <= 10'h0;
							b_main_state <= PL_MAIN_STT_DATA_WRITE;
						end
					end
				PL_MAIN_STT_DATA_WRITE:
					begin
						if(b_main_count >= 10'd512)begin
							b_main_state <= PL_MAIN_STT_CRC_WRITE;
							b_main_count <= 10'h0;
						end
						else begin
							if(!iMMC_BUSY)begin
								b_main_count <= b_main_count + 10'h1;
							end
						end
					end
				PL_MAIN_STT_CRC_WRITE:
					begin
						if(b_main_count >= 10'd2)begin
							b_main_state <= PL_MAIN_STT_DATARESP_REQ;
							b_main_count <= 10'h0;
						end
						else begin
							if(!iMMC_BUSY)begin
								b_main_count <= b_main_count + 10'h1;
							end
						end
					end
				PL_MAIN_STT_DATARESP_REQ:
					begin
						if(!iMMC_BUSY)begin
							b_main_count <= 10'h0;
							b_main_state <= PL_MAIN_STT_DATARESP_GET;
						end
					end
				PL_MAIN_STT_DATARESP_GET:
					begin
						if(iMMC_VALID)begin
							if(iMMC_DATA[4:0] == 5'h05)begin
								b_main_state <= PL_MAIN_STT_BUSYCHECK_REQ;
							end
							else begin
								b_main_state <= PL_MAIN_STT_DATARESP_REQ;
							end
						end
					end
				PL_MAIN_STT_BUSYCHECK_REQ:
					begin
						if(!iMMC_BUSY)begin
							b_main_state <= PL_MAIN_STT_BUSYCHECK_GET;
						end
					end
				PL_MAIN_STT_BUSYCHECK_GET:
					begin
						if(iMMC_VALID)begin
							if(iMMC_DATA[0] == 1'b1)begin
								b_main_state <= PL_MAIN_STT_DUMMY_REQ;
							end
							else begin
								b_main_state <= PL_MAIN_STT_BUSYCHECK_REQ;
							end
						end
					end
					
				PL_MAIN_STT_DUMMY_REQ:
					begin
						if(!iMMC_BUSY)begin
							b_main_count <= 10'h0;
							b_main_state <= PL_MAIN_STT_DUMMY_GET;
						end
					end
				PL_MAIN_STT_DUMMY_GET:
					begin
						if(iMMC_VALID)begin
							b_main_state <= PL_MAIN_STT_END;
						end
					end
					
				PL_MAIN_STT_END:
					begin
						b_main_state <= PL_MAIN_STT_IDLE;
					end
			endcase
		end
	end


	function [7:0] func_mmc_data_select;
		input [1:0] func_select;
		input [31:0] func_data;
		begin
			case(func_select)
				2'h0 : func_mmc_data_select = func_data[7:0];
				2'h1 : func_mmc_data_select = func_data[15:8];
				2'h2 : func_mmc_data_select = func_data[23:16];
				2'h3 : func_mmc_data_select = func_data[31:24];
			endcase
		end
	endfunction

	reg [7:0] mmc_data_out;
	always @* begin
		if(b_main_state == PL_MAIN_STT_CMD)begin
			mmc_data_out = func_cmd_flame(b_main_count, b_main_addr);
		end
		else if(b_main_state == PL_MAIN_STT_STBLOCK_WRITE)begin
			mmc_data_out = 8'hfe;
		end
		else if(b_main_state == PL_MAIN_STT_DATA_WRITE)begin
			mmc_data_out = func_mmc_data_select(b_main_count[1:0], iBUFF_DATA);
		end
		else begin
			mmc_data_out = 8'hff;
		end
	end

	assign oBUFF_ADDR = b_main_count[8:2];

	assign oCMD_END = (b_main_state == PL_MAIN_STT_END);

	assign oMMC_REQ = !iMMC_BUSY && (b_main_state == PL_MAIN_STT_CMD || b_main_state == PL_MAIN_STT_RESP_REQ || b_main_state == PL_MAIN_STT_WAIT_REQ || b_main_state == PL_MAIN_STT_STBLOCK_WRITE || b_main_state == PL_MAIN_STT_DATA_WRITE || b_main_state == PL_MAIN_STT_CRC_WRITE || b_main_state == PL_MAIN_STT_DATARESP_REQ || b_main_state == PL_MAIN_STT_BUSYCHECK_REQ || b_main_state == PL_MAIN_STT_DUMMY_REQ);
	
	assign oMMC_CS = (b_main_state == PL_MAIN_STT_IDLE || b_main_state == PL_MAIN_STT_END)? 1'b1 : 1'b0;
	assign oMMC_DATA = mmc_data_out;



endmodule













`default_nettype wire 



