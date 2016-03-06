

`default_nettype none


module tb_mist32_mist32e_system;
	parameter PL_MAIN_CYCLE = 20;
	parameter PL_DISPLAY_CYCLE = 40;
	parameter PL_RESET_TIME = 5;


	/****************************************
	System
	****************************************/
	reg iCLOCK;
	reg inRESET;
	reg iRESET_SYNC;
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
	/****************************************
	Device - Keyboard
	****************************************/

	/****************************************
	Device - Display
	****************************************/
	//DISP Clock
	reg iDISP_CLOCK;

	wire [31:0] memory_addr_byte_order = {oMEMORY_ADDR[29:0], 2'h0};


	mist32_mist32e_system TARGET(
		/****************************************
		System
		****************************************/
		
		/****************************************
		Initial ROM
		****************************************/
		//Flash
		.oFLASH_ADDR(),
		.iFLASH_DQ(8'h0),
		.onFLASH_CE(),
		.onFLASH_OE(),
		.onFLASH_WE(),
		.onFLASH_RESET(),
		.onFLASH_WP(),
		.onFLASH_BYTE(),
		.inFLASH_RY(1'b0),
		/****************************************
		Memory BUS
		****************************************/

		/****************************************
		Device - Keyboard
		****************************************/
		.iPS2_CLOCK(1'b0),
		.iPS2_DATA(1'b0),
		/****************************************
		Device - Display
		****************************************/
		//DISP Clock

		//SRAM
		.oDISP_SRAM_CE(),
		.oDISP_SRAM_WE(),
		.oDISP_SRAM_OE(),
		.oDISP_SRAM_UB(),
		.oDISP_SRAM_LB(),
		.oDISP_SRAM_ADDR(),
		.ioDISP_SRAM_DATA(),
		//Display - Data
		.oDISP_HSYNC(),
		.oDISP_VSYNC(),
		.oDISP_ADV_CLOCK(),
		.oDISP_ADV_BLANK(),
		.oDISP_ADV_SYNC(),
		.oDISP_ADV_R(),
		.oDISP_ADV_G(),
		.oDISP_ADV_B(),

		.*
	);



	sim_memory_model #(1, "bin/core_bench.hex") MEMORY_MODEL(
	//sim_memory_model_64bit #(3, "tb_inst_test.hex") MEMORY_MODEL(		//no load instruction file
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Req
		.iMEMORY_REQ(oMEMORY_REQ),
		.oMEMORY_LOCK(iMEMORY_BUSY),
		.iMEMORY_ORDER(2'h0),				//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		.iMEMORY_MASK(oMEMORY_MASK),
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
		iDISP_CLOCK = !iDISP_CLOCK;
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
		iDISP_CLOCK = 1'b0;
		
		//Initial Load Disable
		force TARGET.iboot_memory_valid = 1'b0;

		//Reset 
		#(PL_RESET_TIME);
		inRESET = 1'b1;
		
		


		#15000000 begin
			$finish;
		end
	end



	/******************************************************
	Assertion
	******************************************************/
	reg assert_check_flag;

	always@(posedge iCLOCK)begin
		if(inRESET && oMEMORY_REQ && !iMEMORY_BUSY && oMEMORY_RW)begin
			//Finish Check
			if(memory_addr_byte_order == 32'h0000_1004)begin
				if(!assert_check_flag)begin
					$display("[SIM-ERR]Wrong Data.");
					$display("[SIM-ERR]Simulation Finished.");
					$finish;
				end
				else begin
					$display("[SIM-OK]Simulation Finished.");
					$finish;
				end
			end
			//Check Flag
			else if(memory_addr_byte_order == 32'h0000_1000)begin
				assert_check_flag = oMEMORY_DATA[24];
			end
			//Log
			else if(memory_addr_byte_order == 32'h0000_1008)begin
				$display("Core - Bench Score : %d", oMEMORY_DATA);
			end
		end
	end



endmodule // tb_mist32_mist32e_system



`default_nettype wire

