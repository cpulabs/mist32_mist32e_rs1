/*******************************************************
PS2 Keyboard Controller

	- Memory MAP
		32'h00000000(000)	: Key Scancode Output ([8]Valid bit  [7:0]Key Scan code)
*******************************************************/



`default_nettype none



module keyboard(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//BUS(DATA)-Input
		input wire iDEV_REQ,
		output wire oDEV_BUSY,
		input wire iDEV_RW,
		input wire [31:0] iDEV_ADDR,
		input wire [31:0] iDEV_DATA,
		//BUS(DATA)-Output
		output wire oDEV_REQ,
		input wire iDEV_BUSY,
		output wire [31:0] oDEV_DATA,
		//IRQ
		output wire oDEV_IRQ_REQ,
		input wire iDEV_IRQ_BUSY,
		input wire iDEV_IRQ_ACK,
		//PS2
		input wire iPS2_CLOCK,
		input wire iPS2_DATA
	);

	localparam PL_INTFLAG_ADDR =  32'h00000004;

	/************************************************************
	Wire & Register
	************************************************************/
	//Data Output Buffer
	reg b_req;
	reg [31:0] b_data;
	//PS2 Interface
	wire ps2_if_req;
	wire [7:0] ps2_if_data;
	//Write Condition
	wire specialmemory_use_condition;
	wire queue_write_condition;
	wire data_rd_condition;
	wire irq_rd_condition;
	//Special Memory
	wire [31:0] special_memory_rd_data;
	//Keyboard Queue
	wire data_fifo_full;
	wire data_fifo_empty;
	wire [7:0] data_fifo_data;
	//IRQ Buffer
	wire irq_counter_full;
	wire irq_counter_empty;

	/************************************************************
	PS2 Interface
	************************************************************/
	keyboard_ps2_receiver PS2_IF_KEYBOARD(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//Receive
		.oPS2MOD_REQ(ps2_if_req),
		.oPS2MOD_DATA(ps2_if_data),
		//PS2
		.iPS2_CLOCK(iPS2_CLOCK),
		.iPS2_DATA(iPS2_DATA)
	);

	/************************************************************
	Condition CTRL
	************************************************************/
	assign queue_write_condition = ps2_if_req && !data_fifo_full;
	assign data_rd_condition = (iDEV_REQ && iDEV_ADDR == 32'h00000000);
	assign irq_rd_condition = !irq_counter_empty && !iDEV_IRQ_BUSY;


	/************************************************************
	Data Queue
	************************************************************/
	wire [4:0] fifo_counter;
	keyboard_sync_fifo #(8, 32, 5) KEYBOARD_DATA_FIFO(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iREMOVE(iRESET_SYNC),
		.oCOUNT(fifo_counter),
		.iWR_EN(queue_write_condition),
		.iWR_DATA(ps2_if_data),
		.oWR_FULL(data_fifo_full),
		.iRD_EN(data_rd_condition && !data_fifo_empty),
		.oRD_DATA(data_fifo_data),
		.oRD_EMPTY(data_fifo_empty)
	);

	/************************************************************
	IRQ (Counter)
	************************************************************/
	reg b_irq_state;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_irq_state <= 1'b0;
		end
		else if(iRESET_SYNC)begin
			b_irq_state <= 1'b0;
		end
		else begin
			case(b_irq_state)
				1'b0:
					begin
						if(queue_write_condition)begin
							b_irq_state <= 1'b1;
						end
					end
				1'b1:
					begin
						if(iDEV_REQ && !iDEV_RW && iDEV_ADDR == PL_INTFLAG_ADDR)begin
							b_irq_state <= 1'b0;
						end
					end
			endcase
		end
	end



	//Data Output Buffer
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_req <= 1'b0;
			b_data <= {32{1'b0}};
		end
		else if(iRESET_SYNC)begin
			b_req <= 1'b0;
			b_data <= {32{1'b0}};
		end
		else begin
			b_req <= (iDEV_REQ && !iDEV_RW && iDEV_ADDR == PL_INTFLAG_ADDR) || data_rd_condition;
			b_data <= (iDEV_REQ && !iDEV_RW && iDEV_ADDR == PL_INTFLAG_ADDR)? {27'h0, fifo_counter} : ((!data_fifo_empty)? {{23{1'b0}}, 1'b1, data_fifo_data} : {32{1'b0}});
		end
	end


	/************************************************************
	Assign
	************************************************************/
	assign oDEV_BUSY = iDEV_BUSY;
	assign oDEV_REQ = b_req;
	assign oDEV_DATA = b_data;
	assign oDEV_IRQ_REQ = !iDEV_IRQ_BUSY && b_irq_state;

endmodule


`default_nettype wire
