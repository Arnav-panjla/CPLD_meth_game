`timescale 1ns / 1ps

module ell201_project_tb();

    reg clk;
    reg rst;
    reg [7:0] switch;
    wire o_clk;
    wire [6:0] led;
    wire [3:0] bcd_tens;
    wire [3:0] bcd_units;

    // Instantiate DUT
    ell201_project dut (
        .clk(clk),
        .rst(rst),
        .o_clk(o_clk),
        .led(led),
        .switch(switch),
        .bcd_tens(bcd_tens),
        .bcd_units(bcd_units)
    );

    // 1Hz clock (simulate 1s period) - make slow clock manually
    initial begin
        clk = 0;
        forever #500_000_000 clk = ~clk; // Toggle every 0.5s -> 1s period
    end

    initial begin
        $dumpfile("ell201_project_tb.vcd");
        $dumpvars(0, ell201_project_tb);

        rst = 1;
        switch = 8'b00000000;

        // Hold reset for 2 seconds
        #2_000_000_000;
        rst = 0;

        // Wait for first level numbers
        #30_000_000_000; // 30 seconds (3 numbers at 5s interval)

        // Simulate correct switch input
        switch = 8'd30; // pretend correct sum

        // Wait for Level 1 result and countdown
        #30_000_000_000;

        // Now in Level 2
        #20_000_000_000; // 3 numbers at 3s interval

        switch = 8'd50; // pretend correct sum

        // Wait till level 2 ends
        #30_000_000_000;

        $finish;
    end

endmodule
