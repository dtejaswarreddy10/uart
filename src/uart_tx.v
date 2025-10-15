/*

*/


module uart_tx #(parameter DATA_WIDTH = 8,SAMPLING = 16)(
	input clk,reset,bclk,
	input ready,valid,mode,
	input [DATA_WIDTH-1:0] p_data_in,
	output s_data_out);


endmodule
