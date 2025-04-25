module gmpv3 (
    input wire clk,
    input wire rst,
    output wire o_clk, // one led assigned to o_clk
    output reg [6:0] led, // one led is taken by o_clk
    input wire [7:0] switch,
    output wire [3:0] bcd_tens,
    output wire [3:0] bcd_units
);
    // Direct clock pass-through
    assign o_clk = clk;
    
    // Signal declarations
	 reg [7:0] current_output;
    wire [3:0] slow_clk;
    wire [4:0] lfsr_out;

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

    // Control Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_output <= 0;
        end else begin
            case (slow_clk)
                4'd0: begin
                    current_output <= 8'b00000000;
                    led <= switch[6:0]; // Display switch value on LEDs
                end
                4'd1, 4'd2, 4'd3, 4'd4, 4'd5: begin
                    current_output <= {3'b000, lfsr_out};
                    // values[slow_clk-1] <= lfsr_out;
                end
                4'd6: begin // placeholder 00 for user to calculate
                    // led <= ~(7'b1111111 >> score); // Heavy meth used !!!!
                    current_output <= 8'b00000000;
                end
                4'd7, 4'd8, 4'd9, 4'd10: begin
                    current_output <= switch[7:0];
                end
                default: begin
                    current_output <= 8'b00000000;
                end
            endcase
        end
    end

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



