


`default_nettype none

module mmc_buffer_512b(
		input wire iCLOCK,
		//Write
		input wire iWR_REQ,
		input wire [3:0] iWR_MASK,		//0=Write Active | 1=Write Protect
		input wire [6:0] iWR_ADDR,
		input wire [31:0] iWR_DATA,
		//Read
		input wire [6:0] iRD_ADDR,
		output wire [31:0] oRD_DATA
	);
	
	function [31:0] func_write_mask;
		input [31:0] func_data;
		input [31:0] func_memory_data;
		input [3:0] func_mask;
		reg [7:0] func_local_tmp_0;
		reg [7:0] func_local_tmp_1;
		reg [7:0] func_local_tmp_2;
		reg [7:0] func_local_tmp_3;
		begin
			func_local_tmp_0 = (func_mask[0])? func_memory_data[7:0] : func_data[7:0];
			func_local_tmp_1 = (func_mask[1])? func_memory_data[15:8] : func_data[15:8];
			func_local_tmp_2 = (func_mask[2])? func_memory_data[23:16] : func_data[23:16];
			func_local_tmp_3 = (func_mask[3])? func_memory_data[31:24] : func_data[31:24];
			func_write_mask = {func_local_tmp_3, func_local_tmp_2, func_local_tmp_1, func_local_tmp_0};
		end
	endfunction
	
	reg [31:0] buff[0:127];
	always@(posedge iCLOCK)begin
		//Write
		if(iWR_REQ)begin
			buff[iWR_ADDR] <= func_write_mask(iWR_DATA, buff[iWR_ADDR], iWR_MASK);
		end
	end
	
	assign oRD_DATA = buff[iRD_ADDR];

endmodule


`default_nettype wire

