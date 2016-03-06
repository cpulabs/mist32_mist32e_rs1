`default_nettype none


module uart(
		//Clock
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//Transmit
		input wire iTX_EN,
		input wire iTX_REQ,
		output wire oTX_BUSY,
		input wire [7:0] iTX_DATA,
		output wire [3:0] oTX_BUFF_CNT,
		output wire oTX_TRANSMIT,
		//Receive
		input wire iRX_EN,
		input wire iRX_REQ,
		output wire oRX_EMPTY,
		output wire [7:0] oRX_DATA,
		output wire [3:0] oRX_BUFF_CNT,
		output wire oRX_RECEIVE,
		//IRQ
		output wire oIRQ_VALID,
		//UART
		output wire oUART_TXD,
		input wire iUART_RXD
	);
	
	
	/*********************************************
	* Uart FIFO
	*********************************************/
	wire transmitter_tx_enable;
	wire transmitter_tx_busy;
	wire [7:0] transmitter_tx_data;
	
	wire receiver_rx_enable;
	wire receiver_rx_busy;
	wire [7:0] receiver_rx_data;

	//Txd Buffer
	uart_sync_fifo #(8, 16, 4) TX_FIFO(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iREMOVE(iRESET_SYNC),
		.oCOUNT(oTX_BUFF_CNT),
		//WR
		.iWR_EN(iTX_EN && iTX_REQ),
		.iWR_DATA(iTX_DATA),
		.oWR_FULL(oTX_BUSY),
		//RD
		.iRD_EN(!transmitter_tx_enable && !transmitter_tx_busy),
		.oRD_DATA(transmitter_tx_data),
		.oRD_EMPTY(transmitter_tx_enable)
	);

	
	//Rxd Buffer
	uart_sync_fifo #(8, 16, 4) RX_FIFO(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iREMOVE(iRESET_SYNC),
		.oCOUNT(oRX_BUFF_CNT),
		//WR
		.iWR_EN(receiver_rx_enable && !receiver_rx_busy),
		.iWR_DATA(receiver_rx_data),
		.oWR_FULL(receiver_rx_busy),
		//RD
		.iRD_EN(iRX_EN && iRX_REQ),
		.oRD_DATA(oRX_DATA),
		.oRD_EMPTY(oRX_EMPTY)
	);
	
	
	/*********************************************
	* Uart Transmitter
	*********************************************/
	//19'd108;		//115200
	uart_transmitter #(20'd108) UART_TRANSMITTER(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//Request
		.iTX_REQ(!transmitter_tx_enable && !transmitter_tx_busy),
		.oTX_BUSY(transmitter_tx_busy),
		.iTX_DATA(transmitter_tx_data),
		//UART
		.oUART_TXD(oUART_TXD)
	);
	
	/*********************************************
	* Uart Receiver
	*********************************************/
	//19'd108;		//115200
	uart_receiver #(20'd108) UART_RECEIVER(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//R Data	
		.oRX_VALID(receiver_rx_enable),
		.oRX_DATA(receiver_rx_data),
		//UART
		.iUART_RXD(iUART_RXD)
	);
	
	/*********************************************
	* Assign
	*********************************************/
	assign oTX_TRANSMIT = !transmitter_tx_enable && !transmitter_tx_busy;
	assign oRX_RECEIVE = receiver_rx_enable;

	
endmodule


`default_nettype wire

	
