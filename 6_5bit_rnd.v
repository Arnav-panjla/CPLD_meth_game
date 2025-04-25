module gmpv3 (
    input wire clk,
    input wire rst,
    output wire o_clk, // one led assigned to o_clk
    output reg [6:0] led, // one led is taken by o_clk
    input wire [7:0] switch,
    output reg [7:0] current_output,
    output wire [3:0] bcd_tens,
    output wire [3:0] bcd_units,
    output reg [7:0] final_sum
);
    assign o_clk = clk; 
    wire [3:0] slow_clk;
    wire [4:0] lfsr_out;
    wire [7:0] sum_out;  // Add wire for sum_out from adder_6input
    reg [2:0] score;
    reg [4:0] values [0:4];  // Array to store values

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
            final_sum <= 0;  // Reset final_sum to 0 on reset
        end else begin
            case (slow_clk)
                4'd0: begin
                    current_output <= 8'b00000000;
                    led <= switch[6:0]; // Display switch value on LEDs
                end
                4'd1: begin
                    led <= ~(7'b1111111 >> score); // Heavy meth used !!!!
                    current_output <= {3'b000, lfsr_out};
                    values[0] <= lfsr_out;
                end
                4'd2: begin
                    led <= ~(7'b1111111 >> score); // Heavy meth used !!!!
                    current_output <= {3'b000, lfsr_out};
                    values[1] <= lfsr_out;
                end
                4'd3: begin
                    led <= ~(7'b1111111 >> score); // Heavy meth used !!!!
                    current_output <= {3'b000, lfsr_out};
                    values[2] <= lfsr_out;
                end
                4'd4: begin
                    led <= ~(7'b1111111 >> score); // Heavy meth used !!!!
                    current_output <= {3'b000, lfsr_out};
                    values[3] <= lfsr_out;
                end
                4'd5: begin
                    led <= ~(7'b1111111 >> score); // Heavy meth used !!!!
                    current_output <= {3'b000, lfsr_out};
                    values[4] <= lfsr_out;
                end
                4'd6: begin // placeholder 00 for user to calculate
                    led <= ~(7'b1111111 >> score); // Heavy meth used !!!!
                    current_output <= 8'b00000000;
                end
                4'd7: begin 
                    current_output <= switch[7:0]; // Display switch value on LEDs
                end
                4'd8: begin
                    current_output <= switch[7:0];
                end
                4'd9: begin
                    if (sum_out == switch[7:0]) begin // Compare against sum_out instead of final_sum
                        score <= score + 1;
                        current_output <= sum_out;
                        led <= 7'b1111111; // All LEDs on to show correct answer
                    end else begin
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
            final_sum <= sum_out;  // Update final_sum with sum_out
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

    wire feedback;
    assign feedback = rand_num[4] ^ rand_num[2]; // XOR feedback logic

    always @(posedge clk or posedge rst) begin
        if (rst)
            rand_num <= seed_value; // Load external seed
        else
            rand_num <= {rand_num[3:0], feedback}; // Shift with feedback
    end

endmodule

module slow_clk_gen (
    input wire clk,
    input wire rst,
    output reg [3:0] slow_clk // 4-bit slow clock
);

    reg [3:0] cycle_counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            slow_clk <= 0;
            cycle_counter <= 0;
        end else begin
            if (cycle_counter == 9) begin // trigger every 10 clocks
                cycle_counter <= 0;
                if (slow_clk == 4'd9)
                    slow_clk <= 0; // Reset slow clock after 10 cycles
                else
                    slow_clk <= slow_clk + 1;
            end else begin
                cycle_counter <= cycle_counter + 1;
            end
        end
    end

endmodule

module binary_to_bcd (
    input  wire [7:0] binary_in,
    output reg  [3:0] tens,
    output reg  [3:0] units
);
    reg [7:0] clamped_input;

    always @(*) begin
        clamped_input = (binary_in > 99) ? 99 : binary_in;  // Clamp to 99 if greater
        tens  = clamped_input / 10;
        units = clamped_input % 10;
    end

endmodule




