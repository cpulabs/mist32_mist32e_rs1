
`default_nettype none

module global_clock(
		//System
		input wire iCLOCK_50,				//Clock 50MHz
		//PLL
		output wire oPLL_LOCK,
		//Output
		output wire oCLOCK_MAIN,			//Main System Clock,
		output wire oCLOCK_VGA,
		output wire oCLOCK_ASMI,
		output wire oCLOCK_MMC
	);

	wire clock_20mhz;
	system_pll VGA_PLL(
		.inclk0(iCLOCK_50),
		.c0(),					//75MHz
		.c1(),					//49MHz
		.c2(oCLOCK_VGA),		//25MHz
		.c3(clock_20mhz),		//20MHz
		.locked (oPLL_LOCK)
	);

	assign oCLOCK_MAIN = iCLOCK_50;
	assign oCLOCK_ASMI = clock_20mhz;
	assign oCLOCK_MMC = clock_20mhz;


endmodule // global_clock


`default_nettype wire

