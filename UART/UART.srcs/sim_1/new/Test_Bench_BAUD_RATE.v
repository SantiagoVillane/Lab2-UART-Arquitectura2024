`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.12.2024 21:01:47
// Design Name: 
// Module Name: Test_Bench_BAUD_RATE
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


module Test_Bench_BAUD_RATE();

// Parámetros
    parameter FREQ_CLK = 100E6; // Frecuencia del reloj (100 MHz)
    parameter BAUD_RATE = 9600;       // Baud rate

    // Señales
    reg i_clock;
    reg i_reset;
    wire o_tick;

    // Instancia del módulo bajo prueba
    BAUD_RATE_GENERATOR #(
        .FREQ_CLK(FREQ_CLK),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .i_clk(i_clock),
        .i_reset(i_reset),
        .o_tick(o_tick)
    );

    // Generación del reloj
    always #5 i_clock = ~i_clock; // Reloj de 100 MHz -> Periodo de 10 ns

    // Proceso inicial para aplicar estímulos
    initial begin
        i_clock = 1'b0; // Inicializar reloj
        i_reset = 1'b1; // Activar reset
        
        #20; // Mantener reset activo por 20 ns
        i_reset = 1'b0; // Desactivar reset
        
        // Ejecutar simulación por tiempo suficiente para observar varios ticks
        #110000; // 110 µs (suficiente para observar múltiples ciclos de o_tick)
        $finish; // Finalizar simulación
    end

    // Monitoreo de señales y parámetros
    initial begin
        // Mostrar parámetros calculados
        $display("DIVISOR calculado: %d", uut.DIVISOR);
        $monitor("Time: %0t ns | Reset: %b | Counter: %d | o_tick: %b", 
                 $time, i_reset, uut.counter, o_tick);
    end
endmodule
