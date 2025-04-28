module gmp (
     input wire clk,    // PIN_43
     input wire rst,    // PIN_14
     output wire o_clk, // PIN_24
     output reg [6:0] led,          
     input wire [6:0] switch,      
     output wire [3:0] bcd_tens,   
     output wire [3:0] bcd_units   
);
     assign o_clk = clk; // for debugging purposes

     reg [7:0] current_output;      
     reg [4:0] lfsr_reg;            
     reg [3:0] counter;             
     reg [7:0] sum;           

     // Instantiate BCD converter for 7-segment display
     binary_to_bcd bcd_inst (
         .binary_in(current_output),
         .tens(bcd_tens),
         .units(bcd_units)
     );
     
     // Each cycle is 1sec, due to 1Hz frequency
     // Phase 1: Random number generation (cycles 0-3)
     // Phase 2: Display clearing (cycle 4)
     // Phase 3: User input (cycles 5-10)
     // Phase 4: Result checking (cycles 11-14)
     // Phase 5: Game reset (cycle 15)
     always @(posedge clk or posedge rst) begin
         if (rst) begin
             current_output <= 0;
             lfsr_reg <= 5'b10101;  
             led <= 7'b0000000;
             counter <= 0;
             sum <= 0;
         end else begin
            counter <= counter + 1; // Increment cycle counter
            
             if (counter < 4'd4) begin 
                lfsr_reg <= {lfsr_reg[3:0], lfsr_reg[4] ^ lfsr_reg[2]};
                current_output <= {3'b000, lfsr_reg};
                led <= {lfsr_reg, 2'b00};
                sum <= sum + {3'b000, lfsr_reg}; 
             end 
             else if (counter == 4'd4) begin 
                 current_output <= 8'b00000000;
             end 
             else if (counter > 4'd4 && counter <= 4'd10) begin 
                 current_output <= {1'b0, switch};
             end 
             else if (counter > 4'd10 && counter < 4'd12) begin 
                 current_output <= (sum % 100);
                 // sum checking
                 if ({1'b0, switch} == (sum % 100)) begin 
                    led <= 7'b1111111; // All LEDs 
                 end
                 else begin
                    led <= 7'b1010101; // some differnt pattern 
                 end
             end 
             else if (counter == 4'd15) begin 
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
     output wire [3:0] tens,    
     output wire [3:0] units        
);

     wire [7:0] clamped_input = (binary_in > 8'd99) ? 8'd99 : binary_in;

     assign tens = clamped_input / 10;   
     assign units = clamped_input % 10; 
endmodule