
`default_nettype none

module mmc_spi_async_transfer_layer(
		//System
		input wire iCLOCK,
		input wire inRESET,
		input wire iMMC_CLOCK,
		input wire iRESET_SYNC,	//for iCLOCK
		//Master - Req	
		input wire iMASTER_REQ,
		output wire oMASTER_LOCK,
		input wire [7:0] iMASTER_DATA,
		//Master - Data Rec
		output wire oMASTER_VALID,
		output wire [7:0] oMASTER_DATA,
		output wire oMASTER_INFO_MISO,
		//SPI
		output wire oSPI_CLK,
		output wire oSPI_MOSI,
		input wire iSPI_MISO
	);

	/**********************************************
	MMC Sync Reset(for 50Mhz)
	**********************************************/
	localparam PL_MMC_RESET_STT_0 = 2'h0;
	localparam PL_MMC_RESET_STT_1 = 2'h1;
	localparam PL_MMC_RESET_STT_2 = 2'h2;
	localparam PL_MMC_RESET_STT_IDLE = 2'h3;
	
	reg [1:0] b_mmc_reset_state;

	always @(posedge iCLOCK or negedge inRESET) begin
		if (!inRESET) begin
			b_mmc_reset_state <= PL_MMC_RESET_STT_0;
		end
		else if(iRESET_SYNC)begin
			b_mmc_reset_state <= PL_MMC_RESET_STT_0;
		end
		else begin
			case(b_mmc_reset_state)
				PL_MMC_RESET_STT_0:
					begin
						b_mmc_reset_state <= PL_MMC_RESET_STT_1;
					end
				PL_MMC_RESET_STT_1:
					begin
						b_mmc_reset_state <= PL_MMC_RESET_STT_2;
					end
				PL_MMC_RESET_STT_2:
					begin
						b_mmc_reset_state <= PL_MMC_RESET_STT_IDLE;
					end
				PL_MMC_RESET_STT_IDLE:
					begin
						b_mmc_reset_state <= PL_MMC_RESET_STT_IDLE;
					end
			endcase
		end
	end

	reg b_mmc_reset_buff0;
	reg b_mmc_reset_buff1;
	reg b_mmc_reset_buff2;
	always @(posedge iMMC_CLOCK or negedge inRESET) begin
		if (!inRESET) begin
			b_mmc_reset_buff0 <= 1'b0;
			b_mmc_reset_buff1 <= 1'b0;
			b_mmc_reset_buff2 <= 1'b0;
		end
		else begin
			b_mmc_reset_buff0 <= (b_mmc_reset_state != PL_MMC_RESET_STT_IDLE);
			b_mmc_reset_buff1 <= b_mmc_reset_buff0;
			b_mmc_reset_buff2 <= b_mmc_reset_buff1;
		end
	end

	wire mmc_sync_reset = b_mmc_reset_buff2;

	/**********************************************
	Request State
	**********************************************/
	wire fifo_full;
	wire spi_done;

	localparam PL_REQ_STT_IDLE = 1'h0;
	localparam PL_REQ_STT_WAIT = 1'h1;

	reg b_req_state;

	wire system_busy = (b_req_state != PL_REQ_STT_IDLE) || fifo_full || (b_mmc_reset_state != PL_MMC_RESET_STT_IDLE);

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_req_state <= PL_REQ_STT_IDLE;
		end
		else if(iRESET_SYNC)begin
			b_req_state <= PL_REQ_STT_IDLE;
		end
		else begin
			case(b_req_state)
				PL_REQ_STT_IDLE:
					begin
						if(!system_busy && iMASTER_REQ)begin
							b_req_state <= PL_REQ_STT_WAIT;
						end
					end
				PL_REQ_STT_WAIT:
					begin
						if(spi_done)begin
							b_req_state <= PL_REQ_STT_IDLE;
						end
					end
			endcase
		end
	end


	/**********************************************
	ASYNC FIFO
	**********************************************/
	wire fifo_empty;
	wire [7:0] fifo_data;

	mmc_async_fifo #(8, 4, 2) REQ_FIFO(
		.inRESET(inRESET),
		.iRESET_SYNC_WR(iRESET_SYNC),
		.iRESET_SYNC_RD(mmc_sync_reset),
		.iWR_CLOCK(iCLOCK),
		.iWR_EN(!system_busy && iMASTER_REQ),
		.iWR_DATA(iMASTER_DATA),
		.oWR_FULL(fifo_full),
		.oWR_COUNT(),
		.iRD_CLOCK(iMMC_CLOCK),
		.iRD_EN(!fifo_empty),
		.oRD_DATA(fifo_data),
		.oRD_EMPTY(fifo_empty),
		.oRD_COUNT()
	);

	wire fifo_read_valid = !fifo_empty;



	
	/**********************************************
	Generage SPI Clock
	**********************************************/
	localparam PL_PARAM_SPI_IDLE = 4'h0;
	localparam PL_PARAM_SPI_DATA_SET = 4'ha;
	localparam PL_PARAM_SPI_DATA0 = 4'h1;
	localparam PL_PARAM_SPI_DATA1 = 4'h2;
	localparam PL_PARAM_SPI_DATA2 = 4'h3;
	localparam PL_PARAM_SPI_DATA3 = 4'h4;
	localparam PL_PARAM_SPI_DATA4 = 4'h5;
	localparam PL_PARAM_SPI_DATA5 = 4'h6;
	localparam PL_PARAM_SPI_DATA6 = 4'h7;
	localparam PL_PARAM_SPI_DATA7 = 4'h8;
	localparam PL_PARAM_SPI_END = 4'h9;

	reg [3:0] b_spi_state;
	
	always@(posedge iMMC_CLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_spi_state <= PL_PARAM_SPI_IDLE;
		end
		else if(mmc_sync_reset)begin
			b_spi_state <= PL_PARAM_SPI_IDLE;
		end
		else begin
			case(b_spi_state)
				PL_PARAM_SPI_IDLE:
					begin
						if(fifo_read_valid)begin
							b_spi_state <= PL_PARAM_SPI_DATA_SET;
						end
					end
				PL_PARAM_SPI_DATA_SET:
					begin
						b_spi_state <= PL_PARAM_SPI_DATA0;
					end
				PL_PARAM_SPI_DATA0:
					begin
						b_spi_state <= PL_PARAM_SPI_DATA1;
					end
				PL_PARAM_SPI_DATA1:
					begin
						b_spi_state <= PL_PARAM_SPI_DATA2;
					end
				PL_PARAM_SPI_DATA2:
					begin
						b_spi_state <= PL_PARAM_SPI_DATA3;
					end
				PL_PARAM_SPI_DATA3:
					begin
						b_spi_state <= PL_PARAM_SPI_DATA4;
					end
				PL_PARAM_SPI_DATA4:
					begin
						b_spi_state <= PL_PARAM_SPI_DATA5;
					end
				PL_PARAM_SPI_DATA5:
					begin
						b_spi_state <= PL_PARAM_SPI_DATA6;
					end
				PL_PARAM_SPI_DATA6:
					begin
						b_spi_state <= PL_PARAM_SPI_DATA7;
					end
				PL_PARAM_SPI_DATA7:
					begin
						b_spi_state <= PL_PARAM_SPI_END;
					end
				PL_PARAM_SPI_END:
					begin
						b_spi_state <= PL_PARAM_SPI_IDLE;
					end
				default:
					begin
						b_spi_state <= PL_PARAM_SPI_IDLE;
					end
			endcase
		end
	end

	//RxD
	reg [7:0] b_txd_data;
	reg [7:0] b_rxd_data;
	always@(posedge iMMC_CLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_rxd_data <= 8'h0;
		end
		else if(mmc_sync_reset)begin
			b_rxd_data <= 8'h0;
		end
		else if(b_spi_state == PL_PARAM_SPI_IDLE)begin
			b_rxd_data <= 8'h0;
		end
		else if(b_spi_state == PL_PARAM_SPI_END)begin
			b_rxd_data <= b_rxd_data;
		end
		else begin
			b_rxd_data <= {b_rxd_data[6:0], iSPI_MISO};
		end
	end

	//Txd
	always@(posedge iMMC_CLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_txd_data <= 8'h0;
		end
		else if(mmc_sync_reset)begin
			b_txd_data <= 8'h0;
		end
		else begin
			if(fifo_read_valid)begin
				b_txd_data <= fifo_data;
			end
		end
	end

	function func_spi_out_data;
		input [3:0] func_state;
		input [7:0] func_data;
		begin
			case(func_state)
				PL_PARAM_SPI_DATA_SET : func_spi_out_data = func_data[7];
				PL_PARAM_SPI_DATA0 : func_spi_out_data = func_data[7];
				PL_PARAM_SPI_DATA1 : func_spi_out_data = func_data[6];
				PL_PARAM_SPI_DATA2 : func_spi_out_data = func_data[5];
				PL_PARAM_SPI_DATA3 : func_spi_out_data = func_data[4];
				PL_PARAM_SPI_DATA4 : func_spi_out_data = func_data[3];
				PL_PARAM_SPI_DATA5 : func_spi_out_data = func_data[2];
				PL_PARAM_SPI_DATA6 : func_spi_out_data = func_data[1];
				PL_PARAM_SPI_DATA7 : func_spi_out_data = func_data[0];
				default : func_spi_out_data = 1'b1;
			endcase
		end
	endfunction


	/**********************************************
	SPI Transfer End
	**********************************************/
	reg b_async_buff_valid0;
	reg b_async_buff_valid1;
	reg b_async_buff_valid2;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_async_buff_valid0 <= 1'b0;
			b_async_buff_valid1 <= 1'b0;
			b_async_buff_valid2 <= 1'b0;
		end
		else if(iRESET_SYNC)begin
			b_async_buff_valid0 <= 1'b0;
			b_async_buff_valid1 <= 1'b0;
			b_async_buff_valid2 <= 1'b0;
		end
		else begin
			b_async_buff_valid0 <= (b_spi_state == PL_PARAM_SPI_END);
			b_async_buff_valid1 <= b_async_buff_valid0;
			b_async_buff_valid2 <= b_async_buff_valid1;
		end
	end

	assign spi_done = !b_async_buff_valid2 && b_async_buff_valid1;

	reg [7:0] b_async_buff_data0;
	reg [7:0] b_async_buff_data1;
	reg [7:0] b_async_buff_data2;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_async_buff_data0 <= 8'h0;
			b_async_buff_data1 <= 8'h0;
			b_async_buff_data2 <= 8'h0;
		end
		else if(iRESET_SYNC)begin
			b_async_buff_data0 <= 8'h0;
			b_async_buff_data1 <= 8'h0;
			b_async_buff_data2 <= 8'h0;
		end
		else begin
			b_async_buff_data0 <= b_rxd_data;
			b_async_buff_data1 <= b_async_buff_data0;
			b_async_buff_data2 <= b_async_buff_data1;
		end
	end
	

	assign oMASTER_LOCK = system_busy;

	assign oMASTER_VALID = spi_done;
	assign oMASTER_DATA = b_async_buff_data1;//b_async_buff_data2;
	assign oMASTER_INFO_MISO = iSPI_MISO;
	
	assign oSPI_CLK = (b_spi_state == PL_PARAM_SPI_IDLE || b_spi_state == PL_PARAM_SPI_END || b_spi_state == PL_PARAM_SPI_DATA_SET)? 1'b1 : iMMC_CLOCK;
	assign oSPI_MOSI = func_spi_out_data(b_spi_state, b_txd_data);


endmodule

`default_nettype wire

