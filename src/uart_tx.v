/*

*/


module uart_tx #(parameter DATA_WIDTH = 8,SAMPLING = 16)(
	input clk,reset,
//	input bclk,
	input ready,valid,
//	input mode,
	input [1:0]parity_select,stop_select,
	input [DATA_WIDTH-1:0] p_data_in,
	output s_data_out,
	output temp_busy);

	wire bclk;

	tx_control control_instance (.clk(clk),.reset(reset),.bclk(bclk),.parity(parity_select),.stop(stop_select),.start(valid),.busy(temp_busy),.p_data_in(p_data_in),.s_data_out(s_data_out));

	baud_generator badu_gen_instance(.clk(clk),.reset(reset),.bclk(bclk));


endmodule
