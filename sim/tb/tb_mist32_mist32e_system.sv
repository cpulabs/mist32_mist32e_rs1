

`default_nettype none


module tb_mist32_mist32e_system;
	parameter PL_MAIN_CYCLE = 20;
	parameter PL_DISPLAY_CYCLE = 40;
	parameter PL_MMC_CYCLE = 40;
	parameter PL_RESET_TIME = 5;
	
	//`include "task_disp_loadstore.v"


	/****************************************
	System
	****************************************/
	reg iCLOCK;
	reg inRESET;
	reg iRESET_SYNC;
	//DISP Clock
	reg iCLOCK_DISP;
	//MMC Clock
	reg iCLOCK_MMC;
	/****************************************
	Memory BUS
	****************************************/
	//Req
	wire oMEMORY_REQ;
	wire iMEMORY_BUSY;
	wire [3:0] oMEMORY_MASK;
	wire oMEMORY_RW;						//1:Write | 0:Read
	wire [31:0] oMEMORY_ADDR;
	//This -> Data RAM
	wire [31:0] oMEMORY_DATA;
	//Data RAM -> This
	wire iMEMORY_VALID;
	wire oMEMORY_BUSY;
	wire [63:0] iMEMORY_DATA;
	
	

	wire [31:0] memory_addr_byte_order = {oMEMORY_ADDR[29:0], 2'h0};

	wire pcocessor_interconnect_io_req;
	wire interconnect_pcocessor_io_busy;
	wire pcocessor_interconnect_io_rw;
	wire [31:0] pcocessor_interconnect_io_addr;
	wire [31:0] pcocessor_interconnect_io_data;
	wire interconnect_pcocessor_io_req;
	wire pcocessor_interconnect_io_busy;
	wire [31:0] interconnect_pcocessor_io_data;
	wire interconnect_pcocessor_io_irq_req;
	wire [5:0] interconnect_pcocessor_io_irq_num;
	wire pcocessor_interconnect_io_irq_ack;

	wire processor_interconnect_irq_cfgt_req;
	wire [5:0] processor_interconnect_irq_cfgt_entry;
	wire processor_interconnect_irq_cfgt_mask;
	wire processor_interconnect_irq_cfgt_valid;
	wire [1:0] processor_interconnect_irq_cfgt_level;


	mist32_mist32e_rs0 TARGET(
		/****************************************
		System
		****************************************/
		
		
		/****************************************
		IBOOT
		****************************************/
		.iIBOOT_VALID(1'b0),
		.iIBOOT_MEMIF_REQ_VALID(1'b0),
		.iIBOOT_MEMIF_REQ_DQM0(1'b0),
		.iIBOOT_MEMIF_REQ_DQM1(1'b0),
		.iIBOOT_MEMIF_REQ_DQM2(1'b0),
		.iIBOOT_MEMIF_REQ_DQM3(1'b0),
		.iIBOOT_MEMIF_REQ_RW(1'b1),
		.iIBOOT_MEMIF_REQ_ADDR(25'h0),
		.iIBOOT_MEMIF_REQ_DATA(32'h0),
		.oIBOOT_MEMIF_REQ_LOCK(),
		/****************************************
		Memory BUS
		****************************************/

		
		/****************************************
		EXTIO BUS
		****************************************/
		//Request
		.oEXTIO_REQ(pcocessor_interconnect_io_req),					//Input
		.iEXTIO_BUSY(interconnect_pcocessor_io_busy),
		.oEXTIO_RW(pcocessor_interconnect_io_rw),						//0=Read : 1=Write
		.oEXTIO_ADDR(pcocessor_interconnect_io_addr),
		.oEXTIO_DATA(pcocessor_interconnect_io_data),
		//Return
		.iEXTIO_REQ(interconnect_pcocessor_io_req),						//Output
		.oEXTIO_BUSY(pcocessor_interconnect_io_busy),
		.iEXTIO_DATA(interconnect_pcocessor_io_data),
		//Interrupt
		.iEXTIO_IRQ_REQ(interconnect_pcocessor_io_irq_req),
		.iEXTIO_IRQ_NUM(interconnect_pcocessor_io_irq_num),
		.oEXTIO_IRQ_ACK(pcocessor_interconnect_io_irq_ack),
		//Interrupt Controll
		.oEXTIO_IRQ_CONFIG_TABLE_REQ(processor_interconnect_irq_cfgt_req),
		.oEXTIO_IRQ_CONFIG_TABLE_ENTRY(processor_interconnect_irq_cfgt_entry),
		.oEXTIO_IRQ_CONFIG_TABLE_FLAG_MASK(processor_interconnect_irq_cfgt_mask),
		.oEXTIO_IRQ_CONFIG_TABLE_FLAG_VALID(processor_interconnect_irq_cfgt_valid),
		.oEXTIO_IRQ_CONFIG_TABLE_FLAG_LEVEL(processor_interconnect_irq_cfgt_level),

		.*
	);
	
	/*******************************************************************************************
	Device Interrconnect
	*******************************************************************************************/
	/*************************************
	Dev0 : Keyboard
	Dev1 : UART
	Dev2 : none
	Dev3 : VGA
	*************************************/
	wire interconnect_dev0_req;
	wire dev0_interconnect_busy;
	wire interconnect_dev0_rw;
	wire [31:0] interconnect_dev0_addr;
	wire [31:0] interconnect_dev0_data;
	wire dev0_interconnect_req;
	wire interconnect_dev0_busy;
	wire [31:0] dev0_interconnect_data;
	wire dev0_interconnect_irq;
	wire interconnect_dev0_ack;

	wire interconnect_dev1_req;
	wire dev1_interconnect_busy;
	wire interconnect_dev1_rw;
	wire [31:0] interconnect_dev1_addr;
	wire [31:0] interconnect_dev1_data;
	wire dev1_interconnect_req;
	wire [31:0] dev1_interconnect_data;
	wire dev1_interconnect_irq;
	wire interconnect_dev1_ack;

	wire interconnect_dev2_req;
	wire dev2_interconnect_busy;
	wire interconnect_dev2_rw;
	wire [31:0] interconnect_dev2_addr;
	wire [31:0] interconnect_dev2_data;
	wire dev2_interconnect_req;
	wire interconnect_dev2_busy;
	wire [31:0] dev2_interconnect_data;
	wire dev2_interconnect_irq;
	wire interconnect_dev2_ack;

	wire interconnect_dev3_req;
	wire dev3_interconnect_busy;
	wire interconnect_dev3_rw;
	wire [31:0] interconnect_dev3_addr;
	wire [31:0] interconnect_dev3_data;
	wire dev3_interconnect_req;
	wire [31:0] dev3_interconnect_data;
	wire dev3_interconnect_irq;
	wire interconnect_dev3_ack;

	dev_interconnect #(
		/*
		//Device Address
		.PL_DEV0_INDEX(32'h0),		//Byte
		.PL_DEV0_SIZE(32'h8),		//Byte
		.PL_DEV1_INDEX(32'h100),	
		.PL_DEV1_SIZE(32'hf),
		.PL_DEV2_INDEX(32'h200),	
		.PL_DEV2_SIZE(32'h100),
		.PL_DEV3_INDEX(32'h300),	
		.PL_DEV3_SIZE(32'h12c400),
		//Device IRQ
		.PL_DEV0_IRQ_PRIORITY(4'hf),
		.PL_DEV1_IRQ_PRIORITY(4'h0),
		.PL_DEV2_IRQ_PRIORITY(4'h0),
		.PL_DEV3_IRQ_PRIORITY(4'h9)
		*/
		//Device Address
		.PL_DEV0_INDEX(32'h0),		//Byte
		.PL_DEV0_SIZE(32'h8),		//Byte
		.PL_DEV1_INDEX(32'h100),	
		.PL_DEV1_SIZE(32'hf),
		.PL_DEV2_INDEX(32'h300),	
		.PL_DEV2_SIZE(32'h12c400),
		.PL_DEV3_INDEX(32'h12C800),	
		.PL_DEV3_SIZE(32'h240),
		.PL_DEV4_INDEX(32'h200000),	
		.PL_DEV4_SIZE(32'h0),
		.PL_DEV5_INDEX(32'h200000),	
		.PL_DEV5_SIZE(32'h0),
		.PL_DEV6_INDEX(32'h200000),	
		.PL_DEV6_SIZE(32'h0),
		.PL_DEV7_INDEX(32'h200000),	
		.PL_DEV7_SIZE(32'h0),
		//Device IRQ
		.PL_DEV0_IRQ_PRIORITY(4'hf),
		.PL_DEV1_IRQ_PRIORITY(4'h0),
		.PL_DEV2_IRQ_PRIORITY(4'h0),
		.PL_DEV3_IRQ_PRIORITY(4'h9),
		.PL_DEV4_IRQ_PRIORITY(4'h0),
		.PL_DEV5_IRQ_PRIORITY(4'h0),
		.PL_DEV6_IRQ_PRIORITY(4'h0),
		.PL_DEV7_IRQ_PRIORITY(4'h0)
	)DEV_INTERCONNECT(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		/*********************************************
		Configlation Table
		*********************************************/
		.iIRQ_CTRL_REQ(processor_interconnect_irq_cfgt_req),
		.iIRQ_CTRL_ENTRY(processor_interconnect_irq_cfgt_entry),
		.iIRQ_CTRL_INFO_MASK(processor_interconnect_irq_cfgt_mask),
		.iIRQ_CTRL_INFO_VALID(processor_interconnect_irq_cfgt_valid),
		.iIRQ_CTRL_INFO_MODE(processor_interconnect_irq_cfgt_level),
		/*********************************************
		From Core
		*********************************************/
		.iCORE_REQ(pcocessor_interconnect_io_req),		
		.oCORE_BUSY(interconnect_pcocessor_io_busy),
		.iCORE_RW(pcocessor_interconnect_io_rw),
		.iCORE_ADDR(pcocessor_interconnect_io_addr),
		.iCORE_DATA(pcocessor_interconnect_io_data),
		//BUS(DATA)-Output
		.oCORE_REQ(interconnect_pcocessor_io_req),		
		.iCORE_BUSY(pcocessor_interconnect_io_busy),
		.oCORE_DATA(interconnect_pcocessor_io_data),	
		//IRQ Out
		.oIRQ_VALID(interconnect_pcocessor_io_irq_req),
		.oIRQ_NUM(interconnect_pcocessor_io_irq_num),
		.iIRQ_ACK(pcocessor_interconnect_io_irq_ack),
		/*********************************************
		To Device-0
		*********************************************/
		//BUS(DATA)-Input
		.oDEV0_REQ(interconnect_dev0_req),		
		.iDEV0_BUSY(dev0_interconnect_busy),
		.oDEV0_RW(interconnect_dev0_rw),
		.oDEV0_ADDR(interconnect_dev0_addr),
		.oDEV0_DATA(interconnect_dev0_data),
		//BUS(DATA)-Output
		.iDEV0_REQ(dev0_interconnect_req),		
		.oDEV0_BUSY(interconnect_dev0_busy),
		.iDEV0_DATA(dev0_interconnect_data),
		//IRQ
		.iDEV0_IRQ(dev0_interconnect_irq),	
		.oDEV0_ACK(interconnect_dev0_ack),	
		/*********************************************
		To Device-1
		*********************************************/
		//BUS(DATA)-Input
		.oDEV1_REQ(interconnect_dev1_req),		
		.iDEV1_BUSY(dev1_interconnect_busy),
		.oDEV1_RW(interconnect_dev1_rw),
		.oDEV1_ADDR(interconnect_dev1_addr),
		.oDEV1_DATA(interconnect_dev1_data),
		//BUS(DATA)-Output
		.iDEV1_REQ(dev1_interconnect_req),		
		.oDEV1_BUSY(),
		.iDEV1_DATA(dev1_interconnect_data),
		//IRQ
		.iDEV1_IRQ(dev1_interconnect_irq),	
		.oDEV1_ACK(interconnect_dev1_ack),	
		/*********************************************
		To Device-2
		*********************************************/
		//BUS(DATA)-Input
		.oDEV2_REQ(interconnect_dev2_req),		
		.iDEV2_BUSY(dev2_interconnect_busy),
		.oDEV2_RW(interconnect_dev2_rw),
		.oDEV2_ADDR(interconnect_dev2_addr),
		.oDEV2_DATA(interconnect_dev2_data),
		//BUS(DATA)-Output
		.iDEV2_REQ(dev2_interconnect_req),		
		.oDEV2_BUSY(interconnect_dev2_busy),
		.iDEV2_DATA(dev2_interconnect_data),
		//IRQ
		.iDEV2_IRQ(dev2_interconnect_irq),	
		.oDEV2_ACK(interconnect_dev2_ack),
		/*********************************************
		To Device-3
		*********************************************/
		//BUS(DATA)-Input
		.oDEV3_REQ(interconnect_dev3_req),		
		.iDEV3_BUSY(dev3_interconnect_busy),
		.oDEV3_RW(interconnect_dev3_rw),
		.oDEV3_ADDR(interconnect_dev3_addr),
		.oDEV3_DATA(interconnect_dev3_data),
		//BUS(DATA)-Output
		.iDEV3_REQ(dev3_interconnect_req),		
		.oDEV3_BUSY(),
		.iDEV3_DATA(dev3_interconnect_data),
		//IRQ
		.iDEV3_IRQ(dev3_interconnect_irq),	
		.oDEV3_ACK(interconnect_dev3_ack),
		/*********************************************
		To Device-4
		*********************************************/
		//BUS(DATA)-Input
		.oDEV4_REQ(),		
		.iDEV4_BUSY(1'b0),
		.oDEV4_RW(),
		.oDEV4_ADDR(),
		.oDEV4_DATA(),
		//BUS(DATA)-Output
		.iDEV4_REQ(1'b0),		
		.oDEV4_BUSY(),
		.iDEV4_DATA(32'h0),
		//IRQ
		.iDEV4_IRQ(1'b0),	
		.oDEV4_ACK(),
		/*********************************************
		To Device-5
		*********************************************/
		//BUS(DATA)-Input
		.oDEV5_REQ(),		
		.iDEV5_BUSY(1'b0),
		.oDEV5_RW(),
		.oDEV5_ADDR(),
		.oDEV5_DATA(),
		//BUS(DATA)-Output
		.iDEV5_REQ(1'b0),		
		.oDEV5_BUSY(),
		.iDEV5_DATA(32'h0),
		//IRQ
		.iDEV5_IRQ(1'b0),	
		.oDEV5_ACK(),
		/*********************************************
		To Device-6
		*********************************************/
		//BUS(DATA)-Input
		.oDEV6_REQ(),		
		.iDEV6_BUSY(1'b0),
		.oDEV6_RW(),
		.oDEV6_ADDR(),
		.oDEV6_DATA(),
		//BUS(DATA)-Output
		.iDEV6_REQ(1'b0),		
		.oDEV6_BUSY(),
		.iDEV6_DATA(32'h0),
		//IRQ
		.iDEV6_IRQ(1'b0),	
		.oDEV6_ACK(),
		/*********************************************
		To Device-7
		*********************************************/
		//BUS(DATA)-Input
		.oDEV7_REQ(),		
		.iDEV7_BUSY(1'b0),
		.oDEV7_RW(),
		.oDEV7_ADDR(),
		.oDEV7_DATA(),
		//BUS(DATA)-Output
		.iDEV7_REQ(1'b0),		
		.oDEV7_BUSY(),
		.iDEV7_DATA(32'h0),
		//IRQ
		.iDEV7_IRQ(1'b0),	
		.oDEV7_ACK()
	);


	/*******************************************************************************************
	Device Keyboard
	*******************************************************************************************/
	keyboard DEVICE_KEYBOARD(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//BUS(DATA)-Input
		.iDEV_REQ(interconnect_dev0_req),
		.oDEV_BUSY(dev0_interconnect_busy),
		.iDEV_RW(interconnect_dev0_rw),
		.iDEV_ADDR(interconnect_dev0_addr),
		.iDEV_DATA(interconnect_dev0_data),
		//BUS(DATA)-Output
		.oDEV_REQ(dev0_interconnect_req),
		.iDEV_BUSY(interconnect_dev0_busy),
		.oDEV_DATA(dev0_interconnect_data),
		//IRQ
		.oDEV_IRQ_REQ(dev0_interconnect_irq),
		.iDEV_IRQ_BUSY(1'b0),
		.iDEV_IRQ_ACK(interconnect_dev0_ack),
		//PS2
		.iPS2_CLOCK(1'b1),
		.iPS2_DATA(1'b1)
	);


	/*******************************************************************************************
	Device - SCI
	*******************************************************************************************/
	wire uart_dev_txd;
	sci_top DEVICE_SCI(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//BUS(DATA)-Input
		.iREQ_VALID(interconnect_dev1_req),
		.oREQ_BUSY(dev1_interconnect_busy),
		.iREQ_RW(interconnect_dev1_rw),
		.iREQ_ADDR(interconnect_dev1_addr),
		.iREQ_DATA(interconnect_dev1_data),
		//BUS(DATA)-Output
		.oREQ_VALID(dev1_interconnect_req),
		.oREQ_DATA(dev1_interconnect_data),
		//IRQ
		.oIRQ_VALID(dev1_interconnect_irq),
		.oIRQ_NUM(),
		.iIRQ_ACK(interconnect_dev1_ack),
		//PS2
		.oUART_TXD(uart_dev_txd),
		.iUART_RXD(1'b1)
	);


	/*******************************************************************************************
	Device - VGA
	*******************************************************************************************/
	//`ifdef SYNTH_BOARD
	vga_display DEVICE_DISPLAY(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//BUS(DATA)-Input
		.iDEV_REQ(interconnect_dev2_req),		
		.oDEV_BUSY(dev2_interconnect_busy),
		.iDEV_RW(interconnect_dev2_rw),
		.iDEV_ADDR(interconnect_dev2_addr),
		.iDEV_DATA(interconnect_dev2_data),
		//BUS(DATA)-Output
		.oDEV_REQ(dev2_interconnect_req),		
		.iDEV_BUSY(interconnect_dev2_busy),
		.oDEV_DATA(dev2_interconnect_data),
		//IRQ
		.oDEV_IRQ_REQ(dev2_interconnect_irq),		
		.iDEV_IRQ_BUSY(1'b0), 
		.iDEV_IRQ_ACK(interconnect_dev2_ack),
		//Display Clock
		.iVGA_CLOCK(iCLOCK_DISP),
		//SRAM
		.onSRAM_CE(),
		.onSRAM_WE(),
		.onSRAM_OE(),
		.onSRAM_UB(),
		.onSRAM_LB(),
		.oSRAM_ADDR(),
		.ioSRAM_DATA(),
		//Display
		.oDISP_HSYNC(),
		.oDISP_VSYNC(),
		//ADV7123 Output
		.oADV_CLOCK(),
		.onADV_BLANK(),
		.onADV_SYNC(),
		.oADV_R(),
		.oADV_G(),
		.oADV_B()
	);	
	

	
	/*******************************************************************************************
	Device - MMC 512 Card
	*******************************************************************************************/
	mmc_top DEVICE_MMC(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		.iCLOCK_MMC(iCLOCK_MMC),
		//BUS(DATA)-Input
		.iREQ_VALID(interconnect_dev3_req),		
		.oREQ_BUSY(dev3_interconnect_busy),
		.iREQ_RW(interconnect_dev3_rw),
		.iREQ_ADDR(interconnect_dev3_addr),
		.iREQ_DATA(interconnect_dev3_data),
		//BUS(DATA)-Output
		.oREQ_VALID(dev3_interconnect_req),		
		.oREQ_DATA(dev3_interconnect_data),
		//IRQ
		.oIRQ_VALID(dev3_interconnect_irq),		
		.iIRQ_ACK(interconnect_dev3_ack),
		//MMC - SPI
		.iMMC_CON(1'b1),
		.oMMC_CE(),
		.oMMC_CLK(),
		.oMMC_MOSI(),
		.iMMC_MISO(1'b1)
	);
	


	sim_memory_model #(1, "bin/gcc_dry2reg.hex") MEMORY_MODEL(
	//sim_memory_model_64bit #(3, "tb_inst_test.hex") MEMORY_MODEL(		//no load instruction file
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Req
		.iMEMORY_REQ(oMEMORY_REQ),
		.oMEMORY_LOCK(iMEMORY_BUSY),
		.iMEMORY_ORDER(2'h0),				//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		.iMEMORY_MASK(~oMEMORY_MASK),
		.iMEMORY_RW(oMEMORY_RW),						//1:Write | 0:Read
		.iMEMORY_ADDR(memory_addr_byte_order),
		//This -> Data RAM
		.iMEMORY_DATA(oMEMORY_DATA),
		//Data RAM -> This
		.oMEMORY_VALID(iMEMORY_VALID),
		.iMEMORY_LOCK(oMEMORY_BUSY),
		.oMEMORY_DATA(iMEMORY_DATA)
	);


	//Main Clock
	always#(PL_MAIN_CYCLE/2)begin
		iCLOCK = !iCLOCK;
	end

	//Display Clock
	always#(PL_DISPLAY_CYCLE/2)begin
		iCLOCK_DISP = !iCLOCK_DISP;
	end

	//Display Clock
	always#(PL_MMC_CYCLE/2)begin
		iCLOCK_MMC = !iCLOCK_MMC;
	end

	//Set Default Clock - Main Clock
	default clocking clk@(posedge iCLOCK);
	endclocking


	initial begin
		$display("Check Start");
		//Initial
		iCLOCK = 1'b0;
		inRESET = 1'b0;
		iRESET_SYNC = 1'b0;
		iCLOCK_DISP = 1'b0;
		iCLOCK_MMC = 1'b0;
		
		//Initial Load Disable
		//force TARGET.iboot_memory_valid = 1'b0;

		//Reset 
		#(PL_RESET_TIME);
		inRESET = 1'b1;
		
		


		#1500000000 begin
			$finish;
		end
	end

	/******************************************************
	UART Display
	******************************************************/
	sim_uart_receiver_model #(115200, 1, 0) UART(
		.iUART_RXD(uart_dev_txd)
	);
	
	

	/******************************************************
	Assertion
	******************************************************/
	always@(posedge iCLOCK)begin
		if(inRESET)begin
			//task_disp_loadstore();
			//task_disp_branch();
		end
	end
	

	task task_disp_loadstore;
		begin
			if(TARGET.MIST32E10FA.CORE.CORE_PIPELINE.EXECUTE.iDATAIO_REQ && !TARGET.MIST32E10FA.CORE.CORE_PIPELINE.EXECUTE.oDATAIO_RW)begin
				$display("[INFO]Time : %d, Core(EX3) Load/Store[L], %x, %x, %x, %x", $time, TARGET.MIST32E10FA.CORE.CORE_PIPELINE.EXECUTE.b_pc-32'h4, TARGET.MIST32E10FA.CORE.CORE_PIPELINE.EXECUTE.b_r_spr, TARGET.MIST32E10FA.CORE.CORE_PIPELINE.EXECUTE.oDATAIO_ADDR, TARGET.MIST32E10FA.CORE.CORE_PIPELINE.EXECUTE.load_data);
			end
			if(TARGET.MIST32E10FA.CORE.CORE_PIPELINE.EXECUTE.oDATAIO_REQ && TARGET.MIST32E10FA.CORE.CORE_PIPELINE.EXECUTE.oDATAIO_RW)begin
				$display("[INFO]Time : %d, Core(EX3) Load/Store[S], %x, %x, %x, %x", $time, TARGET.MIST32E10FA.CORE.CORE_PIPELINE.EXECUTE.b_pc-32'h4, TARGET.MIST32E10FA.CORE.CORE_PIPELINE.EXECUTE.b_r_spr, TARGET.MIST32E10FA.CORE.CORE_PIPELINE.EXECUTE.oDATAIO_ADDR, TARGET.MIST32E10FA.CORE.CORE_PIPELINE.EXECUTE.for_assertion_store_real_data);
			end
		end
	endtask
	
	task task_disp_branch;
		begin
			if(TARGET.MIST32E10FA.CORE.CORE_PIPELINE.EXECUTE.oJUMP_VALID)begin
				$display("[INFO]Time : %d, Core(EX) Branch : %x(PCR) -> %x(PCR)", $time, TARGET.MIST32E10FA.CORE.CORE_PIPELINE.EXECUTE.b_pc, TARGET.MIST32E10FA.CORE.CORE_PIPELINE.EXECUTE.oBRANCH_ADDR);
			end
		end
	endtask


endmodule // tb_mist32_mist32e_system



`default_nettype wire

