/*

*/


module uart_tranceiver#(parameter DATA_WIDTH = 8,SAMPLING = 16,CLK_FREQUENCY =100000000 ,BAUD_RATE = 9600)(
	input clk,reset,
	input valid_in,mode,
	input [DATA_WIDTH-1:0] p_data_in,
	output ready,
	output s_data_out,
	input s_data_in,
	output valid_out,
	output [DATA_WIDTH-1:0]p_data_out,
	output parity_error,stop_error
	);


endmodule
