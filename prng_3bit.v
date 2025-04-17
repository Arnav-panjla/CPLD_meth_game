module top_module (
    input wire clk,
    input wire reset,
    output wire [2:0] bcd_out
);

    // Hardcoded 3-bit seed
    wire [2:0] seed = 3'b101;

    // Instantiate the PRNG
    prng_3bit prng_inst (
        .clk(clk),
        .reset(reset),
        .seed(seed),
        .out(bcd_out)
    );

endmodule

// PRNG Module using 3 D Flip-Flops
module prng_3bit (
    input wire clk,
    input wire reset,
    input wire [2:0] seed,
    output wire [2:0] out
);

    wire [2:0] q;
    wire feedback;

    // Feedback using XOR of last two bits
    assign feedback = q[0] ^ q[1];

    // D inputs: Load seed on reset, else shift
    wire d0 = reset ? seed[2] : feedback;
    wire d1 = reset ? seed[1] : q[2];
    wire d2 = reset ? seed[0] : q[1];

    // D Flip-Flops
    dff dff0 (.clk(clk), .reset(reset), .d(d0), .q(q[2]));
    dff dff1 (.clk(clk), .reset(reset), .d(d1), .q(q[1]));
    dff dff2 (.clk(clk), .reset(reset), .d(d2), .q(q[0]));

    assign out = q;

endmodule

// D Flip-Flop with Reset
module dff (
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

