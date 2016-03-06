/*******************************************************
MIST32 Default Device : MMC Controller Device(~2GByte)
- Master Clock : 50MHz
- Block Size : 512Byte
		
Memory Map(Word)
	0~255	:	GCI-Node(Device) Special Memory	
	256		:	Card Initial CMD | Data:Ignore
	257		:	Card Read 512Byte CMD | Data:Card Sector Addr
	258		:	Card Write 512Byte CMD | Data:Card Sector Addr
	259
	~		:	Reserved
	270
	271		:	Flag Register | Data:Ignore(Read Only, Write Ignore)
	272
	~		:	Buffer Register(512Byte)
	400
	
*******************************************************/
`default_nettype none


module mmc_top(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		input wire iCLOCK_MMC,
		//CPU Interface
		input wire iREQ_VALID,
		output wire oREQ_BUSY,
		input wire iREQ_RW,
		input wire [31:0] iREQ_ADDR,
		input wire [31:0] iREQ_DATA,
		output wire oREQ_VALID,
		output wire [31:0] oREQ_DATA,
		//IRQ
		output wire oIRQ_VALID,
		input wire iIRQ_ACK,
		//MMC - SPI
		input wire iMMC_CON,
		output wire oMMC_CE,
		output wire oMMC_CLK,
		output wire oMMC_MOSI,
		input wire iMMC_MISO
	);
	
	
	
	/************************************************************
	Buffer layer -> MMC protocol layer
	************************************************************/
	wire card2gci_busy;
	reg gci2card_req;
	reg [2:0] gci2card_command;
	reg [31:0] gci2card_addr;
	
	wire card2gci_out_valid;
	wire [31:0] card2gci_out_data;
	wire [5:0] card2gci_out_flags;
	wire card2gci_cardirq;
	
	localparam L_PARAM_MMC_CMD_INITIAL_CARD = 3'h0;
	localparam L_PARAM_MMC_CMD_READ_CARD = 3'h1;
	localparam L_PARAM_MMC_CMD_WRITE_CARD = 3'h2;
	localparam L_PARAM_MMC_CMD_READ_BUFF = 3'h3;
	localparam L_PARAM_MMC_CMD_WRITE_BUFF = 3'h4;
	
	always @* begin
		case(iREQ_ADDR[9:0])
			10'h0 : 
				begin
					gci2card_req = iREQ_VALID;
					gci2card_command = L_PARAM_MMC_CMD_INITIAL_CARD;
					gci2card_addr = iREQ_ADDR;
				end
			10'h4 : 
				begin
					gci2card_req = iREQ_VALID;
					gci2card_command = L_PARAM_MMC_CMD_READ_CARD;
					gci2card_addr = iREQ_DATA;//iREQ_ADDR;
				end
			10'h8 : 
				begin
					gci2card_req = iREQ_VALID;
					gci2card_command = L_PARAM_MMC_CMD_WRITE_CARD;
					gci2card_addr = iREQ_DATA;//iREQ_ADDR;
				end
			default : 
				begin
					if(iREQ_ADDR[9:0] >= 10'h40 && 10'h240 >= iREQ_ADDR[9:0] && !iREQ_RW)begin
						gci2card_req = iREQ_VALID;
						gci2card_command = L_PARAM_MMC_CMD_READ_BUFF;
						gci2card_addr = iREQ_ADDR - 32'h40;
					end
					else if(iREQ_ADDR[9:0] >= 10'h40 && 10'h240 >= iREQ_ADDR[9:0] && iREQ_RW)begin
						gci2card_req = iREQ_VALID;
						gci2card_command = L_PARAM_MMC_CMD_WRITE_BUFF;
						gci2card_addr = iREQ_ADDR - 32'h40;
					end
					else begin
						gci2card_req = 1'b0;
						gci2card_command = L_PARAM_MMC_CMD_INITIAL_CARD;
						gci2card_addr = iREQ_ADDR;
					end
				end
		endcase	
	end
	
	reg b_sdcfg_ire;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_sdcfg_ire <= 1'b0;
		end
		else if(iRESET_SYNC)begin
			b_sdcfg_ire <= 1'b0;
		end
		else begin
			if(iREQ_VALID && iREQ_RW && !card2gci_busy && iREQ_ADDR[9:0] == 10'hc)begin
				b_sdcfg_ire <= iREQ_DATA[0];
			end
		end
	end
	
	
	wire card_interrupt;
	mmc_top_control_layer_512 MMC_DEVICE(
		.inRESET(inRESET),
		.iCLOCK(iCLOCK),
		.iCLOCK_MMC(iCLOCK_MMC),
		//Command
		.iCMD_REQ(gci2card_req && !card2gci_busy),
		.oCMD_BUSY(card2gci_busy),
		.iCMD_COMMAND(gci2card_command),
		.iCMD_ADDR(gci2card_addr),
		.iCMD_DATA(iREQ_DATA),
		//Out
		.oOUT_VALID(card2gci_out_valid),
		.oOUT_DATA(card2gci_out_data),
		.oOUT_ERROR(),
		.oOUT_FLAGS(card2gci_out_flags),
		//Interrupt
		.iIRQ_ENABLE(b_sdcfg_ire),
		.oIRQ_REQ(card_interrupt),
		.iIRQ_ACK(iIRQ_ACK),
		//Card Read Info
		.oCARD_READ_END(card2gci_cardirq),
		//MMC
		.iMMC_CON(iMMC_CON),
		.oMMC_CE(oMMC_CE),
		.oMMC_CLK(oMMC_CLK),
		.oMMC_MOSI(oMMC_MOSI),
		.iMMC_MISO(iMMC_MISO)
	);
	
	//Ack Latch
	reg b_ack_wait;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_ack_wait <= 1'b0;
		end
		else begin
			if(!b_ack_wait)begin
				if(iREQ_VALID && iREQ_ADDR[9:0] >= 10'h00 && 10'h240 >= iREQ_ADDR[9:0]/* && !iDEV_RW*/)begin	//Buffer Read Condition
					b_ack_wait <= 1'b1;
				end
			end
			else begin
				if(card2gci_out_valid)begin
					b_ack_wait <= 1'b0;
				end
			end
		end
	end

	reg b_ack_flag;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_ack_flag <= 1'b0;
		end
		else begin
			if(!card2gci_busy)begin
				b_ack_flag <= (iREQ_ADDR[9:0] == 10'h3c) && iREQ_VALID && !iREQ_RW;
			end
		end
	end
	
	reg b_ack_cfg;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_ack_cfg <= 1'b0;
		end
		else begin
			if(!card2gci_busy)begin
				b_ack_cfg <= (iREQ_ADDR[9:0] == 10'hc) && iREQ_VALID && !iREQ_RW;
			end
		end
	end
	
	
	/*
	//Irq latch
	reg b_irq_latch;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_irq_latch <= 1'b0;
		end
		else begin
			if(!b_irq_latch)begin
				b_irq_latch <= card2gci_cardirq;
			end
			else begin
				if(iIRQ_ACK)begin
					b_irq_latch <= 1'b0;
				end
			end
		end
	end
	*/
	
	assign oREQ_BUSY = card2gci_busy;
	
	assign oREQ_VALID = !card2gci_busy && ((card2gci_out_valid && b_ack_wait) || b_ack_flag || b_ack_cfg);
	assign oREQ_DATA = (!b_ack_flag)? card2gci_out_data : 
		(b_ack_cfg)? {31'h0, b_sdcfg_ire} : {26'h0, card2gci_out_flags};
	
	assign oIRQ_VALID = card_interrupt;//b_irq_latch;
	
endmodule

`default_nettype wire

