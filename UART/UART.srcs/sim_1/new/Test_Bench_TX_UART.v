`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.12.2024 21:04:44
// Design Name: 
// Module Name: Test_Bench_TX_UART
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


module Test_Bench_TX_UART();

// Parámetros del diseño
    parameter CLOCK_FREQ = 50E6; // Frecuencia del reloj (50 MHz)
   // parameter CLOCK_FREQ = 100E6;
    parameter BAUD_RATE = 9600;        // Baud rate
    parameter DATA_LENGTH = 8;         // Longitud de los datos (8 bits)
    parameter SB_TICK = 16;            // Ticks para el bit de parada

    // Señales del testbench
    reg clk;
    reg reset;
    reg start_tx;
    reg s_tick;
    reg [DATA_LENGTH-1:0] tx_data;
    wire tx;
    wire tx_done;

    // Instanciar el módulo bajo prueba (DUT)
    TX_UART #(
        .DATA_LENGTH(DATA_LENGTH),
        .SB_TICK(SB_TICK)
    ) uut (
        .i_clk(clk),
        .i_reset(reset),
        .i_start_tx(start_tx),
        .i_s_tick(s_tick),
        .o_tx_done(tx_done),
        .o_tx(tx),
        .i_tx_data(tx_data)
    );

    // Generador de ticks para simular el generador de baud rate
    localparam TICK_PERIOD = (CLOCK_FREQ / (BAUD_RATE * SB_TICK));
    reg [31:0] tick_counter;

    always @(posedge clk) begin
        if (reset) begin
            tick_counter <= 0;
            s_tick <= 0;
        end else if (tick_counter == (TICK_PERIOD - 1)) begin
            tick_counter <= 0;
            s_tick <= 1'b1; // Generar un tick
        end else begin
            tick_counter <= tick_counter + 1;
            s_tick <= 1'b0;
        end
    end

    // Generador de reloj (50 MHz)
    always #10 clk = ~clk;

    // Proceso inicial para aplicar estímulos
    initial begin
        // Inicializar señales
        clk = 0;
        reset = 1;
        start_tx = 0;
        tx_data = 8'b10101011; // Dato a transmitir
        tick_counter = 0;

        #100 reset = 0; // Desactivar reset después de 100 ns

        // Iniciar la transmisión del primer dato
        #100 start_tx = 1;
        #20 start_tx = 0; // Pulso corto para iniciar la transmisión

        // Esperar a que se complete la transmisión
        wait(tx_done);
        #100;

        // Iniciar la transmisión de un segundo dato
        tx_data = 8'b11001100;
        #100 start_tx = 1;
        #20 start_tx = 0;

        // Esperar a que se complete la segunda transmisión
        wait(tx_done);
        #100;
        
    
    end
    

    // Monitor para observar las señales clave
    initial begin
        $monitor("Time: %0t | State: %b | TX: %b | TX Done: %b | TX Data: %b", 
                 $time, uut.state, tx, tx_done, uut.shift_reg);
    end
 
endmodule
