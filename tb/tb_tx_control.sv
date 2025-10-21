`timescale 1ns/1ps

module tb_tx_control;

  // ------------------------------------------------------------
  // Parameters
  // ------------------------------------------------------------
  localparam CLK_FREQ   = 100_000_000; // 100 MHz
  localparam SAMPLING   = 16;
  localparam DATA_WIDTH = 8;
  localparam BAUD_RATE  = 9600;

  // ------------------------------------------------------------
  // Testbench Signals
  // ------------------------------------------------------------
  reg clk;
  reg reset;
  reg ready;
  reg valid;
  reg mode_select;
  reg [1:0] parity_select;
  reg [1:0] stop_select;
  reg [DATA_WIDTH-1:0] p_data_in;
  wire [DATA_WIDTH-1:0]p_data_out;
 
  wire valid_out;
  wire parity_error,stop_error;

  // ------------------------------------------------------------
  // DUT Instantiation
  // ------------------------------------------------------------
  uart_loop_back #(
    .DATA_WIDTH(DATA_WIDTH),
    .SAMPLING(SAMPLING),
    .CLK_FREQUENCY(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
  ) duv (
    .clk(clk),
    .reset(reset),
    .ready(ready),
    .valid_in(valid),
    .mode(mode_select),
    .parity(parity_select),
    .stop(stop_select),
    .p_data_in(p_data_in),
    .p_data_out(p_data_out),
    .valid_out(valid_out),
    .parity_error(parity_error),
    .stop_error(stop_error)
  );

  // ------------------------------------------------------------
  // Clock Generation (100 MHz)
  // ------------------------------------------------------------
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10 ns period -> 100 MHz
  end

  // ------------------------------------------------------------
  // Reset Task
  // ------------------------------------------------------------
  task apply_reset;
    begin
      reset = 1;
      valid = 0;
      //ready = 0;
      @(posedge clk);
      @(posedge clk);
      reset = 0;
    end
  endtask

  // ------------------------------------------------------------
  // UART Transmission Stimulus
  // ------------------------------------------------------------
  task send_byte(
      input [DATA_WIDTH-1:0] data,
      input [1:0] parity_mode,
      input [1:0] stop_mode,
      input fifo_mode
  );
    begin
      @(posedge clk);
      mode_select = fifo_mode;
      parity_select = parity_mode;  // 00-none, 01-odd, 10-even
      stop_select   = stop_mode;    // 00-1 stop, 01-2 stops
      p_data_in     = data;
      valid         = 1;
      @(posedge clk);
      valid         = 0;
      $display("[%0t ns] Sending byte: 0x%0h (parity=%0b stop=%0b)", 
                $time, data, parity_mode, stop_mode);

      // Wait for transmission to complete
	if (fifo_mode == 1'b1) begin
      wait (ready == 0);
      wait (ready == 1);
	end 
      $display("[%0t ns] Transmission complete.\n", $time);
    end
  endtask

  // ------------------------------------------------------------
  // Monitor serial output waveform
  // ------------------------------------------------------------
  initial begin
    $display("\n===== UART TX Testbench Start =====\n");
    apply_reset();

	// FIFO was Not Enabled 
	
    // Test Case 1: No parity, 1 stop bit
    send_byte(8'hA5, 2'b00, 2'b00,1'b1);

    // Test Case 2: Even parity, 1 stop bit
    send_byte(8'h3C, 2'b10, 2'b00,1'b1);

    // Test Case 3: Odd parity, 2 stop bits
    send_byte(8'hF0, 2'b01, 2'b01,1'b1);

    // Test Case 4: Random data
    send_byte(8'h55, 2'b00, 2'b00,1'b1);

	// FIFO was Enabled 

    // Test Case 5: No parity, 1 stop bit
    send_byte(8'hA5, 2'b00, 2'b00,1'b0);

    // Test Case 6: Even parity, 1 stop bit
    send_byte(8'h3C, 2'b10, 2'b00,1'b0);

    // Test Case 7: Odd parity, 2 stop bits
    send_byte(8'hF0, 2'b01, 2'b01,1'b0);

    // Test Case 8: Random data
    send_byte(8'h55, 2'b00, 2'b00,1'b0);









	wait(duv.dut_tx.fifo_empty == 1'b1);
	wait(duv.dut_tx.control_instance.busy == 1);
	wait(duv.dut_tx.control_instance.busy == 0);
	
    $display("\n===== All UART TX Tests Completed =====\n");
    $finish;
  end


endmodule

