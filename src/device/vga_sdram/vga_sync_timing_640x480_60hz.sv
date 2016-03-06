`default_nettype none
//VGA Clock is 25.2MHz


module vga_sync_timing_640x480_60hz(
		input wire iVGA_CLOCK,		//25.2MHz @640x480 60Hz
		input wire inRESET,
		input wire iRESET_SYNC,
		//PIXCEL
		output wire oDATA_REQ,
		//DISP Out
		output wire oDISP_VSYNC,
		output wire oDISP_HSYNC,
		output wire oDISP_BLANK
	);
	
	/*************************************************
	//Main State
	*************************************************/
	reg [9:0] b_hs_counter;
	reg [9:0] b_vs_counter;
	
	always@(posedge iVGA_CLOCK or negedge inRESET)begin
		if(!inRESET)begin	
			b_hs_counter <= {10{1'b0}};
			b_vs_counter <= {10{1'b0}};
		end
		else if(iRESET_SYNC)begin
			b_hs_counter <= {10{1'b0}};
			b_vs_counter <= {10{1'b0}};
		end
		else begin
			b_hs_counter <= (b_hs_counter < 96 + 48 + 640 + 16)? b_hs_counter + {{9{1'b0}}, 1'b1} : {10{1'b0}};
			b_vs_counter <= (!(b_hs_counter == 0))? b_vs_counter : (b_vs_counter < 525)? b_vs_counter + {{9{1'b0}}, 1'b1} : {10{1'b0}};
		end
	end
	
	assign oDISP_BLANK = (b_hs_counter > 96 + 48 & b_hs_counter <= 96 + 48 + 640 & b_vs_counter > 2 + 33 &  b_vs_counter <= 2 + 33 + 480)? 1'b0 : 1'b1;
	assign oDATA_REQ = (b_hs_counter > 96 + 48 & b_hs_counter <= 96 + 48 + 640 & b_vs_counter > 2 + 33 &  b_vs_counter <= 2 + 33 + 480)? 1'b1 : 1'b0;
	
	assign oDISP_HSYNC = (b_hs_counter < 95)? 1'b0 : 1'b1;
	assign oDISP_VSYNC = (b_vs_counter < 2)? 1'b0 : 1'b1;
	
	
endmodule


`default_nettype wire


