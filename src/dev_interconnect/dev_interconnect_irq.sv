`default_nettype none


module dev_interconnect_irq #(
		//Device IRQ
		parameter PL_DEV0_IRQ_PRIORITY = 4'h0,
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
		//IRQ Controll Register
		input wire iIRQ_CTRL_REQ,
		input wire [4:0] iIRQ_CTRL_ENTRY,
		input wire iIRQ_CTRL_INFO_MASK,
		input wire iIRQ_CTRL_INFO_VALID,
		input wire [1:0] iIRQ_CTRL_INFO_MODE,
		//IRQ
		input wire iDEV0_IRQ,			//IRQ Req Enable
		output wire oDEV0_ACK,			
		input wire iDEV1_IRQ,
		output wire oDEV1_ACK,			
		input wire iDEV2_IRQ,
		output wire oDEV2_ACK,			
		input wire iDEV3_IRQ,
		output wire oDEV3_ACK,
		input wire iDEV4_IRQ,
		output wire oDEV4_ACK,			
		input wire iDEV5_IRQ,
		output wire oDEV5_ACK,			
		input wire iDEV6_IRQ,
		output wire oDEV6_ACK,			
		input wire iDEV7_IRQ,
		output wire oDEV7_ACK,			
		//IRQ Out
		output wire oIRQ_VALID,
		output wire [5:0] oIRQ_NUM,
		input wire iIRQ_ACK
	);
				
				
	localparam L_PARAM_IRQ_STT_IDLE = 1'b0;
	localparam L_PARAM_IRQ_STT_ACK_WAIT = 1'b1;	

	/*******************************************************
	Register & Wire
	*******************************************************/
	//Generate
	integer i;
	//Interrupt Infomation Memory
	reg b_ctrl_mem_mask[0:31];
	reg b_ctrl_mem_valid[0:31];
	//IRQ State
	reg b_irq_state;
	reg [5:0] b_irq_num;
	//IRQ State
	logic [6:0] irq_select_func_out;


	
	/*******************************************************
	Interrupt Infomation Memory
	*******************************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			for(i = 0; i < 32; i = i + 1)begin
				b_ctrl_mem_valid [i] <= 1'b0;
				b_ctrl_mem_mask [i] <= 1'b0;
			end
		end
		else if(iRESET_SYNC)begin
			for(i = 0; i < 32; i = i + 1)begin
				b_ctrl_mem_valid [i] <= 1'b0;
				b_ctrl_mem_mask [i] <= 1'b0;
			end
		end
		else begin 
			if(iIRQ_CTRL_REQ)begin	
				b_ctrl_mem_mask [iIRQ_CTRL_ENTRY] <= iIRQ_CTRL_INFO_MASK;
				b_ctrl_mem_valid [iIRQ_CTRL_ENTRY] <= iIRQ_CTRL_INFO_VALID;
			end
		end
	end

	
	/*******************************************************
	IRQ Port Arbiter
	*******************************************************/
	//assign irq_select_func_out = func_select_irq_source(

	wire irq_select_a_valid; 
	wire [3:0] irq_select_a_priority; 
	wire [5:0] irq_select_a_num;
	assign {irq_select_a_valid, irq_select_a_priority, irq_select_a_num} = func_select_irq_source(
		PL_DEV0_IRQ_PRIORITY,
		PL_DEV1_IRQ_PRIORITY,
		PL_DEV2_IRQ_PRIORITY,
		PL_DEV3_IRQ_PRIORITY,
		iDEV0_IRQ && (!b_ctrl_mem_valid[0] || (b_ctrl_mem_valid[0] && b_ctrl_mem_mask[0])),
		iDEV1_IRQ && (!b_ctrl_mem_valid[1] || (b_ctrl_mem_valid[1] && b_ctrl_mem_mask[1])),
		iDEV2_IRQ && (!b_ctrl_mem_valid[2] || (b_ctrl_mem_valid[2] && b_ctrl_mem_mask[2])),
		iDEV3_IRQ && (!b_ctrl_mem_valid[3] || (b_ctrl_mem_valid[3] && b_ctrl_mem_mask[3]))
	);

	wire irq_select_b_valid; 
	wire [3:0] irq_select_b_priority; 
	wire [5:0] irq_select_b_num;
	assign {irq_select_b_valid, irq_select_b_priority, irq_select_b_num} = func_select_irq_source(
		PL_DEV4_IRQ_PRIORITY,
		PL_DEV5_IRQ_PRIORITY,
		PL_DEV6_IRQ_PRIORITY,
		PL_DEV7_IRQ_PRIORITY,
		iDEV4_IRQ && (!b_ctrl_mem_valid[4] || (b_ctrl_mem_valid[4] && b_ctrl_mem_mask[4])),
		iDEV5_IRQ && (!b_ctrl_mem_valid[5] || (b_ctrl_mem_valid[5] && b_ctrl_mem_mask[5])),
		iDEV6_IRQ && (!b_ctrl_mem_valid[6] || (b_ctrl_mem_valid[6] && b_ctrl_mem_mask[6])),
		iDEV7_IRQ && (!b_ctrl_mem_valid[7] || (b_ctrl_mem_valid[7] && b_ctrl_mem_mask[7]))
	);


	always@* begin
		if(irq_select_a_valid && irq_select_b_valid)begin
			if(irq_select_a_priority >= irq_select_b_priority)begin
				irq_select_func_out <= {1'b1, irq_select_a_num};
			end
			else begin
				irq_select_func_out <= {1'b1, irq_select_b_num};
			end
		end
		else if(irq_select_a_valid)begin
			irq_select_func_out <= {1'b1, irq_select_a_num};
		end
		else if(irq_select_b_valid)begin
			irq_select_func_out <= {1'b1, irq_select_a_num};
		end
		else begin
			irq_select_func_out <= {1'b0, 6'h0};
		end
	end


	
	/*******************************************************
	IRQ State
	*******************************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_irq_state <= L_PARAM_IRQ_STT_IDLE;
			b_irq_num <= 6'h0;
		end
		else if(iRESET_SYNC)begin
			b_irq_state <= L_PARAM_IRQ_STT_IDLE;
			b_irq_num <= 6'h0;
		end
		else begin
			case(b_irq_state)
				L_PARAM_IRQ_STT_IDLE:
					begin
						b_irq_num <= irq_select_func_out[5:0];
						if(irq_select_func_out[6])begin
							b_irq_state <= L_PARAM_IRQ_STT_ACK_WAIT;
						end
					end
				L_PARAM_IRQ_STT_ACK_WAIT:
					begin
						if(iIRQ_ACK)begin
							b_irq_state <= L_PARAM_IRQ_STT_IDLE;
						end
					end
			endcase
		end
	end
											
	

	//[10]Irq Request, [9:6]Priority [5:0]Irq Number
	function [10:0] func_select_irq_source;
		input [3:0] func_node1_info_priority;
		input [3:0] func_node2_info_priority;
		input [3:0] func_node3_info_priority;
		input [3:0] func_node4_info_priority;
		input func_node1_irq;
		input func_node2_irq;
		input func_node3_irq;
		input func_node4_irq;
		begin
			if(func_node1_irq & 
			(!func_node2_irq || func_node2_irq & (func_node1_info_priority > func_node2_info_priority)) & 
			(!func_node3_irq || func_node3_irq & (func_node1_info_priority > func_node3_info_priority)) & 
			(!func_node4_irq || func_node4_irq & (func_node1_info_priority > func_node4_info_priority)))begin
				func_select_irq_source = {1'b1, func_node1_info_priority, 6'h0};
			end
			else if(func_node2_irq & 
			(!func_node1_irq || func_node1_irq & (func_node2_info_priority > func_node1_info_priority)) & 
			(!func_node3_irq || func_node3_irq & (func_node2_info_priority > func_node3_info_priority)) & 
			(!func_node4_irq || func_node4_irq & (func_node2_info_priority > func_node4_info_priority)))begin
				func_select_irq_source = {1'b1, func_node2_info_priority, 6'h1};
			end
			else if(func_node3_irq & 
			(!func_node1_irq || func_node1_irq & (func_node3_info_priority > func_node1_info_priority)) & 
			(!func_node2_irq || func_node2_irq & (func_node3_info_priority > func_node2_info_priority)) & 
			(!func_node4_irq || func_node4_irq & (func_node3_info_priority > func_node4_info_priority)))begin
				func_select_irq_source = {1'b1, func_node3_info_priority, 6'h2};
			end
			else if(func_node4_irq & 
			(!func_node1_irq || func_node1_irq & (func_node4_info_priority > func_node1_info_priority)) & 
			(!func_node2_irq || func_node2_irq & (func_node4_info_priority > func_node2_info_priority)) & 
			(!func_node3_irq || func_node3_irq & (func_node4_info_priority > func_node3_info_priority)))begin
				func_select_irq_source = {1'b1, func_node4_info_priority, 6'h3};
			end
			else begin
				func_select_irq_source = 11'h0;
			end			
		end
	endfunction
	

	assign oIRQ_VALID = (b_irq_state == L_PARAM_IRQ_STT_ACK_WAIT);
	assign oIRQ_NUM = b_irq_num;
	
	reg b_ack_dev0;
	reg b_ack_dev1;
	reg b_ack_dev2;
	reg b_ack_dev3;
	reg b_ack_dev4;
	reg b_ack_dev5;
	reg b_ack_dev6;
	reg b_ack_dev7;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_ack_dev0 <= 1'b0;
			b_ack_dev1 <= 1'b0;
			b_ack_dev2 <= 1'b0;
			b_ack_dev3 <= 1'b0;
			b_ack_dev4 <= 1'b0;
			b_ack_dev5 <= 1'b0;
			b_ack_dev6 <= 1'b0;
			b_ack_dev7 <= 1'b0;
		end
		else if(iRESET_SYNC)begin
			b_ack_dev0 <= 1'b0;
			b_ack_dev1 <= 1'b0;
			b_ack_dev2 <= 1'b0;
			b_ack_dev3 <= 1'b0;
			b_ack_dev4 <= 1'b0;
			b_ack_dev5 <= 1'b0;
			b_ack_dev6 <= 1'b0;
			b_ack_dev7 <= 1'b0;
		end
		else begin
			b_ack_dev0 <= (b_irq_state == L_PARAM_IRQ_STT_IDLE)? (irq_select_func_out[5:0] == 5'h0) && irq_select_func_out[6] : 1'b0;
			b_ack_dev1 <= (b_irq_state == L_PARAM_IRQ_STT_IDLE)? (irq_select_func_out[5:0] == 5'h1) && irq_select_func_out[6] : 1'b0;
			b_ack_dev2 <= (b_irq_state == L_PARAM_IRQ_STT_IDLE)? (irq_select_func_out[5:0] == 5'h2) && irq_select_func_out[6] : 1'b0;
			b_ack_dev3 <= (b_irq_state == L_PARAM_IRQ_STT_IDLE)? (irq_select_func_out[5:0] == 5'h3) && irq_select_func_out[6] : 1'b0;
			b_ack_dev4 <= (b_irq_state == L_PARAM_IRQ_STT_IDLE)? (irq_select_func_out[5:0] == 5'h4) && irq_select_func_out[6] : 1'b0;
			b_ack_dev5 <= (b_irq_state == L_PARAM_IRQ_STT_IDLE)? (irq_select_func_out[5:0] == 5'h5) && irq_select_func_out[6] : 1'b0;
			b_ack_dev6 <= (b_irq_state == L_PARAM_IRQ_STT_IDLE)? (irq_select_func_out[5:0] == 5'h6) && irq_select_func_out[6] : 1'b0;
			b_ack_dev7 <= (b_irq_state == L_PARAM_IRQ_STT_IDLE)? (irq_select_func_out[5:0] == 5'h7) && irq_select_func_out[6] : 1'b0;
		end
	end
	
	/*
	assign oDEV0_ACK = (b_irq_state == L_PARAM_IRQ_STT_IDLE)? (irq_select_func_out[5:0] == 5'h0) && irq_select_func_out[6] : 1'b0;
	assign oDEV1_ACK = (b_irq_state == L_PARAM_IRQ_STT_IDLE)? (irq_select_func_out[5:0] == 5'h1) && irq_select_func_out[6] : 1'b0;
	assign oDEV2_ACK = (b_irq_state == L_PARAM_IRQ_STT_IDLE)? (irq_select_func_out[5:0] == 5'h2) && irq_select_func_out[6] : 1'b0;
	assign oDEV3_ACK = (b_irq_state == L_PARAM_IRQ_STT_IDLE)? (irq_select_func_out[5:0] == 5'h3) && irq_select_func_out[6] : 1'b0;
	*/
	
	assign oDEV0_ACK = b_ack_dev0;
	assign oDEV1_ACK = b_ack_dev1;
	assign oDEV2_ACK = b_ack_dev2;
	assign oDEV3_ACK = b_ack_dev3;
	assign oDEV4_ACK = b_ack_dev4;
	assign oDEV5_ACK = b_ack_dev5;
	assign oDEV6_ACK = b_ack_dev6;
	assign oDEV7_ACK = b_ack_dev7;

		
endmodule


`default_nettype wire
					