

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
		input wire [19:0] iREAD_ADDR,
		output wire oREAD_BUSY,
		output wire oREAD_VALID,
		output wire [15:0] oREAD_DATA,
		//Write Port
		input wire iWRITE_REQ,
		input wire [19:0] iWRITE_ADDR,
		input wire [15:0] iWRITE_DATA,
		output wire oWRITE_BUSY,
		//Memory IF
		output wire oMEM_VALID,
		output wire [1:0] oMEM_BYTEENA,
		output wire oMEM_RW,
		output wire [31:0] oMEM_ADDR,
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
	reg [19:0] b_addr;
	reg [15:0] b_data;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_req <= 1'b0;
			b_rw <= 1'b0;
			b_addr <= 20'h0;
			b_data <= 16'h0;
		end
		else if(iRESET_SYNC)begin
			b_req <= 1'b0;
			b_rw <= 1'b0;
			b_addr <= 20'h0;
			b_data <= 16'h0;
		end
		else begin
			if(!iMEM_BUSY)begin
				b_req <= (iREAD_ENABLE && iREAD_REQ) || (!iREAD_ENABLE && iWRITE_REQ);
				b_rw <= !iREAD_ENABLE;
				b_addr <= (iREAD_ENABLE)? iREAD_ADDR : iWRITE_ADDR;
				b_data <= iWRITE_DATA;
			end
		end
	end
	
	assign oMEM_VALID = b_req;
	assign oMEM_BYTEENA = 2'b00;
	assign oMEM_RW = b_rw;
	assign oMEM_ADDR = {12'h0, b_addr};
	assign oMEM_DATA = b_data;

	assign oMEM_BUSY = 1'b0;



	
endmodule
















//vga_vram_interrconnect
module vga_vram_control_old(
		//System
		input wire iCLOCK,
		input wire iVGA_CLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//Read Port
		input wire iREAD_REQ,
		input wire [19:0] iREAD_ADDR,
		output wire oREAD_BUSY,
		output wire oREAD_VALID,
		output wire [15:0] oREAD_DATA,
		//Write Port
		input wire iWRITE_REQ,
		input wire [19:0] iWRITE_ADDR,
		input wire [15:0] iWRITE_DATA,
		output wire oWRITE_BUSY,
		//Memory IF
		output wire oMEM_VALID,
		output wire [1:0] oMEM_BYTEENA,
		output wire oMEM_RW,
		output wire [31:0] oMEM_ADDR,
		output wire [15:0] oMEM_DATA,
		input wire iMEM_BUSY,
		input wire iMEM_VALID,
		input wire [15:0] iMEM_DATA,
		output wire oMEM_BUSY
	);

	assign oREAD_VALID = iMEM_VALID;
	assign oREAD_DATA = iMEM_DATA;

	assign oREAD_BUSY = priority_signal || iMEM_BUSY;
	assign oWRITE_BUSY = !priority_signal || iMEM_BUSY; 

	reg b_req;
	reg b_rw;
	reg [19:0] b_addr;
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
			if(!iMEM_BUSY)begin
				b_req <= iREAD_REQ || iWRITE_REQ;
				b_rw <= condition_write_req;
				b_addr <= (condition_read_req)? iREAD_ADDR : iWRITE_ADDR;
				b_data <= iWRITE_DATA;
			end
		end
	end
	
	assign oMEM_VALID = b_req;
	assign oMEM_BYTEENA = 2'b00;
	assign oMEM_RW = b_rw;
	assign oMEM_ADDR = {12'h0, b_addr};
	assign oMEM_DATA = b_data;

	assign oMEM_BUSY = 1'b0;

	wire condition_read_req = !priority_signal && iREAD_REQ && !iMEM_BUSY;


	//Read Histry
	reg b_read_buff;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_read_buff <= 3'h0;
		end
		else if(iRESET_SYNC)begin
			b_read_buff <= 3'h0;
		end
		else begin
			b_read_buff <= condition_read_req;
		end
	end


	//Read Count
	reg [2:0] b_read_count;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_read_count <= 3'h0;
		end
		else if(iRESET_SYNC)begin
			b_read_count <= 3'h0;
		end
		else begin
			if((!b_read_buff && condition_read_req) || (b_read_buff && condition_read_req))begin
				if(b_read_count != 3'h7)begin
					b_read_count <= b_read_count + 3'h1;
				end
			end
			else begin
				b_read_count <= 3'h0;
			end
		end
	end


	wire condition_write_req = priority_signal && iWRITE_REQ && !iMEM_BUSY;


	//Read Histry
	reg b_write_buff;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_write_buff <= 3'h0;
		end
		else if(iRESET_SYNC)begin
			b_write_buff <= 3'h0;
		end
		else begin
			b_write_buff <= condition_write_req;
		end
	end


	//Read Count
	reg [2:0] b_write_count;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_write_count <= 3'h0;
		end
		else if(iRESET_SYNC)begin
			b_write_count <= 3'h0;
		end
		else begin
			if((!b_write_buff && condition_write_req) || (b_write_buff && condition_write_req))begin
				if(b_write_count != 3'h7)begin
					b_write_count <= b_write_count + 3'h1;
				end
			end
			else begin
				b_write_count <= 3'h0;
			end
		end
	end

	
	wire priority_signal = func_priority_encoder(
		iREAD_REQ,
		b_read_count,
		iWRITE_REQ,
		b_write_count
	);



	//0 : Read
	//1 : Write
	function func_priority_encoder;
		input func_read_req;
		input [2:0] func_read_count;
		input func_write_req;
		input [2:0] func_write_count;
		begin
			if(func_read_req && func_write_req)begin
				if(func_read_count > func_write_count)begin
					func_priority_encoder = 1'b1;
				end
				else begin
					func_priority_encoder = 1'b0;
				end
			end
			else if(func_read_req)begin
				func_priority_encoder = 1'b0;
			end
			else if(func_write_req)begin
				func_priority_encoder = 1'b1;
			end
			else begin
				func_priority_encoder = 1'b0;
			end
		end
	endfunction


	
endmodule



`default_nettype wire
