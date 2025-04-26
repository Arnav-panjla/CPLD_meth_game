module ell201_project (
     input wire clk,
     input wire rst,
     output wire o_clk, // one led assigned to o_clk
     output reg [6:0] led, 
     input wire [7:0] switch,
     output wire [3:0] bcd_tens,
     output wire [3:0] bcd_units
);
    // For the first 5 cycles, it generates random numbers using an LFSR
    // It sums these numbers
    // It displays nothing on cycle 5
    // It displays switch input for cycles 6-20
    // For cycles 21-24, it displays the sum % 100 and checks if the user got the correct answer
    // At cycle 25, it resets the game
    
     // Direct clock pass-through
     assign o_clk = clk;

     // Signal declarations
     reg [7:0] current_output;
     reg [4:0] lfsr_reg; // LFSR register
     reg [4:0] counter;
     reg [7:0] sum;

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
             counter <= 0;
             sum <= 0;
         end else begin
            counter <= counter + 1; // Increment counter
             if (counter < 5'd5) begin 
                // Till 5 clock cycles output random numbers
                lfsr_reg <= {lfsr_reg[3:0], lfsr_reg[4] ^ lfsr_reg[2]};
                current_output <= {3'b000, lfsr_reg};
                led <= {lfsr_reg, 2'b00};
                sum <= sum + {3'b000, lfsr_reg}; 
             end
             else if (counter == 5'd5) begin 
                 // clear output at 5th cycle
                 current_output <= 8'b00000000;
             end else if (counter > 5'd5 && counter <= 5'd20) begin 
                 // display swithc value for cycles 6 to 20
                 current_output <= switch;
             end else if (counter > 5'd20 && counter < 5'd25) begin 
                 // after 20 cycle check output
                 current_output <= (sum % 100); // diplaying the correct sum
                 if (switch == (sum % 100)) begin
                    led <= 7'b1111111; // All LEDs on
                 end
                 else begin
                    led <= 7'b1010101; // some pattern to display incorrect answer
                 end
             end else if (counter == 5'd25) begin 
                 // Reset counter after 25 cycles
                 led <= 7'b1111111;
                 counter <= 0; 
                 current_output <= 0;
             end
             else begin
                 current_output <= 0; 
                 led <= 7'b0000000; 
             end
                
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