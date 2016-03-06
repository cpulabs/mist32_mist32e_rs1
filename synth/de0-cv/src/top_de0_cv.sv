
`default_nettype none

module top_de0_cv(
		//System
		input wire CLOCK_50,				//Main Clock 50MHz
		/*
		//UART IF
		input wire UART_RXD,
		output wire UART_TXD,
		*/
		//VGA
		output wire VGA_HS,
		output wire VGA_VS,
		output wire [3:0] VGA_R,
		output wire [3:0] VGA_G,
		output wire [3:0] VGA_B,
		//PS2
		input wire PS2_CLK,
		input wire PS2_DAT,
		//MMC
		output wire SD_CLK,
		inout wire [3:0] SD_DATA,	//[3]CS | [0]MISO
		output wire SD_CMD,		//MOSI
		//SW
		input wire [3:0] KEY,					//Tact SW
		input wire RESET_N,
		input wire [9:0] SW,						//Slide SW
		//LED
		output wire [9:0] LEDR,					//Red LED
		//HEX Out
		output wire [6:0] HEX0,
		output wire [6:0] HEX1,
		output wire [6:0] HEX2,
		output wire [6:0] HEX3,
		output wire [6:0] HEX4,
		output wire [6:0] HEX5,
		//SDRAM
		output wire [12:0] DRAM_ADDR,
		output wire [1:0] DRAM_BA,
		output wire DRAM_CAS_N,
		output wire DRAM_CKE,
		output wire DRAM_CLK,
		output wire DRAM_CS_N,
		inout wire [15:0] DRAM_DQ,
		output wire DRAM_LDQM,
		output wire DRAM_RAS_N,
		output wire DRAM_UDQM,
		output wire DRAM_WE_N,
		//UART
		output wire UART_TXD,
		input wire UART_RXD,
		//GPIO
		inout wire [35:0] GPIO		//GPIO0 not use
	);


	/*******************************************************************************************
	Clock
	*******************************************************************************************/
	wire clock_main;
	wire clock_vga;
	wire clock_asmi;

	wire pll_lock;

	global_clock GLOBAL_CLOCK(
		//System
		.iCLOCK_50(CLOCK_50),				//Clock 50MHz
		//PLL
		.oPLL_LOCK(pll_lock),
		//Output
		.oCLOCK_MAIN(clock_main),			//Main System Clock,
		.oCLOCK_VGA(clock_vga),
		.oCLOCK_ASMI(clock_asmi)
	);
	
	
	/*******************************************************************************************
	Reset
	*******************************************************************************************/
	reg b_sync_reset0;
	reg b_sync_reset1;
	
	always@(posedge clock_main)begin
		b_sync_reset0 <= !KEY[1];
		b_sync_reset1 <= b_sync_reset0;
	end
	
	wire global_async_reset = KEY[0];
	wire global_sync_reset = 1'b0;//b_sync_reset1;
	wire global_sync_reset_asmi = 1'b0;
	

	/*******************************************************************************************
	IBOOT - Initial Instruction Boot
	*******************************************************************************************/
	//Initial Boot ROM
	wire iboot_memory_valid;
	wire iboot_memory_req_valid;
	wire iboot_memory_req_dqm0;
	wire iboot_memory_req_dqm1;
	wire iboot_memory_req_dqm2;
	wire iboot_memory_req_dqm3;
	wire [24:0] iboot_memory_req_addr;
	wire [31:0] iboot_memory_req_data;
	wire iboot_memory_req_lock;

	iboot_rom_de0_cv IBOOT_ROM(
		//System
		.iCLOCK(clock_main),
		.inRESET(global_async_reset),
		.iRESET_SYNC(global_sync_reset),
		//ASMI Clock
		.iCLOCK_ASMI(clock_asmi),		//~20MHz
		.iRESET_ASMI_SYNC(global_sync_reset_asmi),
		//IBOOT
		.oIBOOT_VALID(iboot_memory_valid),
		.oIBOOT_MEMIF_REQ_VALID(iboot_memory_req_valid),
		.oIBOOT_MEMIF_REQ_DQM0(iboot_memory_req_dqm0),
		.oIBOOT_MEMIF_REQ_DQM1(iboot_memory_req_dqm1),
		.oIBOOT_MEMIF_REQ_DQM2(iboot_memory_req_dqm2),
		.oIBOOT_MEMIF_REQ_DQM3(iboot_memory_req_dqm3),
		.oIBOOT_MEMIF_REQ_RW(),
		.oIBOOT_MEMIF_REQ_ADDR(iboot_memory_req_addr),
		.oIBOOT_MEMIF_REQ_DATA(iboot_memory_req_data),
		.iIBOOT_MEMIF_REQ_LOCK(iboot_memory_req_lock)
	);

	/*******************************************************************************************
	Computer - System
	*******************************************************************************************/
	wire memory_req_req;
	wire memory_req_busy;
	wire [3:0] memory_req_mask;
	wire memory_req_rw;
	wire [31:0] memory_req_addr;
	wire [31:0] memory_req_data;
	wire memory_get_valid;
	wire memory_get_busy;
	wire [63:0] memory_get_data;

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
		.iCLOCK(clock_main),
		.inRESET(global_async_reset),
		.iRESET_SYNC(global_sync_reset),
		/****************************************
		IBOOT
		****************************************/
		.iIBOOT_VALID(iboot_memory_valid),
		.iIBOOT_MEMIF_REQ_VALID(iboot_memory_req_valid),
		.iIBOOT_MEMIF_REQ_DQM0(iboot_memory_req_dqm0),
		.iIBOOT_MEMIF_REQ_DQM1(iboot_memory_req_dqm1),
		.iIBOOT_MEMIF_REQ_DQM2(iboot_memory_req_dqm2),
		.iIBOOT_MEMIF_REQ_DQM3(iboot_memory_req_dqm3),
		.iIBOOT_MEMIF_REQ_RW(1'b1),
		.iIBOOT_MEMIF_REQ_ADDR(iboot_memory_req_addr),
		.iIBOOT_MEMIF_REQ_DATA(iboot_memory_req_data),
		.oIBOOT_MEMIF_REQ_LOCK(iboot_memory_req_lock),
		/****************************************
		Memory BUS
		****************************************/
		//Req
		.oMEMORY_REQ(memory_req_req),
		.iMEMORY_BUSY(memory_req_busy),
		.oMEMORY_MASK(memory_req_mask),
		.oMEMORY_RW(memory_req_rw),						//1:Write | 0:Read
		.oMEMORY_ADDR(memory_req_addr),
		//This -> Data RAM
		.oMEMORY_DATA(memory_req_data),
		//Data RAM -> This
		.iMEMORY_VALID(memory_get_valid),
		.oMEMORY_BUSY(memory_get_busy),
		.iMEMORY_DATA(memory_get_data),
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
		.oEXTIO_IRQ_CONFIG_TABLE_FLAG_LEVEL(processor_interconnect_irq_cfgt_level)
	);

	
	/*******************************************************************************************
	Device Interrconnect
	*******************************************************************************************/
	/*************************************
	Dev0 : Keyboard
	Dev1 : UART
	Dev2 : SD
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
		.iCLOCK(clock_main),
		.inRESET(global_async_reset),
		.iRESET_SYNC(global_sync_reset),
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
		.iCLOCK(clock_main),
		.inRESET(global_async_reset),
		.iRESET_SYNC(global_sync_reset),
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
		.iPS2_CLOCK(PS2_CLK),
		.iPS2_DATA(PS2_DAT)
	);


	/*******************************************************************************************
	Device - SCI
	*******************************************************************************************/
	sci_top DEVICE_SCI(
		.iCLOCK(clock_main),
		.inRESET(global_async_reset),
		.iRESET_SYNC(global_sync_reset),
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
		//UART
		.oUART_TXD(UART_TXD),
		.iUART_RXD(UART_RXD)
	);
	
	


	/*******************************************************************************************
	Device - VGA
	*******************************************************************************************/
	wire disp_mem_req_valid;
	wire disp_mem_req_rw;
	wire [31:0] disp_mem_req_addr;
	wire [15:0] disp_mem_req_data;
	wire disp_mem_req_busy;
	wire disp_mem_result_valid;
	wire [15:0] disp_mem_result_data;
	wire disp_mem_result_busy;


	vga_display_sdram DEVICE_DISPLAY(
		//System
		.iCLOCK(clock_main),
		.inRESET(global_async_reset),
		.iRESET_SYNC(global_sync_reset),
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
		.iVGA_CLOCK(clock_vga),
		//DRAM
		.oMEM_VALID(disp_mem_req_valid),
		.oMEM_BYTEENA(),
		.oMEM_RW(disp_mem_req_rw),
		.oMEM_ADDR(disp_mem_req_addr),
		.oMEM_DATA(disp_mem_req_data),
		.iMEM_BUSY(disp_mem_req_busy),
		.iMEM_VALID(disp_mem_result_valid),
		.iMEM_DATA(disp_mem_result_data),
		.oMEM_BUSY(disp_mem_result_busy),

		//Display
		.oDISP_HSYNC(VGA_HS),
		.oDISP_VSYNC(VGA_VS),
		//ADV7123 Output
		.oADV_CLOCK(),
		.onADV_BLANK(),
		.onADV_SYNC(),
		.oADV_R(VGA_R),
		.oADV_G(VGA_G),
		.oADV_B(VGA_B)
	);	
	
	
	/*******************************************************************************************
	Device - MMC 512 Card
	*******************************************************************************************/
	mmc_top DEVICE_MMC(
		//System
		.iCLOCK(clock_main),
		.inRESET(global_async_reset),
		.iRESET_SYNC(global_sync_reset),
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
		.oMMC_CE(SD_DATA[3]),
		.oMMC_CLK(SD_CLK),
		.oMMC_MOSI(SD_CMD),
		.iMMC_MISO(SD_DATA[0])
	);

	/*******************************************************************************************
	Main Memory - IF
	*******************************************************************************************/	
	wire memory_wr;
	wire [7:0] memory_byteena;
	wire [31:0] memory_addr;
	wire [63:0] memory_wr_data;
	wire [63:0] memory_rd_data;

	memory_if MEMIF(
		/****************************************
		System
		****************************************/
		.iCLOCK(clock_main),
		.inRESET(global_async_reset),
		.iRESET_SYNC(global_sync_reset),
		/****************************************
		Processor BUS
		****************************************/
		//Req
		.iCPU_REQ(memory_req_req),
		.oCPU_BUSY(memory_req_busy),
		.iCPU_MASK(memory_req_mask),
		.iCPU_RW(memory_req_rw),						//1:Write | 0:Read
		.iCPU_ADDR(memory_req_addr),
		//This -> Data RAM
		.iCPU_DATA(memory_req_data),
		//Data RAM -> This
		.oCPU_VALID(memory_get_valid),
		.iCPU_BUSY(memory_get_busy),
		.oCPU_DATA(memory_get_data),
		/****************************************
		Memory
		****************************************/
		.oMEM_WR(memory_wr),
		.oMEM_BYTEENA(memory_byteena),
		.oMEM_ADDR(memory_addr),
		.oMEM_DATA(memory_wr_data),
		.iMEM_DATA(memory_rd_data)
	);


	/*******************************************************************************************
	External SDRAM Memory for Display
	*******************************************************************************************/
	wire sdram_ctrl_result_fifo_empty;
	sdram_controller SDRAMC(
		//System
		.iCLOCK(clock_main),			
		.inRESET(global_async_reset),
		//User-REQ
		.iUSER_REQ_VALID(disp_mem_req_valid && !disp_mem_req_busy),
		.inUSER_REQ_DQM(2'b00),			//Write only support
		.iUSER_REQ_RW(disp_mem_req_rw),			//0:Read 1:Write
		.iUSER_REQ_ADDR(disp_mem_req_addr[23:0]),
		.iUSER_REQ_DATA(disp_mem_req_data),
		.oUSER_REQ_LOCK(disp_mem_req_busy),
		//User-OUT
		.iUSER_OUT_VALID(!sdram_ctrl_result_fifo_empty && !disp_mem_result_busy),
		.oUSER_OUT_DATA(disp_mem_result_data),
		.oUSER_OUT_EMPTY(sdram_ctrl_result_fifo_empty),
		//SDRASM
		.oSDRAM_ADDR(DRAM_ADDR),
		.oSDRAM_BA(DRAM_BA),
		.ioSDRAM_DATA(DRAM_DQ),
		.onSDRAM_CS(DRAM_CS_N),
		.onSDRAM_RAS(DRAM_RAS_N),
		.onSDRAM_CAS(DRAM_CAS_N),
		.onSDRAM_WE(DRAM_WE_N),
		.onSDRAM_DQM({DRAM_UDQM, DRAM_LDQM}),
		.oSDRAM_CKE(DRAM_CKE),
		.oSDRAM_CLK(DRAM_CLK)
	);

	assign disp_mem_result_valid = !sdram_ctrl_result_fifo_empty && !disp_mem_result_busy;



	/*******************************************************************************************
	Main Memory
	*******************************************************************************************/	
	/****************************************************
	Altera Primitive 1-Port RAM
	
	bit Size	: 64
	Word Size	: 32768
	Total bit	: 2Mb
	Q-Buffer	: ON
	Byte Enable	: ON 8bit
	Read/Write	: Don't Care
	****************************************************/
	altera_primitive_ram_64bit_32768word MAIN_RAM(
		.address(memory_addr[14:0]),
		.byteena(memory_byteena),
		.clock(CLOCK_50),
		.data(memory_wr_data),
		.wren(memory_wr),
		.q(memory_rd_data)
	);
	
	

	/*******************************************************************************************
	Board
	*******************************************************************************************/
	assign LEDR = {8'h0, !iboot_memory_valid, pll_lock};



endmodule // top_de2_115


`default_nettype wire

