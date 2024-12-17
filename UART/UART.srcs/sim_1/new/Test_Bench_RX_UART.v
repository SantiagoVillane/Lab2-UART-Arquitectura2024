`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.12.2024 20:56:29
// Design Name: 
// Module Name: Test_Bench_RX_UART
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


module Test_Bench_RX_UART();

    // Parámetros
    parameter CLOCK = 100E6;         // Frecuencia del reloj (1.536 MHz)
    parameter BAUD_RATE = 9600;        // Baud rate
    parameter NB_DATA = 8;             // Longitud de los datos (8 bits)
    parameter SB_TICK = 16;            // Ticks para los bits de STOP

    // Señales
    reg clock;
    reg reset;
    reg i_rx;
    wire tick;
    wire rx_done;
    wire [NB_DATA-1:0] data_out;
    reg [2:0] i;

    // Datos de prueba
    localparam [NB_DATA-1:0] data_rx = 8'b10101110; // Byte de datos a transmitir

    // Instanciar el módulo RX_UART
    RX_UART #(
        .DATA_LENGTH(NB_DATA),
        .SB_TICK(SB_TICK)
    ) u_rx_uart (
        .i_clk(clock),
        .i_reset(reset),
        .i_rx(i_rx),
        .i_s_tick(tick),
        .o_rx_ready(rx_done),
        .o_rx_data(data_out)
    );

    // Instanciar el módulo BAUD_RATE_GENERATOR
    BAUD_RATE_GENERATOR #(
        .FREQ_CLK(CLOCK),
        .BAUD_RATE(BAUD_RATE)
    ) DUT (
        .i_clk(clock),
        .i_reset(reset),
        .o_tick(tick)
    );

    // Inicialización y transmisión de datos
    initial begin
        reset = 1'b1;    // Activar reset
        clock = 1'b0;    // Inicializar reloj
        i_rx = 1'b1;     // Línea RX en estado inactivo (idle)
        #20000;          // Esperar 20 us para estabilizar

        reset = 1'b0;    // Desactivar reset
        i_rx = 1'b0;     // Bit de inicio

        // Transmitir los bits de datos uno por uno (LSB primero)
     //   for (i = 0; i < NB_DATA; i = i + 1) begin
       //     #52160 i_rx = data_rx[i]; // Cada bit tarda 16 ticks (16 * periodo del tick)
       // end
       for(i = 0; i < NB_DATA-1; i = i + 1) begin
           // #52160 i_rx = data_rx[i]; // Espera 16 ticks para cada bit
            #104166 i_rx = data_rx[i];
        end 


        // Bit de parada
        #104166 i_rx = 1'b1;
        //#104166 i_rx = data_rx[i]; // Espera 16 ticks para cada bit

        // Esperar tiempo suficiente para que se complete la recepción
        #1000000;
        $stop;
    end

    // Finalizar simulación cuando se detecta el fin de la recepción
    always @(posedge clock) begin
        if (rx_done == 1) begin
            $display("------ Fin de la recepción ------");
            $display("Datos recibidos: %b", data_out);
            $finish;
        end
    end

    // Monitorear señales clave
    initial begin
    
          $monitor("Time: %0t | State: %b | Tick Count: %d | Data Count: %d | i_rx: %b | Data Out: %b | Done: %b", 
         $time, u_rx_uart.state, u_rx_uart.tick_count, u_rx_uart.data_count, i_rx, data_out, rx_done);


    end

    // Generación del reloj
 //   always #10 clock = ~clock; //Para un clock de 50MHZ
     always #5 clock = ~clock; //Para un clock de 100MHZ


endmodule

