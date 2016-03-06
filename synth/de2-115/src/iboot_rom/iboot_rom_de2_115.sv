


`default_nettype none


module iboot_rom_de2_115(
		//System
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//ASMI
		input wire iCLOCK_ASMI,		//~20MHz
		input wire iRESET_ASMI_SYNC,
		//IBOOT
		output wire oIBOOT_VALID,
		output wire oIBOOT_MEMIF_REQ_VALID,
		output wire oIBOOT_MEMIF_REQ_DQM0,
		output wire oIBOOT_MEMIF_REQ_DQM1,
		output wire oIBOOT_MEMIF_REQ_DQM2,
		output wire oIBOOT_MEMIF_REQ_DQM3,
		output wire oIBOOT_MEMIF_REQ_RW,
		output wire [24:0] oIBOOT_MEMIF_REQ_ADDR,
		output wire [31:0] oIBOOT_MEMIF_REQ_DATA,
		input wire iIBOOT_MEMIF_REQ_LOCK
	);
	
	localparam PL_STT_GET0 = 3'h0;
	localparam PL_STT_GET1 = 3'h1;
	localparam PL_STT_GET2 = 3'h2;
	localparam PL_STT_GET3 = 3'h3;
	localparam PL_STT_WRITE = 3'h4;
	localparam PL_STT_END = 3'h5;
	
	//Flash Read Request State
	reg [23:0] b_rd_counter;
	//Flash Get State
	reg b_get_end;
	reg [21:0] b_get_counter;
	reg [2:0] b_get_state;
	reg [7:0] b_get_data0;
	reg [7:0] b_get_data1;
	reg [7:0] b_get_data2;
	reg [7:0] b_get_data3;
	//Flash Controllor Instance
	wire rd_req_busy;
	wire get_empty;
	wire [7:0] get_data;
	wire get_rd_condition = (
		b_get_state == PL_STT_GET0 || 
		b_get_state == PL_STT_GET1 || 
		b_get_state == PL_STT_GET2 || 
		b_get_state == PL_STT_GET3)? 
			!get_empty && !b_get_end : 1'b0;
	
	
	/****************************
	Flash Instance
	****************************/
	iboot_rom_asmi_reader #(23, 8, 8, 3) FLASH_CONTROLLOR(
		//iCLOCK
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//ASMI
		.iCLOCK_ASMI(iCLOCK_ASMI),
		.iRESET_ASMI_SYNC(iRESET_ASMI_SYNC),
		//CPU-Request
		.iCPU_RQ_REQ(!b_get_end && !rd_req_busy),
		.oCPU_RQ_BUSY(rd_req_busy),
		.iCPU_RQ_ADDR(b_rd_counter[22:0]),		
		//CPU-Output
		.iCPU_RD_REQ(get_rd_condition),
		.oCPU_RD_BUSY(get_empty),
		.oCPU_RD_DATA(get_data)
	);


	
	
	//Flash Read 
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_rd_counter <= 24'h0;
		end
		else if(iRESET_SYNC)begin
			b_rd_counter <= 24'h0;
		end
		else begin
			if(!b_get_end)begin
				if(!rd_req_busy)begin
					b_rd_counter <= b_rd_counter + 24'h1;
				end
			end
		end
	end
			
	//Flash Get State
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_get_state <= 3'h0;
		end
		else if(iRESET_SYNC)begin
			b_get_state <= 3'h0;
		end
		else begin
			case(b_get_state)
				PL_STT_GET0:
					begin
						if(b_get_counter == 22'h8000)begin			//Synth
						//if(b_get_counter == 22'h40000)begin
						//if(b_get_counter == 22'h200000)begin
							b_get_state <= PL_STT_END;	
						end
						else begin
							if(!get_empty)begin
								b_get_state <= PL_STT_GET1;
							end
						end
					end
				PL_STT_GET1:
					begin
						if(!get_empty)begin
							b_get_state <= PL_STT_GET2;
						end
					end
				PL_STT_GET2:
					begin
						if(!get_empty)begin
							b_get_state <= PL_STT_GET3;
						end
					end
				PL_STT_GET3:
					begin
						if(!get_empty)begin
							b_get_state <= PL_STT_WRITE;
						end
					end
				PL_STT_WRITE:
					begin
						if(!iIBOOT_MEMIF_REQ_LOCK)begin
							b_get_state <= PL_STT_GET0;	
						end
					end
			endcase	
		end
	end



	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_get_end <= 1'b0;
			b_get_counter <= 22'h0;
			b_get_data0 <= 8'h0;
			b_get_data1 <= 8'h0;
			b_get_data2 <= 8'h0;
			b_get_data3 <= 8'h0;
		end
		else if(iRESET_SYNC)begin
			b_get_end <= 1'b0;
			b_get_counter <= 22'h0;
			b_get_data0 <= 8'h0;
			b_get_data1 <= 8'h0;
			b_get_data2 <= 8'h0;
			b_get_data3 <= 8'h0;
		end
		else begin
			case(b_get_state)
				PL_STT_GET0:
					begin
						if(b_get_counter == 22'h8000)begin			//Synth
						//if(b_get_counter == 22'h1900)begin			// for Sim
							b_get_end <= 1'b1;
						end
						else begin
							if(!get_empty)begin
								b_get_data0 <= get_data;
							end
						end
					end
				PL_STT_GET1:
					begin
						if(!get_empty)begin
							b_get_data1 <= get_data;
						end
					end
				PL_STT_GET2:
					begin
						if(!get_empty)begin
							b_get_data2 <= get_data;
						end
					end
				PL_STT_GET3:
					begin
						if(!get_empty)begin
							b_get_data3 <= get_data;
						end
					end
				PL_STT_WRITE:
					begin
						if(!iIBOOT_MEMIF_REQ_LOCK)begin	
							b_get_counter <= b_get_counter + 22'h1;
						end
					end
				PL_STT_END:
					begin
						b_get_end <= 1'b1;
					end
			endcase	
		end
	end
	
	
	assign oIBOOT_VALID = !b_get_end;
	assign oIBOOT_MEMIF_REQ_VALID = (b_get_state == PL_STT_WRITE)? !iIBOOT_MEMIF_REQ_LOCK : 1'b0;
	assign oIBOOT_MEMIF_REQ_DQM0 = 1'b0;
	assign oIBOOT_MEMIF_REQ_DQM1 = 1'b0;
	assign oIBOOT_MEMIF_REQ_DQM2 = 1'b0;
	assign oIBOOT_MEMIF_REQ_DQM3 = 1'b0;
	assign oIBOOT_MEMIF_REQ_RW = 1'b1;	//0:Read 1:Write
	assign oIBOOT_MEMIF_REQ_ADDR = {3'h0, b_get_counter};
	assign oIBOOT_MEMIF_REQ_DATA = {b_get_data3, b_get_data2, b_get_data1, b_get_data0};


endmodule


`default_nettype wire

