/*

*/



module uart_rx #(parameter DATA_WIDTH = 8, SAMPLING =16)(
	input s_data_in,
	input [1:0] parity,
	input clk,reset,bclk,
	input mode,
	output [DATA_WIDTH-1:0]p_data_out,
	output   valid,
	output   parity_error,stop_error);

	rx_control #(.DATA_WIDTH(DATA_WIDTH),.SAMPLING(SAMPLING)) rx_cont_instance (.s_data_in(s_data_in),.data_valid(valid),.p_data_out(p_data_out),.clk(clk),.reset(reset),.bclk(bclk),.parity(parity),.parity_error(parity_error),.stop_error(stop_error));

endmodule
