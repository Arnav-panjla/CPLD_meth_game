module ell201_project (
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

    reg [3:0]counter; // initilize counter
     // Signal declarations
     reg [7:0] current_output;
     reg [4:0] lfsr_reg; // LFSR register


     // Instantiate BCD Converter
     binary_to_bcd bcd_inst (
         .binary_in(current_output),
         .tens(bcd_tens),
         .units(bcd_units)
     );

     // Control Logic with LFSR implementation at full clock speed
     always @(posedge clk or posedge rst) begin
         if (rst) begin
             current_output <= 0;
             lfsr_reg <= 5'b10101; // Non-zero seed
             led <= 7'b0000000;
             counter <= 0; // Reset counter
         end else begin
             // LFSR computation on every clock edge (full speed)
             // 5-bit maximal-length LFSR with taps at bits 5 and 3
             lfsr_reg <= {lfsr_reg[3:0], lfsr_reg[4] ^ lfsr_reg[2]};

             // Display the LFSR value directly
             current_output <= {3'b000, lfsr_reg};
             led <= {lfsr_reg, 2'b00};


         end
     end
endmodule

module binary_to_bcd (
     input  wire [7:0] binary_in,
     output wire [3:0] tens,
     output wire [3:0] units
);
     // Use wires instead of regs for combinational logic
     wire [7:0] clamped_input = binary_in;

     // Direct assignments eliminate need for always block
     assign tens = clamped_input / 10;
     assign units = clamped_input % 10;
endmodule