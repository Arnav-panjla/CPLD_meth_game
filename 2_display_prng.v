module top_module (
    input wire clk,
    input wire reset,
    output wire [2:0] bcd_out_1,  // Output of first PRNG
    output wire [2:0] bcd_out_2   // Output of second PRNG
);

    // Two different hardcoded 3-bit seeds
    wire [2:0] seed1 = 3'b101;  // First PRNG seed
    wire [2:0] seed2 = 3'b011;  // Second PRNG seed

    // Instantiate first 3-bit PRNG
    prng_3bit prng_inst1 (
        .clk(clk),
        .reset(reset),
        .seed(seed1),
        .out(bcd_out_1)
    );

    // Instantiate second 3-bit PRNG
    prng_3bit prng_inst2 (
        .clk(clk),
        .reset(reset),
        .seed(seed2),
        .out(bcd_out_2)
    );

endmodule

// 3-bit PRNG Module
module prng_3bit (
    input wire clk,
    input wire reset,
    input wire [2:0] seed,
    output wire [2:0] out
);

    wire [2:0] q;
    wire feedback;

    // XOR feedback from last 2 bits
    assign feedback = q[0] ^ q[1];

    // D inputs (seed during reset, else shift)
    wire d0 = reset ? seed[2] : feedback;
    wire d1 = reset ? seed[1] : q[2];
    wire d2 = reset ? seed[0] : q[1];

    // Flip-Flops
    dfff dff0 (.clk(clk), .reset(reset), .d(d0), .q(q[2]));
    dfff dff1 (.clk(clk), .reset(reset), .d(d1), .q(q[1]));
    dfff dff2 (.clk(clk), .reset(reset), .d(d2), .q(q[0]));

    assign out = q;

endmodule

// D Flip-Flop Module
module dfff (
    input wire clk,
    input wire reset,
    input wire d,
    output reg q
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= 1'b0;
        else
            q <= d;
    end
endmodule

