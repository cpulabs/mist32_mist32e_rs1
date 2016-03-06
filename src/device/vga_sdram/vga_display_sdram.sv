/***********************************************************************************
MIST32 Default Device : Display Device
	- Display Area 640*480
	- Framelate 60Hz
	- Dot Clock 25.17MHz
	- DAC is ADV7123

		
Command (Address)
	0x000						: Display Clear (Data : Collor 12bit = 4R4G4B)
	0x100~0x4B000				: Display Bitmap (Data : Collor 12bit = 4R4G4B)
***********************************************************************************/
`default_nettype none


module vga_display_sdram(
		//System
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//BUS(DATA)-Input
		input wire iDEV_REQ,		
		output wire oDEV_BUSY,
		input wire iDEV_RW,
		input wire [31:0] iDEV_ADDR,
		input wire [31:0] iDEV_DATA,
		//BUS(DATA)-Output
		output wire oDEV_REQ,		
		input wire iDEV_BUSY,
		output wire [31:0] oDEV_DATA,
		//IRQ
		output wire oDEV_IRQ_REQ,		
		input wire iDEV_IRQ_BUSY, 
		input wire iDEV_IRQ_ACK,
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
		output wire [7:0] oADV_R,
		output wire [7:0] oADV_G,
		output wire [7:0] oADV_B
	);					
	
	
	
	/************************************************************
	Wire
	************************************************************/
	//Display Controllor
	wire displaycontroller_wait;
	//Condition
	wire display_addr_wr_condition;
	//Data Output Buffer
	reg b_req;
	reg [31:0] b_data;
	
	/************************************************************
	Condition
	************************************************************/
	assign display_addr_wr_condition = iDEV_REQ && !displaycontroller_wait;

	/************************************************************
	Display Controller
	************************************************************/		
	vga_640x480_60hz_adv7123 DISPLAY_MODULE(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),		
		//Write Reqest
		.iDISP_WR_REQ(display_addr_wr_condition),
		.oDISP_WR_BUSY(displaycontroller_wait),
		.iDISP_WR_ADDR({2'h0, iDEV_ADDR[31:2]}),
		.iDISP_WR_DATA(iDEV_DATA),
		//Display Clock
		.iVGA_CLOCK(iVGA_CLOCK),
		//SDRAM
		.*,
		//Display
		.oDISP_HSYNC(oDISP_HSYNC),
		.oDISP_VSYNC(oDISP_VSYNC),
		//ADV7123 Output
		.oADV_CLOCK(oADV_CLOCK),
		.onADV_BLANK(onADV_BLANK),
		.onADV_SYNC(onADV_SYNC),
		.oADV_R(oADV_R),
		.oADV_G(oADV_G),
		.oADV_B(oADV_B)
	);	
	
	/************************************************************
	Output Buffer
	************************************************************/	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_req <= 1'b0;
			b_data <= {32{1'b0}};
		end
		else if(iRESET_SYNC)begin
			b_req <= 1'b0;
			b_data <= {32{1'b0}};
		end
		else begin
			b_req <= 1'b0;//display_addr_wr_condition;
			b_data <= {32{1'b0}};
		end
	end
	
	
	/************************************************************
	Assign
	************************************************************/	
	assign oDEV_BUSY = displaycontroller_wait;
	assign oDEV_REQ = b_req;
	assign oDEV_DATA = b_data;
	assign oDEV_IRQ_REQ = 1'b0;
	

endmodule


`default_nettype wire
