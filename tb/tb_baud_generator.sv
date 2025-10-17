`timescale 1ns/1ps

module tb_baud_generator;

    // ------------------------------------------------------------
    // DUT Parameters
    // ------------------------------------------------------------
    localparam CLK_FREQ  = 100_000_000;  // 100 MHz
    localparam SAMPLING  = 16;

    // List of baud rates to test
    integer baud_rates [5] = '{9600, 19200, 38400, 57600, 115200};

    // ------------------------------------------------------------
    // DUT Interface
    // ------------------------------------------------------------
    reg clk;
    reg reset;
    wire bclk;

    // Current baud rate (we will override via defparam)
    parameter BAUD_RATE = 9600;

    // ------------------------------------------------------------
    // Instantiate DUT (parameters can be overridden with defparam)
    // ------------------------------------------------------------
    baud_generator #(
        .SAMPLING(SAMPLING),
        .CLK_FREQUENCY(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .reset(reset),
        .bclk(bclk)
    );

    // ------------------------------------------------------------
    // Clock Generation (100 MHz)
    // ------------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;   // 10 ns period -> 100 MHz
    end

    // ------------------------------------------------------------
    // Test Logic
    // ------------------------------------------------------------
    integer i;
    realtime t_start, t_end;
    realtime expected_period, measured_period, error_pct;

    initial begin
        $display("\n===== UART Baud Rate Generator Verification =====\n");
        for (i = 0; i < $size(baud_rates); i++) begin
            // Override baud rate parameter dynamically
            force dut.n = CLK_FREQ / (baud_rates[i] * SAMPLING);

            // Apply reset
            reset = 1;
            repeat(3) @(posedge clk);
            reset = 0;

            // Wait for first pulse
            @(posedge bclk);
            t_start = $realtime;
            @(posedge bclk);
            t_end = $realtime;

            measured_period = t_end - t_start;
            expected_period = 1e9 / (baud_rates[i] * SAMPLING);
            error_pct = ((measured_period - expected_period) / expected_period) * 100.0;

            $display("Baud Rate = %0d", baud_rates[i]);
            $display("Expected bclk Period = %.3f ns", expected_period);
            $display("Measured bclk Period = %.3f ns", measured_period);
            $display("Error = %.3f%%", error_pct);
            if (error_pct > 0.5 || error_pct < -0.5)
                $display("? FAIL: Baud rate out of tolerance\n");
            else
                $display("? PASS: Baud rate generator correct\n");

            #1000;
        end

        $display("All baud rate checks completed.\n");
        $finish;
    end

endmodule

