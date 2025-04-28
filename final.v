module gmp (
     input wire clk,                // Clock input
     input wire rst,                // Reset input (active high)
     output wire o_clk,             // Clock output for external components
     output reg [6:0] led,          // 7-bit LED output
     input wire [6:0] switch,       // 7-bit switch input
     output wire [3:0] bcd_tens,    // Tens place for 7-segment display
     output wire [3:0] bcd_units    // Units place for 7-segment display
);
     // Pass through clock signal
     assign o_clk = clk;

     // Signal declarations
     reg [7:0] current_output;      // Current value to display
     reg [4:0] lfsr_reg;            // 5-bit Linear Feedback Shift Register for random number generation
     reg [3:0] counter;             // 4-bit cycle counter (0-15)
     reg [7:0] sum;                 // Sum of random numbers generated

     // Instantiate BCD converter for 7-segment display
     binary_to_bcd bcd_inst (
         .binary_in(current_output),
         .tens(bcd_tens),
         .units(bcd_units)
     );

     // Game state machine - controlled by clock and reset
     // Each cycle is 1sec, due to 1Hz frequency
     // Phase 1: Random number generation (cycles 0-3)
     // Phase 2: Display clearing (cycle 4)
     // Phase 3: User input (cycles 5-10)
     // Phase 4: Result checking (cycles 11-14)
     // Phase 5: Game reset (cycle 15)
     always @(posedge clk or posedge rst) begin
         if (rst) begin
             // Initialize all registers on reset
             current_output <= 0;
             lfsr_reg <= 5'b10101;  // Non-zero seed for random number generation
             led <= 7'b0000000;     // All LEDs off
             counter <= 0;
             sum <= 0;
         end else begin
            counter <= counter + 1; // Increment cycle counter
            
             if (counter < 4'd4) begin 
                // Phase 1 (cycles 0-3): Generate random numbers
                // Update LFSR with XOR feedback
                lfsr_reg <= {lfsr_reg[3:0], lfsr_reg[4] ^ lfsr_reg[2]};
                // Display random value (0-31)
                current_output <= {3'b000, lfsr_reg};
                // Show random pattern on LEDs
                led <= {lfsr_reg, 2'b00};
                // Accumulate sum of random values
                sum <= sum + {3'b000, lfsr_reg}; 
             end
             else if (counter == 4'd4) begin 
                 // Phase 2 (cycle 4): Clear display before input phase
                 current_output <= 8'b00000000;
             end else if (counter > 4'd4 && counter <= 4'd10) begin 
                 // Phase 3 (cycles 5-10): Accept user input
                 // Display switch value for user to enter answer
                 current_output <= {1'b0, switch};
             end else if (counter > 4'd10 && counter < 4'd12) begin 
                 // Phase 4 (cycles 11-14): Show result and check answer
                 // Display the correct answer (sum modulo 100)
                 current_output <= (sum % 100);
                 // Check if user input matches correct answer
                 if ({1'b0, switch} == (sum % 100)) begin
                    led <= 7'b1111111; // All LEDs on indicates correct answer
                 end
                 else begin
                    led <= 7'b1010101; // Alternating pattern indicates incorrect answer
                 end
             end else if (counter == 4'd15) begin 
                 // Phase 5 (cycle 15): Prepare for next round
                 led <= 7'b1111111;    // Flash all LEDs
                 counter <= 0;         // Reset cycle counter
                 current_output <= 0;  // Clear display
                 sum <= 0;             // Reset sum for next round
             end
             else begin
                 // Default state (should not normally be reached)
                 current_output <= 0; 
                 led <= 7'b0000000; 
             end
         end
     end
endmodule

module binary_to_bcd (
     input  wire [7:0] binary_in,   // 8-bit binary input (0-255)
     output wire [3:0] tens,        // Tens digit (0-9)
     output wire [3:0] units        // Units digit (0-9)
);
     // No clamping needed since modulo operation handles overflow
     wire [7:0] clamped_input = binary_in;

     // Convert binary to BCD using division and modulo
     assign tens = clamped_input / 10;   
     assign units = clamped_input % 10; 
endmodule