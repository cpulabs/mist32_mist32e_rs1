
`default_nettype none

module vga_640x480_60hz_adv7123(
		//System
		input wire iCLOCK,
		input wire inRESET,		
		input wire iRESET_SYNC,		
		//Write Reqest
		input wire iDISP_WR_REQ,
		output wire oDISP_WR_BUSY,
		input wire [31:0] iDISP_WR_ADDR,
		input wire [31:0] iDISP_WR_DATA,
		//Display Clock
		input wire iVGA_CLOCK,
		//SDRAM
		output wire oMEM_VALID,
		output wire [1:0] oMEM_BYTEENA,
		output wire oMEM_RW,
		output wire [31:0] oMEM_ADDR,
		output wire [15:0] oMEM_DATA,
		input wire iMEM_BUSY,
		input wire iMEM_VALID,
		input wire [15:0] iMEM_DATA,
		output wire oMEM_BUSY,
		//Display
		output wire oDISP_HSYNC,
		output wire oDISP_VSYNC,
		//ADV7123 Output
		output wire oADV_CLOCK,
		output wire onADV_BLANK,
		output wire onADV_SYNC,
		output wire [3:0] oADV_R,
		output wire [3:0] oADV_G,
		output wire [3:0] oADV_B
	);


	/**********************************************************
	Make for Disp Clock Reset
	**********************************************************/
	reg [1:0] b_reset_delay;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_reset_delay <= 2'h0;
		end
		else if(iRESET_SYNC)begin
			b_reset_delay <= 2'h0;
		end
		else begin
			b_reset_delay <= (b_reset_delay != 2'hf)? b_reset_delay + 2'h1 : b_reset_delay;
		end
	end

	reg b_disp_sync_reset_buff0;
	reg b_disp_sync_reset_buff1;

	always@(posedge iVGA_CLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_disp_sync_reset_buff0 <= 1'h0;
			b_disp_sync_reset_buff1 <= 1'h0;
		end
		else begin
			b_disp_sync_reset_buff0 <= !(b_reset_delay == 2'hf);
			b_disp_sync_reset_buff1 <= b_disp_sync_reset_buff0;
		end
	end


	wire disp_sync_reset = b_disp_sync_reset_buff1;


	/**********************************************************
	Display
	**********************************************************/
	//VRAM Write Command Controller 
	wire bus_req_wait;
	wire vram_write_req;
	wire [18:0] vram_write_addr;
	wire [15:0] vram_write_data;
	// VRAM Controll 
	wire VramWriteFull;
	wire [15:0] VramReadData;
	wire SramRw;
	wire [15:0] SramWriteData;
	//Display Timing
	wire disptiming_data_req;
	wire disptiming_vsync;
	wire disptiming_hsync;
	wire disptiming_blank;
	
	//VRAM Write Command Controller 
	vga_command_controller CMD_CONTROLLER(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		.iBUSMOD_REQ(iDISP_WR_REQ && !bus_req_wait),
		.iBUSMOD_ADDR(iDISP_WR_ADDR),
		.iBUSMOD_DATA(iDISP_WR_DATA),
		.oBUSMOD_WAIT(bus_req_wait),
		.iVRAM_WAIT(VramWriteFull),
		.oVRAM_WRITE_REQ(vram_write_req),
		.oVRAM_WRITE_ADDR(vram_write_addr),
		.oVRAM_WRITE_DATA(vram_write_data)
	);


	wire vram_write_to_vramctrl_req;
	wire [18:0] vram_write_to_vramctrl_addr;
	wire [15:0] vram_write_to_vramctrl_data;
	wire vram_write_to_vramctrl_busy;
	
	vga_vram_control_write_pixel VRAM_WRITE(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC_IF(iRESET_SYNC),
		//IF	
		.iPIXEL_REQ(vram_write_req),
		.iPIXEL_ADDR(vram_write_addr),
		.iPIXEL_DATA(vram_write_data),
		.oPIXEL_FULL(VramWriteFull),
		//MEM
		.oMEM_REQ(vram_write_to_vramctrl_req),
		.oMEM_ADDR({1'b0, vram_write_to_vramctrl_addr}),
		.oMEM_DATA(vram_write_to_vramctrl_data),
		.iMEM_BUSY(vram_write_to_vramctrl_busy)
	);

	wire vram_read_readstate;
	wire vram_read_req;
	wire [19:0] vram_read_addr;
	wire vram_read_req_busy;
	wire vram_read_result_valid;
	wire [15:0] vram_read_result_data;
	vga_vram_control VRAM_CTRL(
		//System
		.iCLOCK(iCLOCK),
		.iVGA_CLOCK(iVGA_CLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//Read Port
		.iREAD_ENABLE(vram_read_readstate),
		.iREAD_REQ(vram_read_req),
		.iREAD_ADDR(vram_read_addr),
		.oREAD_BUSY(vram_read_req_busy),
		.oREAD_VALID(vram_read_result_valid),
		.oREAD_DATA(vram_read_result_data),
		//Write Port
		.iWRITE_REQ(vram_write_to_vramctrl_req),
		.iWRITE_ADDR(vram_write_to_vramctrl_addr),
		.iWRITE_DATA(vram_write_to_vramctrl_data),
		.oWRITE_BUSY(vram_write_to_vramctrl_busy),
		//Memory IF
		.oMEM_VALID(oMEM_VALID),
		.oMEM_BYTEENA(oMEM_BYTEENA),
		.oMEM_RW(oMEM_RW),
		.oMEM_ADDR(oMEM_ADDR),
		.oMEM_DATA(oMEM_DATA),
		.iMEM_BUSY(iMEM_BUSY),
		.iMEM_VALID(iMEM_VALID),
		.iMEM_DATA(iMEM_DATA),
		.oMEM_BUSY(oMEM_BUSY)
	);

	
	vga_vram_control_read_pixel VRAM_READ(
		//System
		.iCLOCK(iCLOCK),
		.iVGA_CLOCK(iVGA_CLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC_IF(iRESET_SYNC),
		//MEM
		.oMEM_READSTATE(vram_read_readstate),
		.oMEM_REQ(vram_read_req),
		.oMEM_ADDR(vram_read_addr),
		.iMEM_BUSY(vram_read_req_busy),
		.iMEM_VALID(vram_read_result_valid),
		.iMEM_DATA(vram_read_result_data),
		//iBMP Read
		.iPIXEL_VSYNC(!disptiming_vsync),//disp_sync_reset),
		.iPIXEL_DATA_REQ(disptiming_data_req),
		.oPIXEL_DATA_DATA(VramReadData),
		.oPIXEL_DATA_EMPTY()
	);

	
	//Display timing 
	vga_sync_timing_640x480_60hz DISPTIMING_640X480_60HZ(
		.iVGA_CLOCK(iVGA_CLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(disp_sync_reset),
		.oDATA_REQ(disptiming_data_req),
		.oDISP_VSYNC(disptiming_vsync),
		.oDISP_HSYNC(disptiming_hsync),
		.oDISP_BLANK(disptiming_blank)
	);
	
	
	//Display output wire latch
	reg [3:0] b_disp_buff_r, b_disp_buff_g, b_disp_buff_b;
	reg b_disp_buff_brank, b_disp_buff_vsync, b_disp_buff_hsync;
	
	always@(posedge iVGA_CLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_disp_buff_r <= 4'h0;
			b_disp_buff_g <= 4'h0;
			b_disp_buff_b <= 4'h0;
			b_disp_buff_brank <= 1'b0;
			b_disp_buff_vsync <= 1'b0;
			b_disp_buff_hsync <= 1'b0;
		end
		else if(disp_sync_reset)begin
			b_disp_buff_r <= 4'h0;
			b_disp_buff_g <= 4'h0;
			b_disp_buff_b <= 4'h0;
			b_disp_buff_brank <= 1'b0;
			b_disp_buff_vsync <= 1'b0;
			b_disp_buff_hsync <= 1'b0;
		end
		else begin
			b_disp_buff_r <= (!disptiming_data_req)? 4'h0 : VramReadData[15:12];//{VramReadData[15:11], VramReadData[11], VramReadData[11], VramReadData[11]};
			b_disp_buff_g <= (!disptiming_data_req)? 4'h0 : VramReadData[10:7];//{VramReadData[10:5], VramReadData[5], VramReadData[5]};
			b_disp_buff_b <= (!disptiming_data_req)? 4'h0 : VramReadData[4:1];//{VramReadData[4:0], VramReadData[0], VramReadData[0], VramReadData[0]};
			b_disp_buff_brank <= disptiming_blank;
			b_disp_buff_vsync <= disptiming_vsync;
			b_disp_buff_hsync <= disptiming_hsync;
		end
	end
	
	
	//Assign
	assign oADV_CLOCK = iVGA_CLOCK;		
	assign oDISP_WR_BUSY = bus_req_wait;
	
	assign onADV_SYNC = 1'b0;
	
	assign oDISP_VSYNC = b_disp_buff_vsync;
	assign oDISP_HSYNC = b_disp_buff_hsync;
	assign onADV_BLANK = !b_disp_buff_brank;
	assign oADV_R = b_disp_buff_r;
	assign oADV_G = b_disp_buff_g;
	assign oADV_B = b_disp_buff_b;
	
	
	
endmodule

`default_nettype wire

