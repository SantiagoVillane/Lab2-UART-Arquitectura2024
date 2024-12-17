`timescale 1ns / 1ps

module BAUD_RATE_GENERATOR
    #(
        //parameter NB_COUNTER = 9,        // Width of the counter (in bits)
        parameter FREQ_CLK = 50E6, // Frecuencia del reloj principal (100 MHz)
        parameter BAUD_RATE = 19200      // Baud rate deseado
        
    )
    (
        input wire i_clk,           // Reloj principal (100 MHz)
        input wire i_reset,         // Reset sincrónico
        output wire o_tick      // Pulso de baud rate
    );
    
    localparam integer DIVISOR = FREQ_CLK / (BAUD_RATE*16); // Cálculo del divisor
    localparam integer NB_COUNTER = $clog2(DIVISOR);

    // Internal counter register (holds the current count value)
    reg [NB_COUNTER-1 : 0] counter;
    // Next counter value (calculated each clock cycle)
    wire [NB_COUNTER-1 : 0] counter_next;

    always @(posedge i_clk) begin
        if (i_reset) begin
            counter <= 0;
          //  o_tick <= 0;
        end else if (counter == DIVISOR - 1) begin
            counter <= 0;
          //  o_tick <= 1; // Generar pulso de baud rate
        end else begin
            counter <= counter_next;
            //o_tick <= 0;
        end
    end
    
    // Calculate the next value of the counter
    // If counter reaches the COUNTER_LIMIT, reset to 0; otherwise, increment
    assign counter_next = (counter == (DIVISOR-1)) ? 0 : counter + 1;
    assign o_tick = (counter == (DIVISOR-1)) ? 1'b1 : 1'b0;
endmodule
