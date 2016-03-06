
`default_nettype none

module mist32_mist32e_rs0(
		/****************************************
		System
		****************************************/
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		/****************************************
		IBOOT
		****************************************/
		input wire iIBOOT_VALID,
		input wire iIBOOT_MEMIF_REQ_VALID,
		input wire iIBOOT_MEMIF_REQ_DQM0,
		input wire iIBOOT_MEMIF_REQ_DQM1,
		input wire iIBOOT_MEMIF_REQ_DQM2,
		input wire iIBOOT_MEMIF_REQ_DQM3,
		input wire iIBOOT_MEMIF_REQ_RW,
		input wire [24:0] iIBOOT_MEMIF_REQ_ADDR,
		input wire [31:0] iIBOOT_MEMIF_REQ_DATA,
		output wire oIBOOT_MEMIF_REQ_LOCK,

		/****************************************
		Memory BUS
		****************************************/
		//Req
		output wire oMEMORY_REQ,
		input wire iMEMORY_BUSY,
		output wire [3:0] oMEMORY_MASK,
		output wire oMEMORY_RW,						//1:Write | 0:Read
		output wire [31:0] oMEMORY_ADDR,
		//This -> Data RAM
		output wire [31:0] oMEMORY_DATA,
		//Data RAM -> This
		input wire iMEMORY_VALID,
		output wire oMEMORY_BUSY,
		input wire [63:0] iMEMORY_DATA,





		/****************************************
		IO Bus
		****************************************/
		//Request
		output wire oEXTIO_REQ,					//Input
		input wire iEXTIO_BUSY,
		output wire oEXTIO_RW,						//0=Read : 1=Write
		output wire [31:0] oEXTIO_ADDR,
		output wire [31:0] oEXTIO_DATA,
		//Return
		input wire iEXTIO_REQ,						//Output
		output wire oEXTIO_BUSY,
		input wire [31:0] iEXTIO_DATA,
		//Interrupt
		input wire iEXTIO_IRQ_REQ,
		input wire [5:0] iEXTIO_IRQ_NUM,
		output wire oEXTIO_IRQ_ACK,
		//Interrupt Controll
		output wire oEXTIO_IRQ_CONFIG_TABLE_REQ,
		output wire [5:0] oEXTIO_IRQ_CONFIG_TABLE_ENTRY,
		output wire oEXTIO_IRQ_CONFIG_TABLE_FLAG_MASK,
		output wire oEXTIO_IRQ_CONFIG_TABLE_FLAG_VALID,
		output wire [1:0] oEXTIO_IRQ_CONFIG_TABLE_FLAG_LEVEL
	);



	/******************************************************************************************************
	Processor
	******************************************************************************************************/
	wire processor_memory_req;
	wire [3:0] processor_memory_mask;
	wire processor_memory_rw;
	wire [31:0] processor_memory_addr;
	wire [31:0] processor_memory_data;
	wire processor_memory_busy;


	mist32e10fa MIST32E10FA(
		/****************************************
		System
		****************************************/
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		/****************************************
		Memory BUS
		****************************************/
		//Req
		.oMEMORY_REQ(processor_memory_req),
		.iMEMORY_LOCK(iIBOOT_VALID || iMEMORY_BUSY),
		.oMEMORY_ORDER(),				//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		.oMEMORY_MASK(processor_memory_mask),
		.oMEMORY_RW(processor_memory_rw),						//1:Write | 0:Read
		.oMEMORY_ADDR(processor_memory_addr),
		//This -> Data RAM
		.oMEMORY_DATA(processor_memory_data),
		//Data RAM -> This
		.iMEMORY_VALID(iMEMORY_VALID),
		.oMEMORY_BUSY(processor_memory_busy),
		.iMEMORY_DATA(iMEMORY_DATA),
		/****************************************
		IO BUS
		****************************************/
		//Request
		.oEXTIO_REQ(oEXTIO_REQ),					//Input
		.iEXTIO_BUSY(iEXTIO_BUSY),
		.oEXTIO_RW(oEXTIO_RW),						//0=Read : 1=Write
		.oEXTIO_ADDR(oEXTIO_ADDR),
		.oEXTIO_DATA(oEXTIO_DATA),
		//Return
		.iEXTIO_REQ(iEXTIO_REQ),						//Output
		.oEXTIO_BUSY(oEXTIO_BUSY),
		.iEXTIO_DATA(iEXTIO_DATA),
		//Interrupt
		.iEXTIO_IRQ_REQ(iEXTIO_IRQ_REQ),
		.iEXTIO_IRQ_NUM(iEXTIO_IRQ_NUM),
		.oEXTIO_IRQ_ACK(oEXTIO_IRQ_ACK),
		//Interrupt Controll
		.oIO_IRQ_CONFIG_TABLE_REQ(oEXTIO_IRQ_CONFIG_TABLE_REQ),
		.oIO_IRQ_CONFIG_TABLE_ENTRY(oEXTIO_IRQ_CONFIG_TABLE_ENTRY),
		.oIO_IRQ_CONFIG_TABLE_FLAG_MASK(oEXTIO_IRQ_CONFIG_TABLE_FLAG_MASK),
		.oIO_IRQ_CONFIG_TABLE_FLAG_VALID(oEXTIO_IRQ_CONFIG_TABLE_FLAG_VALID),
		.oIO_IRQ_CONFIG_TABLE_FLAG_LEVEL(oEXTIO_IRQ_CONFIG_TABLE_FLAG_LEVEL),
		.oDEBUG_PC()
	);


	/******************************************************************************************************
	Memory
	******************************************************************************************************/
	assign oMEMORY_REQ = (iIBOOT_VALID)? iIBOOT_MEMIF_REQ_VALID : processor_memory_req;	
	assign oMEMORY_MASK = (iIBOOT_VALID)? {iIBOOT_MEMIF_REQ_DQM3, iIBOOT_MEMIF_REQ_DQM2, iIBOOT_MEMIF_REQ_DQM1, iIBOOT_MEMIF_REQ_DQM0} : ~processor_memory_mask;
	assign oMEMORY_RW = (iIBOOT_VALID)? 1'b1 : processor_memory_rw; 					//1:Write | 0:Read
	assign oMEMORY_ADDR = (iIBOOT_VALID)? {6'h0, iIBOOT_MEMIF_REQ_ADDR} : {2'h0, processor_memory_addr[31:2]};
	assign oMEMORY_DATA = (iIBOOT_VALID)? iIBOOT_MEMIF_REQ_DATA : processor_memory_data;
	assign oMEMORY_BUSY = processor_memory_busy;

	assign oIBOOT_MEMIF_REQ_LOCK = iMEMORY_BUSY;
		

endmodule


`default_nettype wire 

