
module altera_asmi_rom (
	clkin,
	read,
	rden,
	addr,
	reset,
	dataout,
	busy,
	data_valid,
	read_address);	

	input		clkin;
	input		read;
	input		rden;
	input	[23:0]	addr;
	input		reset;
	output	[7:0]	dataout;
	output		busy;
	output		data_valid;
	output	[23:0]	read_address;
endmodule
