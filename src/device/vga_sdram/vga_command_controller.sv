
`default_nettype none

/***********************************************************************************
Command (Address)
	0x000						: Display Clear (Data : Collor 12bit = 4R4G4B)
	0x100~0x4B000				: Display Bitmap (Data : Collor 12bit = 4R4G4B)
***********************************************************************************/

module vga_command_controller(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//BUS
		input wire iBUSMOD_REQ,
		input wire [31:0] iBUSMOD_ADDR,
		input wire [31:0] iBUSMOD_DATA,
		output wire oBUSMOD_WAIT,
		//VRAM
		input wire iVRAM_WAIT,
		output wire oVRAM_WRITE_REQ,
		output wire [18:0] oVRAM_WRITE_ADDR,
		output wire [15:0] oVRAM_WRITE_DATA
	);
	
	localparam PL_STT_IDLE = 2'h0;
	localparam PL_STT_CLEAR = 2'h1;
	localparam PL_STT_BITMAP = 2'h2;

	//Lock Controll
	wire state_lock = iVRAM_WAIT;
										
	//State Controller				
	reg [1:0] main_state;
	reg [15:0] req_data;
	reg [18:0] vram_addr;
	//Font ROM
	wire [111:0] font_rom_data;
	
	//State
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			main_state <= PL_STT_IDLE;
		end
		else if(iRESET_SYNC)begin
			main_state <= PL_STT_IDLE;
		end
		else begin
			if(!state_lock)begin
				case(main_state)
					PL_STT_IDLE : //Idle
						begin
							if(iBUSMOD_REQ)begin
								if(iBUSMOD_ADDR == 32'h00000000)begin
									main_state <= PL_STT_CLEAR;	//for simulate	//PL_STT_BITMAP;
								end
								else if(iBUSMOD_ADDR >= 32'h00000100 && iBUSMOD_ADDR < 19'h4B0ff)begin
									main_state <= PL_STT_BITMAP;
								end
							end
						end
					PL_STT_CLEAR : //DisplayClear
						begin
							if(!(vram_addr < 19'h4B000))begin
								main_state <= PL_STT_IDLE;
							end
						end
					PL_STT_BITMAP : //Bitmap
						begin
							main_state <= PL_STT_IDLE;
						end
				endcase	
			end
		end
	end //always
	
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			req_data <= {16{1'b0}};
			vram_addr <= {19{1'b0}};
		end
		else if(iRESET_SYNC)begin
			req_data <= {16{1'b0}};
			vram_addr <= {19{1'b0}};
		end
		else begin
			if(!state_lock)begin
				case(main_state)
					PL_STT_IDLE : //Idle
						begin
							if(iBUSMOD_REQ)begin
								if(iBUSMOD_ADDR == 32'h00000000)begin
									req_data <= iBUSMOD_DATA[15:0];
									vram_addr <= {19{1'b0}};
								end
								else if(iBUSMOD_ADDR >= 32'h00000100 && iBUSMOD_ADDR < 19'h4b0ff)begin
									req_data <= iBUSMOD_DATA[15:0];
									vram_addr <= iBUSMOD_ADDR - 32'h00000100;
								end
							end
						end
					PL_STT_CLEAR : //DisplayClear
						begin
							if(vram_addr < 19'h4B000)begin
								vram_addr <= vram_addr + 19'h00001;
							end 
						end
				endcase	
			end
		end
	end //always

	
	//Assignment Module Output
	assign oBUSMOD_WAIT = state_lock || (main_state != PL_STT_IDLE);
	assign oVRAM_WRITE_REQ = !state_lock && (main_state != PL_STT_IDLE);
	assign oVRAM_WRITE_ADDR = vram_addr;
	assign oVRAM_WRITE_DATA = req_data;
	
endmodule

`default_nettype wire
