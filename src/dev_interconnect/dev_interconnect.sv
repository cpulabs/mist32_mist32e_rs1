`default_nettype none



module dev_interconnect #(
		//Device Address
		parameter PL_DEV0_INDEX = 32'h0,	//Byte
		parameter PL_DEV0_SIZE = 32'h8,		//Byte
		parameter PL_DEV1_INDEX = 32'h100,	
		parameter PL_DEV1_SIZE = 32'h100,
		parameter PL_DEV2_INDEX = 32'h200,	
		parameter PL_DEV2_SIZE = 32'h100,
		parameter PL_DEV3_INDEX = 32'h300,	
		parameter PL_DEV3_SIZE = 32'h100,
		parameter PL_DEV4_INDEX = 32'h300,	
		parameter PL_DEV4_SIZE = 32'h100,
		parameter PL_DEV5_INDEX = 32'h300,	
		parameter PL_DEV5_SIZE = 32'h100,
		parameter PL_DEV6_INDEX = 32'h300,	
		parameter PL_DEV6_SIZE = 32'h100,
		parameter PL_DEV7_INDEX = 32'h300,	
		parameter PL_DEV7_SIZE = 32'h100,
		//Device IRQ
		parameter PL_DEV0_IRQ_PRIORITY = 4'hf,
		parameter PL_DEV1_IRQ_PRIORITY = 4'h0,
		parameter PL_DEV2_IRQ_PRIORITY = 4'h0,
		parameter PL_DEV3_IRQ_PRIORITY = 4'h0,
		parameter PL_DEV4_IRQ_PRIORITY = 4'h0,
		parameter PL_DEV5_IRQ_PRIORITY = 4'h0,
		parameter PL_DEV6_IRQ_PRIORITY = 4'h0,
		parameter PL_DEV7_IRQ_PRIORITY = 4'h0
	)(
		//System
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		/*********************************************
		Configlation Table
		*********************************************/
		input wire iIRQ_CTRL_REQ,
		input wire [5:0] iIRQ_CTRL_ENTRY,
		input wire iIRQ_CTRL_INFO_MASK,
		input wire iIRQ_CTRL_INFO_VALID,
		input wire [1:0] iIRQ_CTRL_INFO_MODE,
		/*********************************************
		From Core
		*********************************************/
		input wire iCORE_REQ,		
		output wire oCORE_BUSY,
		input wire iCORE_RW,
		input wire [31:0] iCORE_ADDR,
		input wire [31:0] iCORE_DATA,
		//BUS(DATA)-Output
		output wire oCORE_REQ,		
		input wire iCORE_BUSY,
		output wire [31:0] oCORE_DATA,	
		//IRQ Out
		output wire oIRQ_VALID,
		output wire [5:0] oIRQ_NUM,
		input wire iIRQ_ACK,
		/*********************************************
		To Device-0
		*********************************************/
		//BUS(DATA)-Input
		output wire oDEV0_REQ,		
		input wire iDEV0_BUSY,
		output wire oDEV0_RW,
		output wire [31:0] oDEV0_ADDR,
		output wire [31:0] oDEV0_DATA,
		//BUS(DATA)-Output
		input wire iDEV0_REQ,		
		output wire oDEV0_BUSY,
		input wire [31:0] iDEV0_DATA,
		//IRQ
		input wire iDEV0_IRQ,	
		output wire oDEV0_ACK,	
		/*********************************************
		To Device-1
		*********************************************/
		//BUS(DATA)-Input
		output wire oDEV1_REQ,		
		input wire iDEV1_BUSY,
		output wire oDEV1_RW,
		output wire [31:0] oDEV1_ADDR,
		output wire [31:0] oDEV1_DATA,
		//BUS(DATA)-Output
		input wire iDEV1_REQ,		
		output wire oDEV1_BUSY,
		input wire [31:0] iDEV1_DATA,
		//IRQ
		input wire iDEV1_IRQ,	
		output wire oDEV1_ACK,	
		/*********************************************
		To Device-2
		*********************************************/
		//BUS(DATA)-Input
		output wire oDEV2_REQ,		
		input wire iDEV2_BUSY,
		output wire oDEV2_RW,
		output wire [31:0] oDEV2_ADDR,
		output wire [31:0] oDEV2_DATA,
		//BUS(DATA)-Output
		input wire iDEV2_REQ,		
		output wire oDEV2_BUSY,
		input wire [31:0] iDEV2_DATA,
		//IRQ
		input wire iDEV2_IRQ,	
		output wire oDEV2_ACK,	
		/*********************************************
		To Device-3
		*********************************************/
		//BUS(DATA)-Input
		output wire oDEV3_REQ,		
		input wire iDEV3_BUSY,
		output wire oDEV3_RW,
		output wire [31:0] oDEV3_ADDR,
		output wire [31:0] oDEV3_DATA,
		//BUS(DATA)-Output
		input wire iDEV3_REQ,		
		output wire oDEV3_BUSY,
		input wire [31:0] iDEV3_DATA,
		//IRQ
		input wire iDEV3_IRQ,	
		output wire oDEV3_ACK,
		/*********************************************
		To Device-4
		*********************************************/
		//BUS(DATA)-Input
		output wire oDEV4_REQ,		
		input wire iDEV4_BUSY,
		output wire oDEV4_RW,
		output wire [31:0] oDEV4_ADDR,
		output wire [31:0] oDEV4_DATA,
		//BUS(DATA)-Output
		input wire iDEV4_REQ,		
		output wire oDEV4_BUSY,
		input wire [31:0] iDEV4_DATA,
		//IRQ
		input wire iDEV4_IRQ,	
		output wire oDEV4_ACK,
		/*********************************************
		To Device-5
		*********************************************/
		//BUS(DATA)-Input
		output wire oDEV5_REQ,		
		input wire iDEV5_BUSY,
		output wire oDEV5_RW,
		output wire [31:0] oDEV5_ADDR,
		output wire [31:0] oDEV5_DATA,
		//BUS(DATA)-Output
		input wire iDEV5_REQ,		
		output wire oDEV5_BUSY,
		input wire [31:0] iDEV5_DATA,
		//IRQ
		input wire iDEV5_IRQ,	
		output wire oDEV5_ACK,
		/*********************************************
		To Device-6
		*********************************************/
		//BUS(DATA)-Input
		output wire oDEV6_REQ,		
		input wire iDEV6_BUSY,
		output wire oDEV6_RW,
		output wire [31:0] oDEV6_ADDR,
		output wire [31:0] oDEV6_DATA,
		//BUS(DATA)-Output
		input wire iDEV6_REQ,		
		output wire oDEV6_BUSY,
		input wire [31:0] iDEV6_DATA,
		//IRQ
		input wire iDEV6_IRQ,	
		output wire oDEV6_ACK,
		/*********************************************
		To Device-7
		*********************************************/
		//BUS(DATA)-Input
		output wire oDEV7_REQ,		
		input wire iDEV7_BUSY,
		output wire oDEV7_RW,
		output wire [31:0] oDEV7_ADDR,
		output wire [31:0] oDEV7_DATA,
		//BUS(DATA)-Output
		input wire iDEV7_REQ,		
		output wire oDEV7_BUSY,
		input wire [31:0] iDEV7_DATA,
		//IRQ
		input wire iDEV7_IRQ,	
		output wire oDEV7_ACK
	);

	wire device_busy = iDEV0_BUSY || iDEV1_BUSY || iDEV2_BUSY || iDEV3_BUSY || iDEV4_BUSY || iDEV5_BUSY || iDEV6_BUSY || iDEV7_BUSY;


	/**********************************************************************************
	Device Select
	**********************************************************************************/
	logic local_req_dev0_valid;
	logic local_req_dev1_valid;
	logic local_req_dev2_valid;
	logic local_req_dev3_valid;
	logic local_req_dev4_valid;
	logic local_req_dev5_valid;
	logic local_req_dev6_valid;
	logic local_req_dev7_valid;
	logic [31:0] local_req_addr;

	always_comb begin
		if(!device_busy && iCORE_REQ)begin
			if(iCORE_ADDR >= PL_DEV0_INDEX && iCORE_ADDR < (PL_DEV0_INDEX + PL_DEV0_SIZE))begin
				local_req_dev0_valid <= 1'h1;
				local_req_dev1_valid <= 1'h0;
				local_req_dev2_valid <= 1'h0;
				local_req_dev3_valid <= 1'h0;
				local_req_dev4_valid <= 1'h0;
				local_req_dev5_valid <= 1'h0;
				local_req_dev6_valid <= 1'h0;
				local_req_dev7_valid <= 1'h0;
				local_req_addr <= iCORE_ADDR;
			end
			else if(iCORE_ADDR >= PL_DEV1_INDEX && iCORE_ADDR < (PL_DEV1_INDEX + PL_DEV1_SIZE))begin
				local_req_dev0_valid <= 1'h0;
				local_req_dev1_valid <= 1'h1;
				local_req_dev2_valid <= 1'h0;
				local_req_dev3_valid <= 1'h0;
				local_req_dev4_valid <= 1'h0;
				local_req_dev5_valid <= 1'h0;
				local_req_dev6_valid <= 1'h0;
				local_req_dev7_valid <= 1'h0;
				local_req_addr <= iCORE_ADDR - PL_DEV1_INDEX;
			end
			else if(iCORE_ADDR >= PL_DEV2_INDEX && iCORE_ADDR < (PL_DEV2_INDEX + PL_DEV2_SIZE))begin
				local_req_dev0_valid <= 1'h0;
				local_req_dev1_valid <= 1'h0;
				local_req_dev2_valid <= 1'h1;
				local_req_dev3_valid <= 1'h0;
				local_req_dev4_valid <= 1'h0;
				local_req_dev5_valid <= 1'h0;
				local_req_dev6_valid <= 1'h0;
				local_req_dev7_valid <= 1'h0;
				local_req_addr <= iCORE_ADDR - PL_DEV2_INDEX;
			end
			else if(iCORE_ADDR >= PL_DEV3_INDEX && iCORE_ADDR < (PL_DEV3_INDEX + PL_DEV3_SIZE))begin
				local_req_dev0_valid <= 1'h0;
				local_req_dev1_valid <= 1'h0;
				local_req_dev2_valid <= 1'h0;
				local_req_dev3_valid <= 1'h1;
				local_req_dev4_valid <= 1'h0;
				local_req_dev5_valid <= 1'h0;
				local_req_dev6_valid <= 1'h0;
				local_req_dev7_valid <= 1'h0;
				local_req_addr <= iCORE_ADDR - PL_DEV3_INDEX;
			end
			else if(iCORE_ADDR >= PL_DEV4_INDEX && iCORE_ADDR < (PL_DEV4_INDEX + PL_DEV4_SIZE))begin
				local_req_dev0_valid <= 1'h0;
				local_req_dev1_valid <= 1'h0;
				local_req_dev2_valid <= 1'h0;
				local_req_dev3_valid <= 1'h0;
				local_req_dev4_valid <= 1'h1;
				local_req_dev5_valid <= 1'h0;
				local_req_dev6_valid <= 1'h0;
				local_req_dev7_valid <= 1'h0;
				local_req_addr <= iCORE_ADDR - PL_DEV4_INDEX;
			end
			else if(iCORE_ADDR >= PL_DEV5_INDEX && iCORE_ADDR < (PL_DEV5_INDEX + PL_DEV5_SIZE))begin
				local_req_dev0_valid <= 1'h0;
				local_req_dev1_valid <= 1'h0;
				local_req_dev2_valid <= 1'h0;
				local_req_dev3_valid <= 1'h0;
				local_req_dev4_valid <= 1'h0;
				local_req_dev5_valid <= 1'h1;
				local_req_dev6_valid <= 1'h0;
				local_req_dev7_valid <= 1'h0;
				local_req_addr <= iCORE_ADDR - PL_DEV5_INDEX;
			end
			else if(iCORE_ADDR >= PL_DEV6_INDEX && iCORE_ADDR < (PL_DEV6_INDEX + PL_DEV6_SIZE))begin
				local_req_dev0_valid <= 1'h0;
				local_req_dev1_valid <= 1'h0;
				local_req_dev2_valid <= 1'h0;
				local_req_dev3_valid <= 1'h0;
				local_req_dev4_valid <= 1'h0;
				local_req_dev5_valid <= 1'h0;
				local_req_dev6_valid <= 1'h1;
				local_req_dev7_valid <= 1'h0;
				local_req_addr <= iCORE_ADDR - PL_DEV6_INDEX;
			end
			else if(iCORE_ADDR >= PL_DEV7_INDEX && iCORE_ADDR < (PL_DEV7_INDEX + PL_DEV7_SIZE))begin
				local_req_dev0_valid <= 1'h0;
				local_req_dev1_valid <= 1'h0;
				local_req_dev2_valid <= 1'h0;
				local_req_dev3_valid <= 1'h0;
				local_req_dev4_valid <= 1'h0;
				local_req_dev5_valid <= 1'h0;
				local_req_dev6_valid <= 1'h0;
				local_req_dev7_valid <= 1'h1;
				local_req_addr <= iCORE_ADDR - PL_DEV7_INDEX;
			end

			else begin
				local_req_dev0_valid <= 1'h0;
				local_req_dev1_valid <= 1'h0;
				local_req_dev2_valid <= 1'h0;
				local_req_dev3_valid <= 1'h0;
				local_req_dev4_valid <= 1'h0;
				local_req_dev5_valid <= 1'h0;
				local_req_dev6_valid <= 1'h0;
				local_req_dev7_valid <= 1'h0;
				local_req_addr <= 32'h0;
			end
		end
		else begin
			local_req_dev0_valid <= 1'h0;
			local_req_dev1_valid <= 1'h0;
			local_req_dev2_valid <= 1'h0;
			local_req_dev3_valid <= 1'h0;
			local_req_dev4_valid <= 1'h0;
			local_req_dev5_valid <= 1'h0;
			local_req_dev6_valid <= 1'h0;
			local_req_dev7_valid <= 1'h0;
			local_req_addr <= 32'h0;
		end
	end


	/**********************************************************************************
	For Device
	**********************************************************************************/
	reg b_req_dev0_valid;
	reg b_req_dev1_valid;
	reg b_req_dev2_valid;
	reg b_req_dev3_valid;
	reg b_req_dev4_valid;
	reg b_req_dev5_valid;
	reg b_req_dev6_valid;
	reg b_req_dev7_valid;
	reg b_req_rw;
	reg [31:0] b_req_local_addr;
	reg [31:0] b_req_data;

	always_ff@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_req_dev0_valid <= 1'b0;
			b_req_dev1_valid <= 1'b0;
			b_req_dev2_valid <= 1'b0;
			b_req_dev3_valid <= 1'b0;
			b_req_dev4_valid <= 1'b0;
			b_req_dev5_valid <= 1'b0;
			b_req_dev6_valid <= 1'b0;
			b_req_dev7_valid <= 1'b0;
			b_req_rw <= 1'b0;
			b_req_local_addr <= 32'h0;
			b_req_data <= 32'h0;
		end
		else if(iRESET_SYNC)begin
			b_req_dev0_valid <= 1'b0;
			b_req_dev1_valid <= 1'b0;
			b_req_dev2_valid <= 1'b0;
			b_req_dev3_valid <= 1'b0;
			b_req_dev4_valid <= 1'b0;
			b_req_dev5_valid <= 1'b0;
			b_req_dev6_valid <= 1'b0;
			b_req_dev7_valid <= 1'b0;
			b_req_rw <= 1'b0;
			b_req_local_addr <= 32'h0;
			b_req_data <= 32'h0;
		end
		else begin
			if(!device_busy)begin
				b_req_dev0_valid <= local_req_dev0_valid;
				b_req_dev1_valid <= local_req_dev1_valid;
				b_req_dev2_valid <= local_req_dev2_valid;
				b_req_dev3_valid <= local_req_dev3_valid;
				b_req_dev4_valid <= local_req_dev4_valid;
				b_req_dev5_valid <= local_req_dev5_valid;
				b_req_dev6_valid <= local_req_dev6_valid;
				b_req_dev7_valid <= local_req_dev7_valid;
				b_req_rw <= iCORE_RW;
				b_req_local_addr <= local_req_addr;
				b_req_data <= iCORE_DATA;
			end
		end
	end

	assign oDEV0_REQ = b_req_dev0_valid;
	assign oDEV0_RW = b_req_rw;
	assign oDEV0_ADDR = b_req_local_addr;
	assign oDEV0_DATA = b_req_data;
	assign oDEV0_BUSY = 1'b0;

	assign oDEV1_REQ = b_req_dev1_valid;
	assign oDEV1_RW = b_req_rw;
	assign oDEV1_ADDR = b_req_local_addr;
	assign oDEV1_DATA = b_req_data;
	assign oDEV1_BUSY = 1'b0;

	assign oDEV2_REQ = b_req_dev2_valid;
	assign oDEV2_RW = b_req_rw;
	assign oDEV2_ADDR = b_req_local_addr;
	assign oDEV2_DATA = b_req_data;
	assign oDEV2_BUSY = 1'b0;

	assign oDEV3_REQ = b_req_dev3_valid;
	assign oDEV3_RW = b_req_rw;
	assign oDEV3_ADDR = b_req_local_addr;
	assign oDEV3_DATA = b_req_data;
	assign oDEV3_BUSY = 1'b0;

	assign oDEV4_REQ = b_req_dev4_valid;
	assign oDEV4_RW = b_req_rw;
	assign oDEV4_ADDR = b_req_local_addr;
	assign oDEV4_DATA = b_req_data;
	assign oDEV4_BUSY = 1'b0;

	assign oDEV5_REQ = b_req_dev5_valid;
	assign oDEV5_RW = b_req_rw;
	assign oDEV5_ADDR = b_req_local_addr;
	assign oDEV5_DATA = b_req_data;
	assign oDEV5_BUSY = 1'b0;

	assign oDEV6_REQ = b_req_dev6_valid;
	assign oDEV6_RW = b_req_rw;
	assign oDEV6_ADDR = b_req_local_addr;
	assign oDEV6_DATA = b_req_data;
	assign oDEV6_BUSY = 1'b0;

	assign oDEV7_REQ = b_req_dev7_valid;
	assign oDEV7_RW = b_req_rw;
	assign oDEV7_ADDR = b_req_local_addr;
	assign oDEV7_DATA = b_req_data;
	assign oDEV7_BUSY = 1'b0;

	assign oCORE_BUSY = device_busy;


	/**********************************************************************************
	From Device
	**********************************************************************************/
	reg b_ack;
	reg [31:0] b_ack_data;

	always_ff@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_ack <= 1'h0;
		end
		else if(iRESET_SYNC)begin
			b_ack <= 1'h0;
		end
		else begin
			b_ack <= |{iDEV0_REQ, iDEV1_REQ, iDEV2_REQ, iDEV3_REQ, iDEV4_REQ, iDEV5_REQ, iDEV6_REQ, iDEV7_REQ};
		end
	end

	always_ff@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_ack_data <= 32'h0;
		end
		else if(iRESET_SYNC)begin
			b_ack_data <= 32'h0;
		end
		else begin
			if(iDEV0_REQ)begin
				b_ack_data <= iDEV0_DATA;
			end
			else if(iDEV1_REQ)begin
				b_ack_data <= iDEV1_DATA;
			end
			else if(iDEV2_REQ)begin
				b_ack_data <= iDEV2_DATA;
			end
			else if(iDEV3_REQ)begin
				b_ack_data <= iDEV3_DATA;
			end
			else if(iDEV4_REQ)begin
				b_ack_data <= iDEV4_DATA;
			end
			else if(iDEV5_REQ)begin
				b_ack_data <= iDEV5_DATA;
			end
			else if(iDEV6_REQ)begin
				b_ack_data <= iDEV6_DATA;
			end
			else if(iDEV7_REQ)begin
				b_ack_data <= iDEV7_DATA;
			end
		end
	end

	assign oCORE_REQ = b_ack;
	assign oCORE_DATA = b_ack_data;


	/**********************************************************************************
	IRQ
	**********************************************************************************/
	dev_interconnect_irq 
	#(
		PL_DEV0_IRQ_PRIORITY, PL_DEV1_IRQ_PRIORITY, PL_DEV2_IRQ_PRIORITY, PL_DEV3_IRQ_PRIORITY,
		PL_DEV4_IRQ_PRIORITY, PL_DEV5_IRQ_PRIORITY, PL_DEV6_IRQ_PRIORITY, PL_DEV7_IRQ_PRIORITY
	) 
	IRQ_CONTROL(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//IRQ Controll Register
		.iIRQ_CTRL_REQ(iIRQ_CTRL_REQ),
		.iIRQ_CTRL_ENTRY(iIRQ_CTRL_ENTRY),
		.iIRQ_CTRL_INFO_MASK(iIRQ_CTRL_INFO_MASK),
		.iIRQ_CTRL_INFO_VALID(iIRQ_CTRL_INFO_VALID),
		.iIRQ_CTRL_INFO_MODE(iIRQ_CTRL_INFO_MODE),
		//IRQ
		.iDEV0_IRQ(iDEV0_IRQ),			//IRQ Req Enable
		.oDEV0_ACK(oDEV0_ACK),			
		.iDEV1_IRQ(iDEV1_IRQ),
		.oDEV1_ACK(oDEV1_ACK),			
		.iDEV2_IRQ(iDEV2_IRQ),
		.oDEV2_ACK(oDEV2_ACK),			
		.iDEV3_IRQ(iDEV3_IRQ),
		.oDEV3_ACK(oDEV3_ACK),
		.iDEV4_IRQ(iDEV4_IRQ),
		.oDEV4_ACK(oDEV4_ACK),		
		.iDEV5_IRQ(iDEV5_IRQ),
		.oDEV5_ACK(oDEV5_ACK),		
		.iDEV6_IRQ(iDEV6_IRQ),
		.oDEV6_ACK(oDEV6_ACK),		
		.iDEV7_IRQ(iDEV7_IRQ),
		.oDEV7_ACK(oDEV7_ACK),	
		//IRQ Out
		.oIRQ_VALID(oIRQ_VALID),
		.oIRQ_NUM(oIRQ_NUM),
		.iIRQ_ACK(iIRQ_ACK)
	);

endmodule // interconnect

`default_nettype wire 

