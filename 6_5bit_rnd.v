module top_module (
    input wire clk,
    input wire rst,
    output wire o_clk,
    input wire [4:0] seed_value,
    output reg [7:0] current_output,
    output wire [3:0] bcd_tens,
    output wire [3:0] bcd_units,
    output wire [7:0] final_sum,
    output reg sum_valid
);

    assign o_clk = clk; 
    wire [2:0] slow_clk;
    wire [4:0] lfsr_out;

    reg [4:0] values [0:4];  // Array to store values

    // Instantiate LFSR
    lfsr_5bit lfsr_inst (
    .clk(clk),
    .rst(rst),
    .seed_value(seed_value),
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
        .in5(values[5]),
        .sum_out(final_sum)
    );

    // Control Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_output <= 0;
            sum_valid <= 0;
        end else begin
            case (slow_clk)
                3'd0: begin
                    current_output <= 8'b00000000;
                    sum_valid <= 0;
                end
                3'd1: begin
                    current_output <= {3'b000, lfsr_out};
                    values[0] <= lfsr_out;
                end
                3'd2: begin
                    current_output <= {3'b000, lfsr_out};
                    values[1] <= lfsr_out;
                end
                3'd3: begin
                    current_output <= {3'b000, lfsr_out};
                    values[2] <= lfsr_out;
                end
                3'd4: begin
                    current_output <= {3'b000, lfsr_out};
                    values[3] <= lfsr_out;
                end
                3'd5: begin
                    current_output <= {3'b000, lfsr_out};
                    values[4] <= lfsr_out;
                end
                3'd6: begin
                    current_output <= 8'b00000000;
                    sum_valid <= 1;         // Signal that sum is now valid
                end
                3'd7: begin
                    current_output <= sum_out;
                end
                3'd8: begin
                    current_output <= sum_out;
                end
                default: begin
                    current_output <= 8'b00000000;
                    sum_valid <= 0;
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


module slow_clk_gen (
    input wire clk,
    input wire rst,
    output reg [2:0] slow_clk // 3-bit slow clock
);

    reg [3:0] cycle_counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cycle_counter <= 0;
            slow_clk <= 0;
        end else begin
            if (cycle_counter == 9) begin
                cycle_counter <= 0;
                if (slow_clk < 6)
                    slow_clk <= slow_clk + 1;
            end else begin
                cycle_counter <= cycle_counter + 1;
            end
        end
    end

endmodule



module lfsr_5bit (
    input wire clk,
    input wire rst,
    input wire [4:0] seed_value,
    output reg [4:0] rand_num
);

    wire feedback;
    assign feedback = rand_num[4] ^ rand_num[2];

    always @(posedge clk or posedge rst) begin
        if (rst)
            rand_num <= seed_value; // Load external seed
        else
            rand_num <= {rand_num[3:0], feedback};
    end

endmodule




module binary_to_bcd (
    input  wire [4:0] binary_in,
    output reg  [3:0] tens,
    output reg  [3:0] units
);
    always @(*) begin
        case (binary_in)
            5'd0:  begin tens = 0; units = 0; end
            5'd1:  begin tens = 0; units = 1; end
            5'd2:  begin tens = 0; units = 2; end
            5'd3:  begin tens = 0; units = 3; end
            5'd4:  begin tens = 0; units = 4; end
            5'd5:  begin tens = 0; units = 5; end
            5'd6:  begin tens = 0; units = 6; end
            5'd7:  begin tens = 0; units = 7; end
            5'd8:  begin tens = 0; units = 8; end
            5'd9:  begin tens = 0; units = 9; end
            5'd10: begin tens = 1; units = 0; end
            5'd11: begin tens = 1; units = 1; end
            5'd12: begin tens = 1; units = 2; end
            5'd13: begin tens = 1; units = 3; end
            5'd14: begin tens = 1; units = 4; end
            5'd15: begin tens = 1; units = 5; end
            5'd16: begin tens = 1; units = 6; end
            5'd17: begin tens = 1; units = 7; end
            5'd18: begin tens = 1; units = 8; end
            5'd19: begin tens = 1; units = 9; end
            5'd20: begin tens = 2; units = 0; end
            5'd21: begin tens = 2; units = 1; end
            5'd22: begin tens = 2; units = 2; end
            5'd23: begin tens = 2; units = 3; end
            5'd24: begin tens = 2; units = 4; end
            5'd25: begin tens = 2; units = 5; end
            5'd26: begin tens = 2; units = 6; end
            5'd27: begin tens = 2; units = 7; end
            5'd28: begin tens = 2; units = 8; end
            5'd29: begin tens = 2; units = 9; end
            5'd30: begin tens = 3; units = 0; end
            5'd31: begin tens = 3; units = 1; end
            default: begin tens = 0; units = 0; end
        endcase
    end
endmodule



