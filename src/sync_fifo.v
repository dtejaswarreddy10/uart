/*

Synchronous fifo
*/

module sync_fifo #(Parameter DATA_WIDTH = 8, FIFO_DEPTH = 16)(
	input clk,reset,
	input write_enable,
	input[DATA_WIDTH-1:0] write_data,
	output full,
	input read_enabe,
	output [DATA_WIDTH-1:0]read_data,
	output empty);


endmodule
