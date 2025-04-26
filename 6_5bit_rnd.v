module ell201_project (
    input wire clk,       // Now: 1Hz clock (1s period)
    input wire rst,
    output wire o_clk,    // Direct passthrough
    output reg [6:0] led,
    input wire [7:0] switch,
    output wire [3:0] bcd_tens,
    output wire [3:0] bcd_units
);
    assign o_clk = clk;

    reg [7:0] current_output;
    reg [4:0] lfsr_reg;
    reg [1:0] level; // 0 = idle, 1 = Level 1, 2 = Level 2
    reg [2:0] clk_counter;
    reg [4:0] counter;
    reg [6:0] sum;

    reg [3:0] countdown;
    reg countdown_active;
    reg [2:0] level_status; // 0: ongoing, 1: passed, 2: failed

    // BCD converter
    binary_to_bcd bcd_inst (
        .binary_in(current_output),
        .tens(bcd_tens),
        .units(bcd_units)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // RESET everything
            current_output <= 0;
            lfsr_reg <= 5'b10101;
            led <= 7'b0000000;
            clk_counter <= 0;
            counter <= 0;
            sum <= 0;
            level <= 1;
            level_status <= 0;
            countdown_active <= 0;
            countdown <= 3;
        end else begin
            if (countdown_active) begin
                clk_counter <= clk_counter + 1;
                if (clk_counter >= 1) begin
                    clk_counter <= 0;
                    if (countdown > 0) begin
                        current_output <= {4'b0000, countdown};
                        countdown <= countdown - 1;
                    end else begin
                        countdown_active <= 0;
                        level <= 2;
                        counter <= 0;
                    end
            
            end else if (level == 1 || level == 2) begin
                clk_counter <= clk_counter + 1;

                if (clk_counter >= (level == 1 ? 5 : 3)) begin
                    clk_counter <= 0;
                    counter <= counter + 1;

                    if (counter <= 3) begin
                        lfsr_reg <= {lfsr_reg[3:0], lfsr_reg[4] ^ lfsr_reg[2]};
                        current_output <= {3'b000, lfsr_reg};
                        led <= {lfsr_reg, 2'b00};
                        sum <= bcd_tens * 10 + bcd_units;
                    end else if (counter == 7) begin
                        // After showing 3 numbers, wait for user's input
                        if (switch == sum) begin
                            current_output <= 8'b000001011;
                            level_status <= 1; // passed
                        end else begin
                            current_output <= 8'd0;
                            level_status <= 2; // failed
                        end
                    end else if (counter == 8) begin
                        // After 5 seconds of showing result
                        if (level_status == 1 && level == 1) begin
                            // Passed -> Start countdown
                            countdown_active <= 1;
                            countdown <= 3;
                            counter <= 0;
                        end else begin
                            // Failed -> Stay at 00
                            level <= 0;
                        end
                    end
                end
                end
            end
        end
    end
endmodule

// BCD converter module
module binary_to_bcd (
    input  wire [7:0] binary_in,
    output wire [3:0] tens,
    output wire [3:0] units
);
    assign tens = binary_in / 10;
    assign units = binary_in % 10;
endmodule
