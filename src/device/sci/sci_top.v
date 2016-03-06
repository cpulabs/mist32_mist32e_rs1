`default_nettype none


module sci_top(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//CPU Interface
		input wire iREQ_VALID,
		output wire oREQ_BUSY,		//Ignore
		input wire iREQ_RW,
		input wire [31:0] iREQ_ADDR,
		input wire [31:0] iREQ_DATA,
		output wire oREQ_VALID,
		output wire [31:0] oREQ_DATA,
		//IRQ
		output wire oIRQ_VALID,
		output wire [5:0] oIRQ_NUM,
		input wire iIRQ_ACK,
		//UART
		output wire oUART_TXD,
		input wire iUART_RXD
	);

	localparam SCITX = 32'h0;
	localparam SCIRX = 32'h4;
	localparam SCICFG = 32'h8;
	localparam SCIFLAG = 32'hc;
	
	//SCI Config Register
	reg b_scicfg_ten;
	reg b_scicfg_ren;
	reg [3:0] b_scicfg_bdr;
	reg [2:0] b_scicfg_tire;
	reg [2:0] b_scicfg_rire;
	//SCI Module
	wire uart_mod_full;
	wire [3:0] uart_mod_txd_fifo_counter;
	wire uart_mod_txd_transmit;
	wire uart_mod_empty;
	wire [7:0] uart_mod_data;
	wire [3:0] uart_mod_rxd_fifo_counter;
	wire uart_mod_rxd_receive;
	//Transmit Buffer
	reg b_irq_transmit_buff_irq;
	reg b_irq_transmit_buff_resresh_wait;
	reg [3:0] b_irq_transmit_buff_resresh_count;
	//Receive Buffer
	reg b_irq_receive_buff_irq;
	reg b_irq_receive_buff_resresh_wait;
	reg [3:0] b_irq_receive_buff_resresh_count;
	//IRQ State
	reg b_irq_state;
	reg b_irq_ack;
	
	
	/**********************************
	SCI Config Register
	**********************************/
	wire scicfg_write_condition = iREQ_ADDR == SCICFG && iREQ_VALID && iREQ_RW;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_scicfg_ten <= 1'b0;
			b_scicfg_ren <= 1'b0;
			b_scicfg_tire <= 3'b0;
			b_scicfg_rire <= 3'b0;
		end
		else if(iRESET_SYNC)begin
			b_scicfg_ten <= 1'b0;
			b_scicfg_ren <= 1'b0;
			b_scicfg_tire <= 3'b0;
			b_scicfg_rire <= 3'b0;
		end
		else begin
			if(scicfg_write_condition)begin
				b_scicfg_ten <= iREQ_DATA[0];					
				b_scicfg_ren <= iREQ_DATA[1];
				b_scicfg_tire <= iREQ_DATA[8:6];
				b_scicfg_rire <= iREQ_DATA[11:9];
			end
		end
	end
	
	/**********************************
	SCI Flag Register
	**********************************/
	reg b_sciflag_rirq;
	reg b_sciflag_tirq;
	
	wire sciflag_read_condition = iREQ_ADDR == SCIFLAG && iREQ_VALID && !iREQ_RW;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_sciflag_rirq <= 1'b0;
			b_sciflag_tirq <= 1'b0;
		end
		else if(iRESET_SYNC)begin
			b_sciflag_rirq <= 1'b0;
			b_sciflag_tirq <= 1'b0;
		end
		else begin
			if(sciflag_read_condition)begin
				b_sciflag_rirq <= 1'b0;
				b_sciflag_tirq <= 1'b0;
			end
			else begin
				if(b_irq_receive_buff_irq)begin
					b_sciflag_rirq <= 1'b1;
				end
				if(b_irq_transmit_buff_irq)begin
					b_sciflag_tirq <= 1'b1;
				end
			end
		end
	end
	
	
	
	/**********************************
	SCI Module
	**********************************/
	uart UARTMOD(
		//Clock
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//TxD
		.iTX_EN(b_scicfg_ten),
		.iTX_REQ(iREQ_VALID && !uart_mod_full && (iREQ_ADDR == SCITX) && iREQ_RW),
		.oTX_BUSY(uart_mod_full),
		.iTX_DATA(iREQ_DATA[7:0]),
		.oTX_BUFF_CNT(uart_mod_txd_fifo_counter),
		.oTX_TRANSMIT(uart_mod_txd_transmit),
		//RxD
		.iRX_EN(b_scicfg_ren),
		.iRX_REQ(iREQ_VALID && !uart_mod_empty && (iREQ_ADDR == SCIRX) && !iREQ_RW),
		.oRX_EMPTY(uart_mod_empty),
		.oRX_DATA(uart_mod_data),
		.oRX_BUFF_CNT(uart_mod_rxd_fifo_counter),
		.oRX_RECEIVE(uart_mod_rxd_receive),
		//UART
		.oUART_TXD(oUART_TXD),
		.iUART_RXD(iUART_RXD)
	);

	/**********************************
	IRQ - SCICFG_TIRE & SCICFG_RIRE Register
	**********************************/
	//Transmit Buffer
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_irq_transmit_buff_irq <= 1'b0;
			b_irq_transmit_buff_resresh_wait <= 1'b0;
			b_irq_transmit_buff_resresh_count <= 4'h0;
		end
		else if(iRESET_SYNC)begin
			b_irq_transmit_buff_irq <= 1'b0;
			b_irq_transmit_buff_resresh_wait <= 1'b0;
			b_irq_transmit_buff_resresh_count <= 4'h0;
		end
		//Reset
		else if(scicfg_write_condition)begin
			b_irq_transmit_buff_irq <= 1'b0;
			b_irq_transmit_buff_resresh_wait <= 1'b0;
			b_irq_transmit_buff_resresh_count <= 4'h0;
		end
		//FIFO Resresh Wait
		else if(b_irq_transmit_buff_resresh_wait)begin
			b_irq_transmit_buff_irq <= 1'b0;
			if(b_irq_transmit_buff_resresh_count > uart_mod_txd_fifo_counter)begin
				b_irq_transmit_buff_resresh_wait <= 1'b0;
			end
		end
		//Normal State
		else begin
			//IRQ Watch
			if(!b_irq_transmit_buff_irq)begin
				if(uart_mod_txd_transmit)begin
					case(b_scicfg_tire)
						3'h0 : b_irq_transmit_buff_irq <= 1'b0;
						3'h1 : 
							begin
								if(uart_mod_txd_fifo_counter <= 4'h1)begin
									b_irq_transmit_buff_irq <= 1'b1;
									b_irq_transmit_buff_resresh_count <= 4'h1;
								end
							end
						3'h2 : 
							begin
								if(uart_mod_txd_fifo_counter <= 4'h2)begin
									b_irq_transmit_buff_irq <= 1'b1;
									b_irq_transmit_buff_resresh_count <= 4'h2;
								end
							end
						3'h3 : 
							begin
								if(uart_mod_txd_fifo_counter <= 4'h4)begin
									b_irq_transmit_buff_irq <= 1'b1;
									b_irq_transmit_buff_resresh_count <= 4'h4;
								end
							end
						3'h4 : 
							begin
								if(uart_mod_txd_fifo_counter <= 4'h8)begin
									b_irq_transmit_buff_irq <= 1'b1;
									b_irq_transmit_buff_resresh_count <= 4'h8;
								end
							end
						default : b_irq_transmit_buff_irq <= 1'b0;
					endcase
				end
			end
			//Busy State
			else begin
				if(b_irq_ack)begin
					b_irq_transmit_buff_irq <= 1'b0;
					b_irq_transmit_buff_resresh_wait <= 1'b1;
				end
			end
		end
	end
	
	//Receive Buffer
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_irq_receive_buff_irq <= 1'b0;
			b_irq_receive_buff_resresh_wait <= 1'b0;
			b_irq_receive_buff_resresh_count <= 4'h0;
		end
		else if(iRESET_SYNC)begin
			b_irq_receive_buff_irq <= 1'b0;
			b_irq_receive_buff_resresh_wait <= 1'b0;
			b_irq_receive_buff_resresh_count <= 4'h0;
		end
		//Reset
		else if(scicfg_write_condition)begin
			b_irq_receive_buff_irq <= 1'b0;
			b_irq_receive_buff_resresh_wait <= 1'b0;
			b_irq_receive_buff_resresh_count <= 4'h0;
		end
		//FIFO Resresh Wait
		else if(b_irq_receive_buff_resresh_wait)begin
			b_irq_receive_buff_irq <= 1'b0;
			if(b_irq_receive_buff_resresh_count < uart_mod_rxd_fifo_counter)begin
				b_irq_receive_buff_resresh_wait <= 1'b0;
			end
		end
		//Normal State
		else begin
			//IRQ Watch
			if(!b_irq_receive_buff_irq)begin
				if(uart_mod_rxd_receive)begin
					case(b_scicfg_tire)
						3'h0 : b_irq_receive_buff_irq <= 1'b0;
						3'h1 : 
							begin
								if(uart_mod_rxd_fifo_counter >= 4'h1)begin
									b_irq_receive_buff_irq <= 1'b1;
									b_irq_receive_buff_resresh_count <= 4'h1;
								end
							end
						3'h2 : 
							begin
								if(uart_mod_rxd_fifo_counter >= 4'h2)begin
									b_irq_receive_buff_irq <= 1'b1;
									b_irq_receive_buff_resresh_count <= 4'h1;
								end
							end
						3'h3 : 
							begin
								if(uart_mod_rxd_fifo_counter >= 4'h4)begin
									b_irq_receive_buff_irq <= 1'b1;
									b_irq_receive_buff_resresh_count <= 4'h1;
								end
							end
						3'h4 : 
							begin
								if(uart_mod_rxd_fifo_counter >= 4'h8)begin
									b_irq_receive_buff_irq <= 1'b1;
									b_irq_receive_buff_resresh_count <= 4'h1;
								end
							end
						3'h5 : 
							begin
								if(uart_mod_rxd_fifo_counter == 4'hF)begin
									b_irq_receive_buff_irq <= 1'b1;
									b_irq_receive_buff_resresh_count <= 4'h1;
								end
							end
						default : b_irq_receive_buff_irq <= 1'b0;
					endcase
				end
			end
			//Busy State
			else begin
				if(b_irq_ack)begin
					b_irq_receive_buff_irq <= 1'b0;
					b_irq_receive_buff_resresh_wait <= 1'b1;
				end
			end
		end
	end
	
	localparam IRQ_STT_IDLE = 1'b0;
	localparam IRQ_STT_IRQ = 1'b1;
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_irq_state <= IRQ_STT_IDLE;
			b_irq_ack <= 1'b0;
		end
		else if(iRESET_SYNC)begin
			b_irq_state <= IRQ_STT_IDLE;
			b_irq_ack <= 1'b0;
		end
		else begin
			case(b_irq_state)
				IRQ_STT_IDLE:
					begin
						//IRQ Check
						if(b_irq_receive_buff_irq || b_irq_transmit_buff_irq)begin
							b_irq_ack <= 1'b0;
							b_irq_state <= IRQ_STT_IRQ;
						end
						else begin
							b_irq_ack <= 1'b0;
						end
					end
				IRQ_STT_IRQ:
					begin
						b_irq_ack <= 1'b0;
						if(iIRQ_ACK)begin
							b_irq_state <= IRQ_STT_IDLE;
						end
					end
			endcase
		end
	end
	
	
	reg b_ack_buffer_ack;
	reg [31:0] b_ack_buffer_data;
	
	//Request Ack
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_ack_buffer_ack <= 1'b0;
		end
		else if(iRESET_SYNC)begin
			b_ack_buffer_ack <= 1'b0;
		end
		else begin
			b_ack_buffer_ack <= (iREQ_VALID && (iREQ_ADDR == SCIRX) && !iREQ_RW) || (iREQ_VALID && (iREQ_ADDR == SCICFG) && !iREQ_RW) || (iREQ_VALID && (iREQ_ADDR == SCIFLAG) && !iREQ_RW);
		end
	end
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_ack_buffer_data <= 32'h0;
		end
		else if(iRESET_SYNC)begin
			b_ack_buffer_data <= 32'h0;
		end
		else begin
			if(iREQ_ADDR == SCICFG)begin
				b_ack_buffer_data <= {20'h0, b_scicfg_rire, b_scicfg_tire, b_scicfg_bdr, b_scicfg_ren, b_scicfg_ten};
			end
			else if(iREQ_ADDR == SCIFLAG)begin
				b_ack_buffer_data <= {30'h0, b_sciflag_rirq, b_sciflag_tirq};
			end
			else if(iREQ_ADDR == SCIRX)begin
				b_ack_buffer_data <= (uart_mod_empty)? 32'h0 : 32'h80000000 | uart_mod_data;
			end
			else begin
				b_ack_buffer_data <= 32'h0;
			end
		end
	end


	
	assign oREQ_BUSY = uart_mod_full;
	assign oREQ_VALID = b_ack_buffer_ack;
	assign oREQ_DATA = b_ack_buffer_data;
	assign oIRQ_VALID = (b_irq_state == IRQ_STT_IRQ);
	assign oIRQ_NUM = 6'h00;
	
endmodule
			
`default_nettype wire

