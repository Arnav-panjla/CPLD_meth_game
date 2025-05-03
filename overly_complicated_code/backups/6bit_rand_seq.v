module top_module (
    input wire clk,
    input wire rst,
    output wire [2:0] num1, // tens digit
    output wire [2:0] num2, // ones digit
    output wire [5:0] rand_out,
    output wire [6:0] num   // final 2-digit number (max 7 bits: 7*10 + 7 = 77)
);
    wire slow_clk;

    click_counter counter_inst (
        .clk(clk),
        .rst(rst),
        .tick(slow_clk)
    );

    random_6bit_xor_msb rng_inst (
        .clk(slow_clk),
        .rst(rst),
        .rand_out(rand_out)
    );

    assign num1 = rand_out[5:3];
    assign num2 = rand_out[2:0];
    assign num = (num1 * 7'd10) + num2; // Combined as two-digit number
endmodule


module random_6bit_xor_msb (
    input wire clk,
    input wire rst,
    output reg [5:0] rand_out
);

    reg [4:0] lfsr;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr <= 5'b10101;
            rand_out <= 6'b000000;
        end else begin
            // LFSR for lower 5 bits
            lfsr[4:1] <= lfsr[3:0];
            lfsr[0] <= lfsr[4] ^ lfsr[3];

            // 6-bit output: MSB = XOR of bit0 and bit1
            rand_out[4:0] <= lfsr;
            rand_out[5] <= lfsr[1] ^ lfsr[0];
        end
    end
endmodule

module click_counter (
    input wire clk,
    input wire rst,
    output reg tick
);
    reg [3:0] count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 4'd0;
            tick <= 1'b0;
        end else begin
            if (count == 4'd9) begin
                count <= 4'd0;
                tick <= 1'b1;
            end else begin
                count <= count + 1;
                tick <= 1'b0;
            end
        end
    end
endmodule

