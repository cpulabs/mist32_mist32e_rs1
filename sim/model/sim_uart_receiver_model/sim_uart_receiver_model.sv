
`default_nettype none

module sim_uart_receiver_model #(
		parameter P_BAUDRATE = 115200,
		parameter P_DISPLAY_ENA = 1,
		parameter P_DISPLAY_REALTIME = 1
	)(
		input wire iUART_RXD
	);

	integer base_latency = 8680;//1/P_BAUDRATE*1000000000;

	reg [7:0] b_rd_data;
	reg b_timing;

	initial begin
		b_rd_data = 8'h0;
		b_timing = 1'b0;
	end

	always#(base_latency/2)begin
		b_timing = !b_timing;
	end

	function [7:0] func_get_data_bit;
		input func_bit;
		input [7:0] func_data;
		begin
			func_get_data_bit = {func_bit, func_data[7:1]};
		end
	endfunction


	initial begin
		forever begin
			if(!iUART_RXD)begin
				//STARTBIT
				#(base_latency);
				//Get1
				b_rd_data = func_get_data_bit(iUART_RXD, b_rd_data);
				#(base_latency);
				//Get2
				b_rd_data = func_get_data_bit(iUART_RXD, b_rd_data);
				#(base_latency);
				//Get3
				b_rd_data = func_get_data_bit(iUART_RXD, b_rd_data);
				#(base_latency);
				//Get4
				b_rd_data = func_get_data_bit(iUART_RXD, b_rd_data);
				#(base_latency);
				//Get5
				b_rd_data = func_get_data_bit(iUART_RXD, b_rd_data);
				#(base_latency);
				//Get6
				b_rd_data = func_get_data_bit(iUART_RXD, b_rd_data);
				#(base_latency);
				//Get7
				b_rd_data = func_get_data_bit(iUART_RXD, b_rd_data);
				#(base_latency);
				//Get8
				b_rd_data = func_get_data_bit(iUART_RXD, b_rd_data);
				#(base_latency);
				//STOPBIT
				#(base_latency);
				//Display
				if(P_DISPLAY_ENA)begin
					if(b_rd_data == 8'h0a)begin
						$display("");
					end
					else begin
						if(P_DISPLAY_REALTIME)begin
							$display("%s", b_rd_data);
						end
						else begin
							$write("%s", b_rd_data);
						end
					end
				end
			end
			else begin
				#(base_latency);
			end
		end
	end


endmodule

`default_nettype wire 