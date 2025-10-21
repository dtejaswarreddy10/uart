/*
This module converts the serial data into parallel data 

*/


module rx_control #(parameter DATA_WIDTH = 8,SAMPLING = 16)(
	input s_data_in,
	output reg data_valid,
	output reg [DATA_WIDTH-1:0] p_data_out,
	input clk,reset,bclk,
	input [1:0] parity,
	output reg parity_error,stop_error);

	localparam IDLE= 3'b000,START=3'b001,DATA=3'b011,PARITY=3'b010,STOP=3'b110;			// Gray Encoding

	reg [2:0] present_state,next_state;

	reg [2:0] data_counter;
	reg [3:0] sampling_counter;
	reg valid_frame;
	reg [DATA_WIDTH-1:0] data_reg;
	reg rx_parity_bit;
	reg data_flag;
	reg sampling_flag;

//-----------------------
// FSM: State Register
//-----------------------

	always@(posedge clk or posedge reset) begin
		if(reset) present_state <= IDLE;
		else      present_state <= next_state;

	end

//-------------------------
// FSM: Next-State Logic
//-------------------------

	always@(*)begin
		case(present_state) 
			IDLE : begin
				valid_frame = 1'b0;
				if(s_data_in) begin
					next_state = IDLE;
					p_data_out = 'd0;
					data_valid = 1'b0;
				end
				else      next_state = START;
			end
			START : begin
				//if(sampling_counter== (SAMPLING - 1) & sampling_flag) next_state = DATA;
				if(sampling_counter== (SAMPLING - 1) & bclk) next_state = DATA;
				else 	 next_state = START;
				end
			DATA : begin
				if(data_flag & sampling_flag) begin
				//if(sampling_counter == (SAMPLING - 1) & bclk & data_counter == (DATA_WIDTH - 1)) begin
				//if(data_flag & sampling_counter == (SAMPLING - 1)) begin
					if(parity == 0) next_state = STOP;
					else            next_state = PARITY;
				end	
				else next_state = DATA;
			end
			PARITY : begin
                                       // if(sampling_counter == (SAMPLING - 1) & sampling_flag) next_state = STOP;
					if(sampling_counter== (SAMPLING - 1) & bclk) next_state = STOP;
                                        else     next_state = PARITY;
				end

			STOP : begin
                                //if(stop_flag & sampling_flag ) next_state = IDLE;
				if(sampling_counter== (SAMPLING - 1) & bclk) begin
				 	if( ~stop_error & ~parity_error)  valid_frame = 1'b1;
					next_state = IDLE;
				end
                                else next_state = STOP;
                        end

		endcase
	end
//------------------------------
//------------------------------
	
	always@(posedge clk or posedge reset) begin
		if (reset) sampling_counter <= 0;
		else if(bclk) sampling_counter <= sampling_counter + 1;
	end

	always@(posedge bclk or posedge reset)begin
		if (reset) data_counter <= 0;
		else if(present_state == DATA) begin
			if (sampling_counter == (SAMPLING - 1)) data_counter <= data_counter +1;
		end
		else data_counter = 0;
	end

	always@(posedge bclk or posedge reset) begin
		if (reset) sampling_flag <= 0;
                else if(sampling_counter== (SAMPLING - 1)) sampling_flag <= 1'b1;
                else sampling_flag <= 0;
        end

	always@(posedge bclk or posedge reset) begin
		if (reset) data_flag <= 0;
                else if(data_counter == (DATA_WIDTH - 1)) data_flag <= 1'b1;
                else data_flag <= 0;
        end


//-------------------------------------------------------------------------
// 
//-------------------------------------------------------------------------

	
	always@(posedge clk or posedge reset )begin
		if (reset) begin
			p_data_out   <= 'd0;
			data_valid   <= 1'b0;
			data_reg     <= 'd0;
			stop_error   <= 1'b0;
			parity_error <= 1'b0;
		end
		case(present_state)
			//IDLE 	: begin p_data_out <= 1'b0; data_valid <= 0 ; end
			//START 	: begin p_data_out <= 1'b0; data_valid <= 0 ; end
			DATA 	: begin if(sampling_counter == (SAMPLING/2 -1)) data_reg[data_counter] <= s_data_in ; end
			PARITY 	: begin  
					if(sampling_counter == (SAMPLING/2 -1)) begin
						rx_parity_bit <= s_data_in;
						case (parity)
        					2'b01: parity_error <= (rx_parity_bit != ~(^data_reg)); // odd parity
        					2'b10: parity_error <= (rx_parity_bit != (^data_reg));  // even parity
        					default: parity_error <= 0;
    						endcase
					end
					
				  end 
			STOP 	: begin
					if(sampling_counter == (SAMPLING/2 -1)) begin 
						if (s_data_in) 	stop_error <= 1'b0;
						else 		stop_error <= 1'b1;
					end
				  end

		endcase
	end

//======================================
// OUTPUT LOGIC
// Output values for _data_out and valid signals
//======================================
/*
	always@(posedge clk or posedge reset) begin
		if (reset) begin
			p_data_out <= 'd0;
			data_valid <= 1'b0;
		end else if (valid_frame) begin
			p_data_out <= data_reg;
			data_valid <= 1'b1;
		end else begin
			p_data_out <= 'd0;
			data_valid <= 1'b0;

		end

	end
*/

	always@(*) begin
		if (valid_frame) begin
			p_data_out <= data_reg;
			data_valid <= 1'b1;
		end else begin
			p_data_out <= 'd0;
			data_valid <= 1'b0;

		end

	end

//	assign p_data_out = valid_frame ? data_reg: 'd0 ;
//	assign data_valid = valid_frame ? 1'b1: 1'b0 ;



endmodule
