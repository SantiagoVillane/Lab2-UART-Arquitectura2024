`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2024 11:47:34 PM
// Design Name: 
// Module Name: BAUD_RATE_GENERATOR
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module BAUD_RATE_GENERATOR 
#(
    parameter   BAUD_RATE = 9600,                       //bits/sec 
    parameter   CLOCK_FREQUENCY_MHZ = 100.0,            //MHZ
    parameter   MHZ_TO_HZ_CONVERSION_FACTOR = 1000000
)
(
    input wire clk,            // Reloj del sistema
    input wire rst,            // Señal de reset
    output reg baud_tick       // Señal de tick de baudios
);

    localparam integer NUMBER_OF_STEPS = (CLOCK_FREQUENCY_MHZ * MHZ_TO_HZ_CONVERSION_FACTOR) / (BAUD_RATE * 16);

    // Registro para contar los ciclos del reloj
    reg [$clog2(NUMBER_OF_STEPS)-1:0] counter; 

    always @(posedge clk or posedge rst) 
        begin
            if (rst) 
                begin
                    counter <= 0;
                    baud_tick <= 0;
                end 
            else 
                begin
                    if (counter == NUMBER_OF_STEPS - 1) 
                        begin
                            counter <= 0;
                            baud_tick <= 1; // Generar el tick
                        end 
                    else 
                        begin
                            counter <= counter + 1;
                            baud_tick <= 0;
                        end
                end
        end

endmodule
