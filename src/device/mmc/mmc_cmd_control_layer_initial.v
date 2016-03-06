`default_nettype none


module mmc_cmd_control_layer_initial(
		input wire iCLOCK,
		input wire inRESET,
		//Info
		//input wire iINFO_MMC_DO,
		//
		input wire iINIT_START,
		output wire oINIT_END,
		//
		output wire oMMC_REQ,
		input wire iMMC_BUSY,
		output wire oMMC_CS,
		output wire [7:0] oMMC_DATA
	);

	localparam PL_MAIN_STT_IDLE = 2'h0;
	localparam PL_MAIN_STT_WORK = 2'h1;
	localparam PL_MAIN_STT_WAIT = 2'h2;
	localparam PL_MAIN_STT_END = 2'h3;


	reg [1:0] b_main_state;
	reg [3:0] b_main_count;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_main_state <= PL_MAIN_STT_IDLE;
			b_main_count <= 4'h0;
		end
		else begin
			case(b_main_state)
				PL_MAIN_STT_IDLE:
					begin
						if(iINIT_START)begin
							b_main_state <= PL_MAIN_STT_WORK;
							b_main_count <= 4'h0;
						end
					end
				PL_MAIN_STT_WORK:
					begin
						if(b_main_count > 4'ha)begin
							b_main_state <= PL_MAIN_STT_WAIT;
						end
						else begin
							if(!iMMC_BUSY)begin
								b_main_count <= b_main_count + 4'h1;
							end
						end
					end
				PL_MAIN_STT_WAIT:
					begin
						if(!iMMC_BUSY)begin
							b_main_state <= PL_MAIN_STT_END;
						end
					end
				PL_MAIN_STT_END:
					begin
						b_main_state <= PL_MAIN_STT_IDLE;
					end
				default:
					begin
						b_main_state <= PL_MAIN_STT_IDLE;
					end
			endcase
		end
	end

	assign oINIT_END = (b_main_state == PL_MAIN_STT_END);
	assign oMMC_REQ = !iMMC_BUSY && (b_main_state == PL_MAIN_STT_WORK);
	assign oMMC_CS = 1'b1;
	assign oMMC_DATA = 8'hff;



endmodule

`default_nettype wire 



