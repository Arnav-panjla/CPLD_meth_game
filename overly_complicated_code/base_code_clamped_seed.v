module ell201_project (
     input wire clk,
     input wire rst,
     output wire o_clk, // one led assigned to o_clk
     output reg [6:0] led, 
     input wire [6:0] switch,
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
             lfsr_reg <= (switch[4:0] == 5'b00000) ? 5'b10101 : switch[4:0]; // Non-zero seed
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
                 current_output <= {1'b0, switch};
             end else if (counter > 5'd20 && counter < 5'd25) begin 
                 // after 20 cycle check output
                 current_output <= (sum % 100); // diplaying the correct sum
                 if ({1'b0, switch} == (sum % 100)) begin
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
                 sum <= 0; 
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
    output reg  [3:0] tens,
    output wire [3:0] units
);
    // Clamp input to 0-99
    wire [6:0] clamped = (binary_in > 7'd99) ? 7'd99 : binary_in[6:0];
    
    // Determine tens digit with comparison cascade
    always @(*) begin
        if (clamped < 7'd10) tens = 4'd0;
        else if (clamped < 7'd20) tens = 4'd1;
        else if (clamped < 7'd30) tens = 4'd2;
        else if (clamped < 7'd40) tens = 4'd3;
        else if (clamped < 7'd50) tens = 4'd4;
        else if (clamped < 7'd60) tens = 4'd5;
        else if (clamped < 7'd70) tens = 4'd6;
        else if (clamped < 7'd80) tens = 4'd7;
        else if (clamped < 7'd90) tens = 4'd8;
        else tens = 4'd9;
    end
    
    // Units is just the remainder after subtracting tens*10
    assign units = clamped - (tens * 4'd10);
endmodule