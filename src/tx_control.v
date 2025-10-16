/*
This Module controls converts the parallel data into serial
*/

module tx_control #(parameter DATA_WIDTH = 8,SAMPLING =16)(
	input clk,reset,
	input [1:0]parity,stop,
	input start,busy,
	input [DATA_WIDTH-1:0] p_data_in,
	output s_data_out);

//	localparam IDLE= 3'b000,START=3'b001,DATA=3'b010,PARITY=3'b011,STOP=3'b100;			// Binary Encoding
	localparam IDLE= 3'b000,START=3'b001,DATA=3'b011,PARITY=3'b010,STOP=3'b110;			// Gray Encoding
//	localparam IDLE= 5'b00001,START=5'b00010,DATA=5'b00100,PARITY=5'b01000,STOP=5'b10000;		// One hot encoding 

	reg [2:0] present_state,next_state;
//	reg [4:0] present_state,next_state; 			//for one got encoding

	reg [2:0] data_counter;
	reg [1:0] stop_counter;
	reg [3:0] sampling_counter;

	reg [DATA_WIDTH-1:0] data_reg;
	wire parity_calc;

	always@(posedge clk or posedge reset) begin
		if(reset) present_state <= IDLE;
		else      present_state <= next_state;

	end


	always@(*)begin
		case(present_state) 
			IDLE : begin
				if(start) next_state = START;
				else      next_state = IDLE;
			end
			START : begin
				if(sampling_counter== (SAMPLING - 1)) next_state = DATA;
				else 	 next_state = START;
			DATA : begin
				if(data_counter >= DATA_WIDTH) begin
					if(parity == 0) next_state = STOP;
					else            next_state = PARITY;
				end	
				else next_state = DATA;
			end
			PARITY : begin
                                        if(sampling_counter== (SAMPLING - 1)) next_state = STOP;
                                        else     next_state = PARITY;

			STOP : begin
                                if(stop_counter >= 2) next_state = IDLE;
                                else next_state = STOP;
                        end

		endcase
	end

	always@(posedge clk or posedge reset) begin
		if (reset) data_counter <= 0;
		else if(present_state == DATA) begin
			if (sampling_counter == (SAMPLING - 1)) data_counter <= data_counter +1;
		end
		else data_counter = 0;
	end

	always@(posedge clk or posedge reset) begin
                if (reset) stop_counter <= 0;
                else if(present_state == STOP) begin
                        if (sampling_counter== (SAMPLING - 1)) stop_counter <= stop_counter +1;
                end
                else stop_counter = 0;
        end

	always@(posedge clk or posedge reset) begin
		if (reset) sampling_counter <= 0;
		else if(bclk) sampling_counter <= sampling_counter + 1;
	end


	always@(*)begin
		if (present_state == IDLE) data_reg = p_data_in ;
	end

	always@(*)begin
                if (present_state == START) s_data_out = 0 ;
        end

	always@(*)begin
                if (present_state == DATA) s_data_out = data_reg[data_counter] ;
        end

	always@(*)begin
                if (present_state == STOP) s_data_out = 1 ;
        end

	assign parity_calc = ^data_reg;  					// XOR reduction gives '1' if number of 1's in data is odd

	always@(*)begin
		if (present_state == PARITY) begin
			if(parity == 2'b01)   s_data_out = ~parity_calc ;				// odd parity
			if(parity == 2'b10)   s_data_out = parity_calc; 				// even parity 	
		end
        end



endmodule
