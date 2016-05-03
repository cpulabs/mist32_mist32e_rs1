`default_nettype none


module mmc_cmd_control_layer_cmd17(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//
		input wire iCMD_START,
		input wire [31:0] iCMD_ADDR,
		output wire oCMD_END,
		//Buffer
		output wire oBUFF_REQ,
		output wire [6:0] oBUFF_ADDR,
		output wire [31:0] oBUFF_DATA,
		//Write
		output wire oMMC_REQ,
		input wire iMMC_BUSY,
		output wire oMMC_CS,
		output wire [7:0] oMMC_DATA,
		//Read
		input wire iMMC_VALID,
		input wire [7:0] iMMC_DATA
	);

	localparam PL_MAIN_STT_IDLE = 4'h0;
	localparam PL_MAIN_STT_CMD = 4'h1;
	localparam PL_MAIN_STT_RESP_REQ = 4'h2;
	localparam PL_MAIN_STT_RESP_GET = 4'h3;
	localparam PL_MAIN_STT_STBLOCK_REQ = 4'h4;
	localparam PL_MAIN_STT_STBLOCK_GET = 4'h5;
	localparam PL_MAIN_STT_DATA_GET = 4'h6;
	localparam PL_MAIN_STT_DATA_WAIT = 4'h7;

	localparam PL_MAIN_STT_DUMMY_REQ = 4'hd;
	localparam PL_MAIN_STT_DUMMY_GET = 4'he;
	
	localparam PL_MAIN_STT_END = 4'h8;

	
	//Data + CRC
	reg [1:0] b_receive_state;
	reg [9:0] b_receive_counter;
	
	localparam PL_RECEIVE_STT_IDLE = 2'h0;
	localparam PL_RECEIVE_STT_DATA_GET = 2'h1;
	localparam PL_RECEIVE_STT_CRC_GET = 2'h2;
	localparam PL_RECEIVE_STT_END = 2'h3;
	
	function [7:0] func_cmd_flame;
		input [2:0] func_select;
		input [31:0] func_addr;
		begin
			case(func_select)
				3'h0 : func_cmd_flame = 8'h51;
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
			b_main_addr <= 32'h0;
		end
		else if(iRESET_SYNC)begin
			b_main_addr <= 32'h0;
		end
		else begin
			if(b_main_state == PL_MAIN_STT_IDLE && iCMD_START)begin
				b_main_addr <= iCMD_ADDR;
			end
		end
	end
		
			

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_main_state <= PL_MAIN_STT_IDLE;
			b_main_count <= 10'h0;
		end
		else if(iRESET_SYNC)begin
			b_main_state <= PL_MAIN_STT_IDLE;
			b_main_count <= 10'h0;
		end
		else begin
			case(b_main_state)
				PL_MAIN_STT_IDLE:
					begin
						if(iCMD_START)begin
							b_main_state <= PL_MAIN_STT_CMD;
							b_main_count <= 10'h0;
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
								b_main_state <= PL_MAIN_STT_STBLOCK_REQ;
							end
							else begin
								b_main_state <= PL_MAIN_STT_RESP_REQ;
							end
						end
					end
				PL_MAIN_STT_STBLOCK_REQ:
					begin
						if(!iMMC_BUSY)begin
							b_main_count <= 10'h0;
							b_main_state <= PL_MAIN_STT_STBLOCK_GET;
						end
					end
				PL_MAIN_STT_STBLOCK_GET:
					begin
						if(iMMC_VALID)begin
							if(iMMC_DATA == 8'hfe)begin
								b_main_state <= PL_MAIN_STT_DATA_GET;
								b_main_count <= 10'h0;
							end
							else begin
								b_main_state <= PL_MAIN_STT_STBLOCK_REQ;
							end
						end
					end
				PL_MAIN_STT_DATA_GET:
					begin
						if(b_main_count >= 10'd514)begin
							b_main_state <= PL_MAIN_STT_DATA_WAIT;
						end
						else begin
							if(!iMMC_BUSY)begin
								b_main_count <= b_main_count + 10'h1;
							end
						end
					end
				PL_MAIN_STT_DATA_WAIT:
					begin
						if(b_receive_state == PL_RECEIVE_STT_END)begin
							b_main_state <= PL_MAIN_STT_DUMMY_REQ;
						end
					end
				PL_MAIN_STT_DUMMY_REQ:
					begin
						if(!iMMC_BUSY)begin
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
				default:
					begin
						b_main_state <= PL_MAIN_STT_IDLE;
					end
			endcase
		end
	end


	//Data + CRC
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_receive_state <= PL_RECEIVE_STT_IDLE;
			b_receive_counter <= 10'h0;
		end
		else if(iRESET_SYNC)begin
			b_receive_state <= PL_RECEIVE_STT_IDLE;
			b_receive_counter <= 10'h0;
		end
		else begin
			case(b_receive_state)
				PL_RECEIVE_STT_IDLE:
					begin
						if(b_main_state == PL_MAIN_STT_DATA_GET)begin
							b_receive_state <= PL_RECEIVE_STT_DATA_GET;
							b_receive_counter <= 10'h0;
						end
					end
				PL_RECEIVE_STT_DATA_GET:
					begin
						if(b_receive_counter >= 10'd512)begin
							b_receive_state <= PL_RECEIVE_STT_CRC_GET;
							b_receive_counter <= 10'h0;
						end
						else begin
							if(iMMC_VALID)begin
								b_receive_counter <= b_receive_counter + 10'h1;
							end
						end
					end
				PL_RECEIVE_STT_CRC_GET:
					begin
						if(b_receive_counter >= 10'h2)begin
							b_receive_state <= PL_RECEIVE_STT_END;
						end
						else begin
							if(iMMC_VALID)begin
								b_receive_counter <= b_receive_counter + 10'h1;
							end
						end
					end
				PL_RECEIVE_STT_END:
					begin
						b_receive_state <= PL_RECEIVE_STT_IDLE;
						b_receive_counter <= 9'h0;
					end
				default:
					begin
						b_receive_state <= PL_RECEIVE_STT_IDLE;
						b_receive_counter <= 9'h0;
					end
			endcase
		end
	end

	//Data Receive Buffer
	reg b_recbuff_valid;
	reg [6:0] b_recbuff_addr;
	reg [31:0] b_recbuff_data;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_recbuff_valid <= 1'b0;
			b_recbuff_addr <= 7'h0;
			b_recbuff_data <= 32'h0;
		end
		else if(iRESET_SYNC)begin
			b_recbuff_valid <= 1'b0;
			b_recbuff_addr <= 7'h0;
			b_recbuff_data <= 32'h0;
		end
		else begin
			b_recbuff_valid <= iMMC_VALID && (b_receive_state == PL_RECEIVE_STT_DATA_GET) && (b_receive_counter[1:0] == 2'h3);//(b_receive_counter != 10'h0) && (b_receive_counter[1:0] == 2'h0);
			if(iMMC_VALID && b_receive_state == PL_RECEIVE_STT_DATA_GET)begin
				b_recbuff_addr <= b_receive_counter[8:2];
				b_recbuff_data <= {iMMC_DATA, b_recbuff_data[31:8]};
			end
		end
	end



	assign oBUFF_REQ = b_recbuff_valid;
	assign oBUFF_ADDR = b_recbuff_addr;
	assign oBUFF_DATA = b_recbuff_data;

	assign oCMD_END = (b_main_state == PL_MAIN_STT_END);

	assign oMMC_REQ = !iMMC_BUSY && (b_main_state == PL_MAIN_STT_CMD || b_main_state == PL_MAIN_STT_RESP_REQ || b_main_state == PL_MAIN_STT_STBLOCK_REQ || b_main_state == PL_MAIN_STT_DATA_GET || b_main_state == PL_MAIN_STT_DUMMY_REQ);//b_receive_state == PL_RECEIVE_STT_DATA_GET || b_receive_state == PL_RECEIVE_STT_CRC_GET);
	assign oMMC_CS = (b_main_state == PL_MAIN_STT_IDLE || b_main_state == PL_MAIN_STT_END)? 1'b1 : 1'b0;
	assign oMMC_DATA = (b_main_state == PL_MAIN_STT_CMD)? func_cmd_flame(b_main_count, b_main_addr) : 8'hff;



endmodule

`default_nettype wire 



