/*

*/


module uart_tx #(parameter DATA_WIDTH = 8,SAMPLING = 16)(
	input clk,reset,
	input bclk,
	output reg ready,
	input valid,
	input mode,
	input [1:0]parity_select,stop_select,
	input [DATA_WIDTH-1:0] p_data_in,
	output s_data_out
	);


	reg fifo_wr_en;
	reg [DATA_WIDTH-1:0]fifo_wr_data;
	wire fifo_full,fifo_empty;
	wire [DATA_WIDTH-1:0]fifo_rd_data;
	reg fifo_rd_en;
	reg start_temp,ready_temp;
	reg [DATA_WIDTH-1:0]data_in_temp;
	reg tx_control_start;
	reg [DATA_WIDTH-1:0]tx_control_data_in;
	wire tx_control_busy;

	tx_control #(.DATA_WIDTH(DATA_WIDTH),.SAMPLING(SAMPLING)) control_instance (.clk(clk),.reset(reset),.bclk(bclk),.parity(parity_select),.stop(stop_select),.start(tx_control_start),.busy(tx_control_busy),.p_data_in(tx_control_data_in),.s_data_out(s_data_out));



	sync_fifo #(.DATA_WIDTH(DATA_WIDTH),.FIFO_DEPTH(16)
) tx_fifo_instance (
        .clk(clk),.reset(reset),
        .write_enable(fifo_wr_en),
        .write_data(fifo_wr_data),
        .full(fifo_full),
        .read_enable(fifo_rd_en),
        .read_data(fifo_rd_data),
        .empty(fifo_empty)
);


	
//-----------------------------
//----------------------------

	
/*
	always@(*) begin
		case(mode) 
		1'b0 : begin
			fifo_wr_en = valid;
			fifo_wr_data = p_data_in;
			ready = ~fifo_full;

			tx_control_start = ~fifo_empty;
			tx_control_data_in = fifo_rd_data;
			fifo_rd_enable = ~tx_control_busy ; 

		end
		1'b1 : begin
			start_temp = valid;
			data_in_temp = p_data_in;
			ready = ready_temp;

			tx_control_start = start_temp;
			tx_control_data_in = data_in_temp;
			ready_temp = ~tx_control_busy;
		end

		endcase
		

	end
*/
	always@(*) begin
                case(mode)
                	1'b0 :fifo_wr_en = valid ;
			1'b1 :start_temp = valid ;
		endcase
	end


	always@(*) begin
                case(mode)
                        1'b0 :fifo_wr_data = p_data_in ;
                        1'b1 :data_in_temp = p_data_in ;
                endcase
        end
	
	always@(*) begin
                case(mode)
                        1'b0 :ready = ~fifo_full ;
                        1'b1 :ready = ready_temp ;
                endcase
        end

	always@(*) begin
                case(mode)
                        1'b0 :tx_control_start = ~fifo_empty ;
                        1'b1 :tx_control_start = start_temp ;
                endcase
        end

	always@(*) begin
                case(mode)
                        1'b0 :tx_control_data_in = fifo_rd_data ;
                        1'b1 :tx_control_data_in = data_in_temp ;
                endcase
        end

	always@(*) begin
                case(mode)
                        1'b0 :fifo_rd_en = ~tx_control_busy ;
                        1'b1 :ready_temp = ~tx_control_busy ;
                endcase
        end















endmodule
