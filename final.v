module gmpv3 (
    input wire clk,
    input wire rst,
    output wire o_clk, // one led assigned to o_clk
    output reg [6:0] led, // one led is taken by o_clk
    input wire [7:0] switch,
    output reg [7:0] current_output,
    output wire [3:0] bcd_tens,
    output wire [3:0] bcd_units
);
    // Direct clock pass-through
    assign o_clk = clk;
    
    // Signal declarations
    wire [3:0] slow_clk;
    wire [4:0] lfsr_out;
    wire [7:0] sum_out;
    reg [2:0] score;
    reg [4:0] values [0:4];

    // Instantiate LFSR
    lfsr_5bit lfsr_inst (
        .clk(clk),
        .rst(rst),
        .seed_value(switch[4:0]), // Use switch[4:0] as seed
        .rand_num(lfsr_out)
    );

    // Instantiate Slow Clock Generator
    slow_clk_gen slow_clk_inst (
        .clk(clk),
        .rst(rst),
        .slow_clk(slow_clk)
    );

    // Instantiate BCD Converter
    binary_to_bcd bcd_inst (
        .binary_in(current_output),
        .tens(bcd_tens),
        .units(bcd_units)
    );

    // Instantiate 6-input Adder
    adder_6input adder_inst (
        .in0(values[0]),
        .in1(values[1]),
        .in2(values[2]),
        .in3(values[3]),
        .in4(values[4]),
        .sum_out(sum_out)  // Connect sum_out from adder to wire
    );

    // Control Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_output <= 0;
            score <= 0;
        end else begin
            case (slow_clk)
                4'd0: begin
                    current_output <= 8'b00000000;
                    led <= switch[6:0]; // Display switch value on LEDs
                end
                4'd1, 4'd2, 4'd3, 4'd4, 4'd5: begin
                    current_output <= {3'b000, lfsr_out};
                    // Store in the correct position using slow_clk as index
                    values[slow_clk-1] <= lfsr_out;
                end
                4'd6: begin // placeholder 00 for user to calculate
                    led <= ~(7'b1111111 >> score); // Heavy meth used !!!!
                    current_output <= 8'b00000000;
                end
                4'd7, 4'd8: begin
                    current_output <= switch[7:0];
                end
                4'd9: begin
                    if (sum_out == switch[7:0]) begin // Compare against sum_out instead of final_sum
                        score <= score + 1;
                        current_output <= sum_out;
                        led <= 7'b1111111; // All LEDs on to show correct answer
                    end 
                    else begin
                        current_output <= sum_out;
                        led <= ~(7'b1111111 >> score); // Heavy meth used !!!!
                    end
                end
                4'd10: begin
                    current_output <= sum_out;  // Assign to sum_out
                end
                default: begin
                    current_output <= 8'b00000000;
                    led <= score; // Display score on LEDs
                end
            endcase
        end
    end

endmodule

module adder_6input (
    input wire [4:0] in0,
    input wire [4:0] in1,
    input wire [4:0] in2,
    input wire [4:0] in3,
    input wire [4:0] in4,
    output wire [7:0] sum_out
);

    assign sum_out = (in0 + in1 + in2 + in3 + in4) % 100 ;

endmodule


module lfsr_5bit (
    input wire clk,
    input wire rst,
    input wire [4:0] seed_value,
    output reg [4:0] rand_num
);
    // Single line feedback definition
    wire feedback = rand_num[4] ^ rand_num[2];

    always @(posedge clk or posedge rst) begin
        // Prevent all-zero state while keeping code compact
        rand_num <= rst ? (|seed_value ? seed_value : 5'h01) : {rand_num[3:0], feedback};
    end
endmodule


module slow_clk_gen (
    input wire clk,
    input wire rst,
    output reg [3:0] slow_clk
);
    reg [3:0] cycle_counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            slow_clk <= 0;
            cycle_counter <= 0;
        end else begin
            if (cycle_counter == 9) begin
                cycle_counter <= 0;
                if (slow_clk == 10)
                    slow_clk <= 0;
                else
                    slow_clk <= slow_clk + 1;
            end else
                cycle_counter <= cycle_counter + 1;
        end
    end
endmodule


module binary_to_bcd (
    input  wire [7:0] binary_in,
    output wire [3:0] tens,
    output wire [3:0] units
);
    // Use wires instead of regs for combinational logic
    wire [7:0] clamped_input = (binary_in > 8'd99) ? 8'd99 : binary_in;
    
    // Direct assignments eliminate need for always block
    assign tens = clamped_input / 10;
    assign units = clamped_input % 10;
endmodule




