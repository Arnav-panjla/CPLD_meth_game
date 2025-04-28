module ell201_project (
     input wire clk,
     input wire rst, // SW8 PIN 14
     output wire o_clk,
     output reg [6:0] led, 
     input wire [6:0] switch,
     output wire [3:0] bcd_tens,
     output wire [3:0] bcd_units
);
    // Game flow:
    // 1. Initially rst is high - user inputs number of rounds (1-8)
    // 2. When rst goes low, game starts with user-defined rounds
    // 3. Generate random numbers for specified rounds
    // 4. Display switch input for next 15 cycles
    // 5. Check answer and display result
    // 6. Reset and start over
    
    // Direct clock pass-through
    assign o_clk = clk;

    // Signal declarations
    reg [7:0] current_output;
    reg [4:0] lfsr_reg;        // LFSR register
    reg [4:0] counter;         // Game cycle counter
    reg [7:0] sum;             // Increased to 10 bits to prevent overflow
    reg [3:0] rounds;          // User-defined number of rounds (1-8)
    reg [3:0] round_counter;   // Counts rounds completed
    reg game_started;          // Flag to track if game has started

    // Instantiate BCD Converter
    binary_to_bcd bcd_inst (
        .binary_in(current_output),
        .tens(bcd_tens),
        .units(bcd_units)
    );

    // Clamp switch value to range 1-8
    wire [2:0] clamped_switch = (switch[2:0] < 3'd3) ? 3'd3 : switch[3:0];

    // Control Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Setup phase - user defines number of rounds
            current_output <= {4'b0000, clamped_switch};  // Display clamped switch value
            led <= {clamped_switch, 4'b0000};        
            lfsr_reg <= 5'b10101;                         // Non-zero seed
            counter <= 0;
            sum <= 0;
            round_counter <= 0;
            game_started <= 0;                           // Game hasn't started yet
        end else begin
            if (!game_started) begin
                // First cycle after rst goes low - store rounds and start game
                rounds <= clamped_switch;
                game_started <= 1;
                counter <= 0;
            end else begin
                // Game is running
                counter <= counter + 1;
                
                if (round_counter < rounds && counter < 5'd5) begin
                    // Generate random numbers for user-defined rounds
                    lfsr_reg <= {lfsr_reg[3:0], lfsr_reg[4] ^ lfsr_reg[2]};
                    current_output <= {3'b000, lfsr_reg};
                    led <= {lfsr_reg, 2'b00};
                    sum <= sum + {3'b000, lfsr_reg};
                    
                    if (counter == 5'd4) begin
                        // End of a round
                        round_counter <= round_counter + 1;
                        counter <= 0;
                    end
                end
                else if (round_counter == rounds && counter == 5'd0) begin
                    // All rounds completed - clear output and move to input phase
                    current_output <= 8'b00000000;
                    counter <= counter + 1;
                end
                else if (round_counter == rounds && counter > 5'd0 && counter <= 5'd15) begin
                    // Display switch value for 15 cycles after random number generation
                    current_output <= {1'b0, switch};
                end
                else if (round_counter == rounds && counter > 5'd15 && counter < 5'd20) begin
                    // Check output and display result
                    current_output <= (sum % 100); // Display the correct sum
                    if ({1'b0, switch} == (sum % 100)) begin
                        led <= 7'b1111111; // All LEDs on for correct answer
                    end
                    else begin
                        led <= 7'b1010101; // Pattern for incorrect answer
                    end
                end
                else if (round_counter == rounds && counter == 5'd20) begin
                    // Reset game
                    current_output <= 0;
                    led <= 7'b0000000;
                    counter <= 0;
                    sum <= 0;
                    round_counter <= 0;
                    game_started <= 0; // Return to initial state requiring rst
                end
                else begin
                    current_output <= 0;
                    led <= 7'b0000000;
                end
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