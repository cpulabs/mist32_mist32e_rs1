
`default_nettype none

module mmc_spi_initial_clock(
		input wire iMMC_CLOCK,				//20MHz
		input wire iMMC_RESET_SYNC,
		input wire inRESET,
		output wire oMMC_INIT_CLOCK			//20MHz / 64 = 312.5KHz
	);

	reg [4:0] b_counter;
	always@(posedge iMMC_CLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_counter <= 5'h0;
		end
		else if(iMMC_RESET_SYNC) begin
			b_counter <= 5'h0;
		end
		else begin
			b_counter <= b_counter + 5'h1;
		end
	end

	reg b_initial_clock;
	always@(posedge iMMC_CLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_initial_clock <= 1'b0;
		end
		else if(iMMC_RESET_SYNC) begin
			b_initial_clock <= 1'b0;
		end
		else begin
			if(b_counter == 5'h0)begin
				b_initial_clock <= !b_initial_clock;
			end
		end
	end

	assign oMMC_INIT_CLOCK = b_initial_clock;


endmodule // mmc_spi_initial_clock

`default_nettype wire 
