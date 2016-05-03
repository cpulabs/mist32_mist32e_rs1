

`default_nettype none


module mmc_top_control_layer_512(
		//System
		input wire inRESET,
		input wire iCLOCK,
		input wire iCLOCK_MMC,
		//CMD
		input wire iCMD_REQ,
		output wire oCMD_BUSY,
		input wire [2:0] iCMD_COMMAND,	//0:LCD Initial | 1:Read Card CMD | 2:Write Card CMD | 3:Read Buffer | 4:Write Buffer
		input wire [31:0] iCMD_ADDR,		//For Buffer : Byte Address but only word allign, For Card Sector : Byte Address
		input wire [31:0] iCMD_DATA,
		//OUT
		output wire oOUT_VALID,
		output wire [31:0] oOUT_DATA,
		output wire oOUT_ERROR,
		output wire [5:0] oOUT_FLAGS,
		//IRQ
		input wire iIRQ_ENABLE,
		output wire oIRQ_REQ,
		input wire iIRQ_ACK,
		//Card Read End
		output wire oCARD_READ_END,
		//MMC
		input wire iMMC_CON,	//Connect
		output wire oMMC_CE,
		output wire oMMC_CLK,
		output wire oMMC_MOSI,
		input wire iMMC_MISO
	);

	//assign DEBUG0 = bn_idle;

	localparam MMC_CONTROLLER_INIT = 3'h0;
	localparam MMC_CONTROLLER_CMD0 = 3'h1;
	localparam MMC_CONTROLLER_CMD1 = 3'h2;
	localparam MMC_CONTROLLER_CMD16 = 3'h3;
	localparam MMC_CONTROLLER_CMD17 = 3'h4;
	localparam MMC_CONTROLLER_CMD24 = 3'h5;

	
	/************************************************************
	Condition
	************************************************************/
	wire this_buffer_read = iCMD_REQ && (iCMD_COMMAND == 3'h3);
	wire this_buffer_write = iCMD_REQ && (iCMD_COMMAND == 3'h4);
	
	wire mmc_command_cc_cmd_busy;
	wire this_lock = mmc_command_cc_cmd_busy;
	
	wire mmc_command_cc_cmd_success;
	wire mmc_command_cc_cmd_error;
	wire [4:0] mmc_command_cc_cmd_error_code;
	
	reg [3:0] b_state;
	
	
	wire [31:0] mem_port_rd_data;
	
	/************************************************************
	IRQ
	************************************************************/
	parameter L_PARAM_IRQ_STT_IDLE = 2'b0;
	parameter L_PARAM_IRQ_STT_IRQ_REQ = 2'h1;
	parameter L_PARAM_IRQ_STT_IRQ_FLAG = 2'h2;
	
	reg [1:0] b_irq_state;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_irq_state <= 2'h0;
		end
		else begin
			case(b_irq_state)
				L_PARAM_IRQ_STT_IDLE:
					begin
						if(mmc_command_cc_cmd_success && iIRQ_ENABLE && (b_state == MMC_CONTROLLER_CMD17 || b_state == MMC_CONTROLLER_CMD24))begin
							b_irq_state <= L_PARAM_IRQ_STT_IRQ_REQ;
						end
					end
				L_PARAM_IRQ_STT_IRQ_REQ:
					begin
						if(iIRQ_ACK)begin
							b_irq_state <= L_PARAM_IRQ_STT_IDLE;
						end
					end
			endcase
		end
	end
	
	assign oIRQ_REQ = (b_irq_state == L_PARAM_IRQ_STT_IRQ_REQ);
	
	
	/************************************************************
	Flag Register
	************************************************************/
	//0 : Mount Flag | 1=Card Mount
	//1 : Other Error | 1=Error
	//2 : Command Error | 1=Error
	//3 : Erace Error | 1=Error
	//4 : Address Error Flag | 1=Error
	//5 : Argument Error Flag | 1=Error
	reg [5:0] b_flag_register;
	reg b_flag_error;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_flag_register <= 6'h0;
			b_flag_error <= 1'b0;
		end
		else begin
			//Mount Flag
			b_flag_register[0] <= iMMC_CON;
			if(mmc_command_cc_cmd_success && mmc_command_cc_cmd_error)begin
				b_flag_register[5:1] <= mmc_command_cc_cmd_error_code;
				b_flag_error <= 1'b1;
			end
			else if(mmc_command_cc_cmd_success)begin
				b_flag_register[5:1] <= 5'h0;
				b_flag_error <= 1'b0;
			end
		end
	end
	
	
	/************************************************************
	State
	************************************************************/
	reg bn_idle;
	reg b_cmd_end;
	reg b_wait;
	reg [31:0] b_addr;
	reg [31:0] b_data;
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			bn_idle <= 1'b0;
			b_cmd_end <= 1'b0;
			b_state <= MMC_CONTROLLER_INIT;
			b_wait <= 1'b0;
			b_addr <= 32'h0;
			b_data <= 32'h0;
		end
		else if(b_wait)begin
			if(mmc_command_cc_cmd_success)begin
				b_wait <= 1'b0;
				if(!bn_idle)begin
					b_cmd_end <= 1'b1;
				end
			end
		end
		else if(!bn_idle)begin
			b_addr <= iCMD_ADDR;
			b_data <= iCMD_DATA;
			b_cmd_end <= 1'b0;
			if(iCMD_REQ)begin
				case(iCMD_COMMAND)
					0:	//Initial
						begin
							b_state <= MMC_CONTROLLER_INIT;
							bn_idle <= 1'b1;
						end
					1:	//Read Card
						begin
							b_state <= MMC_CONTROLLER_CMD17;
							bn_idle <= 1'b1;
						end
					2:	//Write Card
						begin
							b_state <= MMC_CONTROLLER_CMD24;
							bn_idle <= 1'b1;
						end
					3:	//Read Buffer
						begin
						end
					4:	//Write Buffer
						begin
						end
				endcase
			end
		end
		else begin
			case(b_state)
				MMC_CONTROLLER_INIT:
					begin
						b_wait <= 1'b1;
						b_state <= MMC_CONTROLLER_CMD0;
						bn_idle <= 1'b1;
					end
				MMC_CONTROLLER_CMD0:
					begin
						b_wait <= 1'b1;
						b_state <= MMC_CONTROLLER_CMD1;
						bn_idle <= 1'b1;
					end
				MMC_CONTROLLER_CMD1:
					begin
						b_wait <= 1'b1;
						b_state <= MMC_CONTROLLER_CMD16;
						bn_idle <= 1'b1;
					end
				
				MMC_CONTROLLER_CMD16:
					begin
						b_wait <= 1'b1;
						bn_idle <= 1'b0;
					end
				
				MMC_CONTROLLER_CMD17:
					begin
						b_wait <= 1'b1;
						bn_idle <= 1'b0;
					end
				MMC_CONTROLLER_CMD24:
					begin
						b_wait <= 1'b1;
						bn_idle <= 1'b0;
					end
			endcase
		end
	end
	
	

	
	/***************************************************
	MMC Comand Control Layer
	***************************************************/
	wire [6:0] mmc_command_cc_buffer_rd_addr;
	wire mmc_command_cc_buffer_wr_req;
	wire [6:0] mmc_command_cc_buffer_wr_addr;
	wire [31:0] mmc_command_cc_buffer_wr_data;
	
	wire mmc_command_cc_cmd_req = !b_wait && bn_idle;
	wire [3:0] mmc_command_cc_cmd_command = b_state;
	wire [31:0]mmc_command_cc_cmd_addr = b_addr;
	
	
	mmc_cmd_control_layer_512 MMC_COMMAND_CONTROLLER(
		//System
		.inRESET(inRESET),
		.iCLOCK(iCLOCK),
		.iCLOCK_MMC(iCLOCK_MMC),
		//Buffer
		.oBUFF_RD_ADDR(mmc_command_cc_buffer_rd_addr),
		.iBUFF_RD_DATA({mem_port_rd_data[7:0], mem_port_rd_data[15:8], mem_port_rd_data[23:16], mem_port_rd_data[31:24]}),		//For big endian
		.oBUFF_WR_REQ(mmc_command_cc_buffer_wr_req),
		.oBUFF_WR_ADDR(mmc_command_cc_buffer_wr_addr),
		.oBUFF_WR_DATA(mmc_command_cc_buffer_wr_data),
		//CMD
		.iCMD_REQ(mmc_command_cc_cmd_req),
		.iCMD_COMMAND(mmc_command_cc_cmd_command),				//0:Init | 1:CMD0 | 2:CMD1 | 3:CMD17 | 4:CMD24 
		.iCMD_ADDR(mmc_command_cc_cmd_addr),
		.oCMD_BUSY(mmc_command_cc_cmd_busy),
		.oCMD_SUCCESS(mmc_command_cc_cmd_success),
		.oCMD_ERROR(mmc_command_cc_cmd_error),
		.oCMD_ERROR_CODE(mmc_command_cc_cmd_error_code),
		//MMC
		.oMMC_CE(oMMC_CE),
		.oMMC_CLK(oMMC_CLK),
		.oMMC_MOSI(oMMC_MOSI),
		.iMMC_MISO(iMMC_MISO)
	);
	

	/***************************************************
	MMC Buffer 512Byte
	***************************************************/
	
	wire mem_select = !(this_buffer_read || this_buffer_write);	//0:HOST | 1:SPI
	
	reg mem_port_wr_req;
	reg [6:0] mem_port_wr_addr;
	reg [31:0] mem_port_wr_data;
	reg [6:0] mem_port_rd_addr;
	
	always @* begin
		if(!mem_select)begin	
			//HOST
			mem_port_wr_req = this_buffer_write;
			mem_port_wr_addr = iCMD_ADDR[8:2];//iCMD_ADDR[6:0]; 
			mem_port_wr_data = ({iCMD_DATA[7:0], iCMD_DATA[15:8], iCMD_DATA[23:16], iCMD_DATA[31:24]});		//For big endian;  //iCMD_DATA;
			mem_port_rd_addr = iCMD_ADDR[8:2];
		end
		else begin
			//SPI
			mem_port_wr_req = mmc_command_cc_buffer_wr_req;
			mem_port_wr_addr = mmc_command_cc_buffer_wr_addr; 
			mem_port_wr_data = mmc_command_cc_buffer_wr_data;//({mmc_command_cc_buffer_wr_data[7:0], mmc_command_cc_buffer_wr_data[15:8], mmc_command_cc_buffer_wr_data[23:16], mmc_command_cc_buffer_wr_data[31:24]});		//For big endian;
			mem_port_rd_addr = mmc_command_cc_buffer_rd_addr;
		end
	end
	
	
	mmc_buffer_512b MMC_BUFFER(
		.iCLOCK(iCLOCK),
		//Write
		.iWR_REQ(mem_port_wr_req),
		.iWR_MASK(4'h0),
		.iWR_ADDR(mem_port_wr_addr),
		.iWR_DATA(mem_port_wr_data),
		//Read
		.iRD_ADDR(mem_port_rd_addr),
		.oRD_DATA(mem_port_rd_data)
	);

	/***************************************************
	Assign
	***************************************************/
	reg b_out_buffer_valid;
	reg [31:0] b_out_buffer_data;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_out_buffer_valid <= 1'b0;
			b_out_buffer_data <= 32'h0;
		end
		else begin
			b_out_buffer_valid <= this_buffer_read || this_buffer_write || b_cmd_end;//this_buffer_read;
			b_out_buffer_data <= mem_port_rd_data;
		end
	end
	
	assign oCMD_BUSY = b_wait || bn_idle;
	
	assign oOUT_VALID = b_out_buffer_valid;
	assign oOUT_DATA = b_out_buffer_data;
	assign oOUT_ERROR = b_flag_error;
	assign oOUT_FLAGS = b_flag_register;
	
	assign oCARD_READ_END = mmc_command_cc_cmd_success && (b_state == MMC_CONTROLLER_CMD17);
	
endmodule

`default_nettype wire

