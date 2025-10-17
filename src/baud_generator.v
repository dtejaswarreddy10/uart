/*
Baud Generator Module : 

This Baud Generator module creates a baud clock (bclk) used by the UART transmitter and receiver to sample or shift data bits at the correct rate.

Inputs:
clk → Main system clock (e.g., 100 MHz)
reset → Resets internal counter and output clock
Output:
bclk → Baud clock, generated at a frequency equal to

EQUATION :
       	divisor(n) = clock Frequency / (baud rate * Sampling )
For example, with a 100 MHz clock, 9600 baud rate, and 16× sampling,
bclk toggles at the correct rate(n) for UART bit timing.

Operation:

The parameter n calculates the number of system clock cycles needed to create one sampling period of the baud clock.
A counter increments on each clock cycle.
When the counter reaches n, it generates a bclk pulse and resets the counter.
This periodic bclk pulse is used by the UART TX and RX modules to time their operations precisely.
*/

module baud_generator #(
	parameter SAMPLING = 16,CLK_FREQUENCY = 100000000,BAUD_RATE = 9600
) (
	input clk,reset,
	output reg bclk
);
	integer n = CLK_FREQUENCY/(BAUD_RATE*SAMPLING);
	integer count;
	always@(posedge clk or posedge reset)begin

		if(reset) begin
			count <= 0;
			bclk  <= 1'b0;
		end
		else if(count == n-1) begin
			bclk  <= 1'b1;
			count <= 0;
		end
		else begin
			count <= count+1;
			bclk  <= 1'b0;
		end
	end 
endmodule
