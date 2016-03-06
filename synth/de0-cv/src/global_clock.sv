
`default_nettype none

module global_clock(
		//System
		input wire iCLOCK_50,				//Clock 50MHz
		//PLL
		output wire oPLL_LOCK,
		//Output
		output wire oCLOCK_MAIN,			//Main System Clock,
		output wire oCLOCK_VGA,
		output wire oCLOCK_ASMI
	);


	system_pll VGA_PLL(
		.refclk(iCLOCK_50),
		.rst(1'b0),
		.outclk_0(),					//75MHz
		.outclk_1(),					//49MHz
		.outclk_2(oCLOCK_VGA),			//25MHz
		.outclk_3(oCLOCK_ASMI),			//20MHz
		.locked (oPLL_LOCK)
	);

	
	assign oCLOCK_MAIN = iCLOCK_50;


endmodule // global_clock


`default_nettype wire

