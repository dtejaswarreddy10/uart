/*
This module converts the serial data into parallel data 

*/


module rx_control #(parameter DATA_WIDTH = 8,SAMPLING = 16)(
	input s_data_in,
	out data_valid,
	output [DATA_WIDTH-1:0] p_data_out,
	input clk,reset,bclk,
	input [1:0] parity,
	output parity_error,stop_error);


endmodule
