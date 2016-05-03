

`default_nettype none

module mmc_cmd_control_layer_512(
		//System
		input wire inRESET,
		input wire iCLOCK,
		input wire iCLOCK_MMC,
		//Buffer
		output wire [6:0] oBUFF_RD_ADDR,
		input wire [31:0] iBUFF_RD_DATA,
		output wire oBUFF_WR_REQ,
		output wire [6:0] oBUFF_WR_ADDR,
		output wire [31:0] oBUFF_WR_DATA,
		//CMD
		input wire iCMD_REQ,
		input wire [3:0] iCMD_COMMAND,		//0:Init | 1:CMD0 | 2:CMD1 | 3:CMD17 | 4:CMD24 
		input wire [31:0] iCMD_ADDR,
		output wire oCMD_BUSY,
		output wire oCMD_SUCCESS,
		output wire oCMD_ERROR,
		output wire [4:0] oCMD_ERROR_CODE,
		//MMC
		output wire oMMC_CE,
		output wire oMMC_CLK,
		output wire oMMC_MOSI,
		input wire iMMC_MISO
	);
	

	/****************************************
	Busy
	****************************************/
	wire spi_txrx_busy;
	wire system_busy = spi_txrx_busy;
	
	/****************************************
	SPI Control
	****************************************/
	localparam PL_MMC_CTRL_IDLE = 3'h0;
	localparam PL_MMC_CTRL_INIT = 3'h1;
	localparam PL_MMC_CTRL_CMD0 = 3'h2;
	localparam PL_MMC_CTRL_CMD1 = 3'h3;
	localparam PL_MMC_CTRL_CMD16 = 3'h7;
	localparam PL_MMC_CTRL_CMD17 = 3'h4;
	localparam PL_MMC_CTRL_CMD24 = 3'h5;
	localparam PL_MMC_CTRL_WAIT = 3'h6;
	
	wire spi_txrx_init_start = !system_busy && iCMD_REQ && iCMD_COMMAND == 4'h0;
	wire spi_txrx_cmd0_start = !system_busy && iCMD_REQ && iCMD_COMMAND == 4'h1;
	wire spi_txrx_cmd1_start = !system_busy && iCMD_REQ && iCMD_COMMAND == 4'h2;
	wire spi_txrx_cmd16_start = !system_busy && iCMD_REQ && iCMD_COMMAND == 4'h3;
	wire spi_txrx_cmd17_start = !system_busy && iCMD_REQ && iCMD_COMMAND == 4'h4;
	wire spi_txrx_cmd24_start = !system_busy && iCMD_REQ && iCMD_COMMAND == 4'h5;

	wire cmd_init_done;
	wire cmd0_done;
	wire cmd1_done;
	wire cmd16_done;
	wire cmd17_done;
	wire cmd24_done;
	
	wire spi_request_busy;

	wire spi_read_valid;
	wire [7:0] spi_read_data;
	wire spi_read_info_miso;
	
	wire command_done = cmd_init_done || cmd0_done || cmd1_done || cmd16_done || cmd17_done || cmd24_done;

	reg [2:0] b_main_state;
	assign spi_txrx_busy = (b_main_state != PL_MMC_CTRL_IDLE);//b_spi_resp_wait || (b_spi_txrx_command != L_PARAM_SPI_TXRX_STT_IDLE);// || !iMMC_MISO;


	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_main_state <= PL_MMC_CTRL_IDLE;
		end
		else begin
			case(b_main_state)
				PL_MMC_CTRL_IDLE:
					begin
						if(spi_txrx_init_start)begin
							b_main_state <= PL_MMC_CTRL_INIT;
						end
						else if(spi_txrx_cmd0_start)begin
							b_main_state <= PL_MMC_CTRL_CMD0;
						end
						else if(spi_txrx_cmd1_start)begin
							b_main_state <= PL_MMC_CTRL_CMD1;
						end
						else if(spi_txrx_cmd16_start)begin
							b_main_state <= PL_MMC_CTRL_CMD16;
						end
						else if(spi_txrx_cmd17_start)begin
							b_main_state <= PL_MMC_CTRL_CMD17;
						end
						else if(spi_txrx_cmd24_start)begin
							b_main_state <= PL_MMC_CTRL_CMD24;
						end
					end
				PL_MMC_CTRL_INIT,
				PL_MMC_CTRL_CMD0,
				PL_MMC_CTRL_CMD1,
				PL_MMC_CTRL_CMD16,
				PL_MMC_CTRL_CMD17,
				PL_MMC_CTRL_CMD24:
					begin
						b_main_state <= PL_MMC_CTRL_WAIT;
					end
				PL_MMC_CTRL_WAIT:
					begin
						if(command_done)begin
							b_main_state <= PL_MMC_CTRL_IDLE;
						end
					end
				default:
					begin
						b_main_state <= PL_MMC_CTRL_IDLE;
					end
			endcase
		end
	end


	reg [2:0] b_main_current_state;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_main_current_state <= PL_MMC_CTRL_IDLE;
		end
		else begin
			if(b_main_state == PL_MMC_CTRL_IDLE)begin
				b_main_current_state <= PL_MMC_CTRL_IDLE;
			end
			else if(b_main_state != PL_MMC_CTRL_WAIT)begin
				b_main_current_state <= b_main_state;
			end
		end
	end
	

	reg [31:0] b_main_addr;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_main_addr <= PL_MMC_CTRL_IDLE;
		end
		else begin
			if(spi_txrx_cmd17_start || spi_txrx_cmd24_start)begin
				b_main_addr <= iCMD_ADDR;
			end
		end
	end


	/***************************************************
	CMD Module
	***************************************************/
	wire cmd_init_mmc_req;
	wire cmd_init_mmc_cs;
	wire [7:0] cmd_init_mmc_data;

	wire cmd0_mmc_req;
	wire cmd0_mmc_cs;
	wire [7:0] cmd0_mmc_data;

	wire cmd1_mmc_req;
	wire cmd1_mmc_cs;
	wire [7:0] cmd1_mmc_data;
	
	wire cmd16_mmc_req;
	wire cmd16_mmc_cs;
	wire [7:0] cmd16_mmc_data;

	wire cmd17_mmc_req;
	wire cmd17_mmc_cs;
	wire [7:0] cmd17_mmc_data;

	wire cmd24_mmc_req;
	wire cmd24_mmc_cs;
	wire [7:0] cmd24_mmc_data;

	wire buffer_write_req;
	wire [6:0] buffer_write_addr;
	wire [31:0] buffer_write_data;

	wire [6:0] buffer_read_addr;



	mmc_cmd_control_layer_initial CMD_INIT(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//
		.iINIT_START(b_main_state == PL_MMC_CTRL_INIT),
		.oINIT_END(cmd_init_done),
		//
		.oMMC_REQ(cmd_init_mmc_req),
		.iMMC_BUSY(spi_request_busy),
		.oMMC_CS(cmd_init_mmc_cs),
		.oMMC_DATA(cmd_init_mmc_data)
	);


	mmc_cmd_control_layer_cmd0 CMD_CMD0(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(1'b0),
		//
		.iCMD_START(b_main_state == PL_MMC_CTRL_CMD0),
		.oCMD_END(cmd0_done),
		//Write
		.oMMC_REQ(cmd0_mmc_req),
		.iMMC_BUSY(spi_request_busy),
		.oMMC_CS(cmd0_mmc_cs),
		.oMMC_DATA(cmd0_mmc_data),
		//Read
		.iMMC_VALID(spi_read_valid),
		.iMMC_DATA(spi_read_data)
	);

	mmc_cmd_control_layer_cmd1 CMD_CMD1(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(1'b0),
		//
		.iCMD_START(b_main_state == PL_MMC_CTRL_CMD1),
		.oCMD_END(cmd1_done),
		//Write
		.oMMC_REQ(cmd1_mmc_req),
		.iMMC_BUSY(spi_request_busy),
		.oMMC_CS(cmd1_mmc_cs),
		.oMMC_DATA(cmd1_mmc_data),
		//Read
		.iMMC_VALID(spi_read_valid),
		.iMMC_DATA(spi_read_data)
	);


	mmc_cmd_control_layer_cmd16 CMD_CMD16(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(1'b0),
		//
		.iCMD_START(b_main_state == PL_MMC_CTRL_CMD16),
		.oCMD_END(cmd16_done),
		//Write
		.oMMC_REQ(cmd16_mmc_req),
		.iMMC_BUSY(spi_request_busy),
		.oMMC_CS(cmd16_mmc_cs),
		.oMMC_DATA(cmd16_mmc_data),
		//Read
		.iMMC_VALID(spi_read_valid),
		.iMMC_DATA(spi_read_data)
	);
	
	mmc_cmd_control_layer_cmd17 CMD_CMD17(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(1'b0),
		//
		.iCMD_START(b_main_state == PL_MMC_CTRL_CMD17),
		.iCMD_ADDR({b_main_addr, 9'h000}),	//512Bute Count
		.oCMD_END(cmd17_done),
		//Buffer
		.oBUFF_REQ(buffer_write_req),
		.oBUFF_ADDR(buffer_write_addr),
		.oBUFF_DATA(buffer_write_data),
		//Write
		.oMMC_REQ(cmd17_mmc_req),
		.iMMC_BUSY(spi_request_busy),
		.oMMC_CS(cmd17_mmc_cs),
		.oMMC_DATA(cmd17_mmc_data),
		//Read
		.iMMC_VALID(spi_read_valid),
		.iMMC_DATA(spi_read_data)
	);

	mmc_cmd_control_layer_cmd24 CMD_CMD24(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(1'b0),
		//
		.iCMD_START(b_main_state == PL_MMC_CTRL_CMD24),
		.iCMD_ADDR({b_main_addr, 9'h000}),	//512Bute Count
		.oCMD_END(cmd24_done),
		//Buffer
		.oBUFF_ADDR(buffer_read_addr),
		.iBUFF_DATA(iBUFF_RD_DATA),
		//Write
		.oMMC_REQ(cmd24_mmc_req),
		.iMMC_BUSY(spi_request_busy),
		.oMMC_CS(cmd24_mmc_cs),
		.oMMC_DATA(cmd24_mmc_data),
		//Read
		.iMMC_VALID(spi_read_valid),
		.iMMC_DATA(spi_read_data),
		.iMMC_INFO_MISO(spi_read_info_miso)
	);

	/***************************************************
	SPI Out Select
	***************************************************/
	reg spi_write_valid;
	reg spi_write_cs;
	reg [7:0] spi_write_data;

	always @* begin
		case(b_main_current_state)
			PL_MMC_CTRL_INIT:
				begin
					spi_write_valid = cmd_init_mmc_req;
					spi_write_cs = cmd_init_mmc_cs;
					spi_write_data = cmd_init_mmc_data;
				end
			PL_MMC_CTRL_CMD0:
				begin
					spi_write_valid = cmd0_mmc_req;
					spi_write_cs = cmd0_mmc_cs;
					spi_write_data = cmd0_mmc_data;
				end
			PL_MMC_CTRL_CMD1:
				begin
					spi_write_valid = cmd1_mmc_req;
					spi_write_cs = cmd1_mmc_cs;
					spi_write_data = cmd1_mmc_data;
				end
			PL_MMC_CTRL_CMD16:
				begin
					spi_write_valid = cmd16_mmc_req;
					spi_write_cs = cmd16_mmc_cs;
					spi_write_data = cmd16_mmc_data;
				end
			PL_MMC_CTRL_CMD17:
				begin
					spi_write_valid = cmd17_mmc_req;
					spi_write_cs = cmd17_mmc_cs;
					spi_write_data = cmd17_mmc_data;
				end
			PL_MMC_CTRL_CMD24:
				begin
					spi_write_valid = cmd24_mmc_req;
					spi_write_cs = cmd24_mmc_cs;
					spi_write_data = cmd24_mmc_data;
				end
			default:
				begin
					spi_write_valid = 1'b0;
					spi_write_cs = 1'b1;
					spi_write_data = 8'h0;
				end
		endcase

	end


	/***************************************************
	SPI Controlor
	***************************************************/
	mmc_spi_async_transfer_layer SPI_MASTER(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iMMC_CLOCK(iCLOCK_MMC),
		.iRESET_SYNC(1'b0),
		//Master - Req	
		.iMASTER_REQ(spi_write_valid && !spi_request_busy),
		.oMASTER_LOCK(spi_request_busy),
		.iMASTER_DATA(spi_write_data),
		//Master - Data Rec
		.oMASTER_VALID(spi_read_valid),
		.oMASTER_DATA(spi_read_data),
		.oMASTER_INFO_MISO(spi_read_info_miso),
		//SPI
		.oSPI_CLK(oMMC_CLK),
		.oSPI_MOSI(oMMC_MOSI),
		.iSPI_MISO(iMMC_MISO)
	);
	
	
	
	
	/***************************************************
	Assign
	***************************************************/
	//Memory
	assign oBUFF_RD_ADDR = buffer_read_addr;
	assign oBUFF_WR_REQ = buffer_write_req;
	assign oBUFF_WR_ADDR = buffer_write_addr;
	assign oBUFF_WR_DATA = buffer_write_data;
	//Command
	assign oCMD_BUSY = system_busy;
	assign oCMD_SUCCESS = command_done;
	assign oCMD_ERROR = 1'b0;
	assign oCMD_ERROR_CODE = 5'h00;
	
	assign oMMC_CE = spi_write_cs;
	

endmodule


`default_nettype wire

