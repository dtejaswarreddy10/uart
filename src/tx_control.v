/*
This Module controls converts the parallel data into serial
*/

module tx_control #(parameter DATA_WIDTH = 8,SAMPLING =16)(
	input clk,reset,
	input [1:0]parity,stop,
	input start,busy,
	input [DATA_WIDTH-1:0] p_data_in,
	output s_data_out);


endmodule
