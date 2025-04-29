`timescale 1ns / 1ps

module tb_gmp;
    reg clk, rst;
    reg [6:0] switch;
    wire o_clk;
    wire [6:0] led;
    wire [3:0] bcd_tens, bcd_units;

    // DUT
    gmp uut (
        .clk(clk),
        .rst(rst),
        .o_clk(o_clk),
        .led(led),
        .switch(switch),
        .bcd_tens(bcd_tens),
        .bcd_units(bcd_units)
    );

    // Clock generation: 10ns period => 100MHz
    always #5 clk = ~clk;

    integer cycle;
    reg [7:0] correct_sum;
    integer correct;

    initial begin
        $dumpfile("gmp_tb.vcd");
        $dumpvars(0, tb_gmp);

        clk = 0;
        rst = 1;
        switch = 0;
        cycle = 0;
        correct_sum = 0;
        correct = 0;

        #20 rst = 0; // Deassert reset after some time

        // Run for 4 full rounds (16 cycles per round)
        repeat (64) begin
            @(posedge clk);
            cycle = cycle + 1;

            // Detect phase for user input
            if (cycle % 16 == 5) begin
                // Phase 3 begins: we already accumulated LFSR output
                correct_sum = 0;
            end

            // Track sum of LFSR-generated values (cycles 0–3 of each round)
            if (cycle % 16 < 4) begin
                correct_sum = correct_sum + uut.lfsr_reg;
            end

            // Inject switch value in input phase
            if ((cycle % 16) >= 5 && (cycle % 16) <= 10) begin
                // 75% of the time, input correct answer
                if ($urandom_range(0, 3) < 3) begin
                    switch = correct_sum % 100;
                    correct = 1;
                end else begin
                    switch = (correct_sum + $urandom_range(1, 10)) % 100;
                    correct = 0;
                end
            end

            // Optional debug output
            if ((cycle % 16) == 12) begin
                $display("Cycle: %0d | Expected: %0d | Input: %0d | BCD: %0d%0d | %s",
                         cycle,
                         correct_sum % 100,
                         switch,
                         bcd_tens,
                         bcd_units,
                         (switch == correct_sum % 100) ? "Correct" : "Wrong");
            end
        end

        $finish;
    end
endmodule
