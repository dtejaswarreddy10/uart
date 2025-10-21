/*

*/

module uart_loop_back #(parameter DATA_WIDTH = 8,SAMPLING = 16,CLK_FREQUENCY =100000000 ,BAUD_RATE = 9600)(
        input clk,reset,
        input valid_in,mode,
	input [1:0] parity,stop,
        input [DATA_WIDTH-1:0] p_data_in,
        output ready,
        output valid_out,
        output [DATA_WIDTH-1:0]p_data_out,
        output parity_error,stop_error
        );

	wire s_data_out ; 
	
	uart_tx #(
    .DATA_WIDTH(DATA_WIDTH),
    .SAMPLING(SAMPLING)
  ) dut_tx (
    .clk(clk),
    .reset(reset),
    .bclk(bclk),
    .ready(ready),
    .valid(valid_in),
    .mode(mode),
    .parity_select(parity),
    .stop_select(stop),
    .p_data_in(p_data_in),
    .s_data_out(s_data_out)
  );


uart_rx #(.DATA_WIDTH(DATA_WIDTH),.SAMPLING(SAMPLING)) dut_rx (
	.s_data_in(s_data_out),
	.parity(parity),
	.clk(clk),
	.reset(reset),
	.bclk(bclk),
	.mode(mode),
	.p_data_out(p_data_out),
	.valid(valid_out),
	.parity_error(parity_error),
	.stop_error(stop_error));

	baud_generator #(.SAMPLING(SAMPLING),.CLK_FREQUENCY(CLK_FREQUENCY),.BAUD_RATE(BAUD_RATE)) badu_gen_instance (.clk(clk),.reset(reset),.bclk(bclk));	

endmodule

