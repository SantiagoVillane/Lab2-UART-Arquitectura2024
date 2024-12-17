`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.12.2024 20:52:39
// Design Name: 
// Module Name: Test_Bench_TOP
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


module Test_Bench_TOP();

  // Parámetros
  parameter NB_DATA = 8;
  parameter NB_OP = 6;
  parameter SB_TICK = 16;
  parameter FREQ_CLK = 50E6;
  parameter BAUD_RATE = 9600;

  // Señales de entrada
  reg i_clk;
  reg i_reset;
  reg i_rx;

  // Señales de salida
  wire o_tx;
  wire [NB_DATA-1:0] result_leds;

  // Instancia del DUT (Device Under Test)
  TOP #(
    .NB_DATA(NB_DATA),
    .NB_OP(NB_OP),
    .SB_TICK(SB_TICK),
    .FREQ_CLK(FREQ_CLK),
    .BAUD_RATE(BAUD_RATE)
  ) uut (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_rx(i_rx),
    .o_tx(o_tx),
    .result_leds(result_leds)
  );

  // Generar un reloj de 20ns (50 MHz)
  always begin
    #10 i_clk = ~i_clk;
  end

  // Proceso de simulación: Enviar datos UART y verificar resultado
  initial begin
    // Inicialización de señales
    i_clk = 0;
    i_reset = 1;
    i_rx = 1; // UART línea inactiva (idle)

    // Reset del sistema
    #100;
    i_reset = 0;

    // Enviar Dato A: 8'b00000101 (5)
    uart_send(8'b00000101);

    // Enviar Dato B: 8'b00000011 (3)
    uart_send(8'b00000011);

    // Enviar Operación: 6'b100000 (Suma)
    uart_send(8'b00100000);

    // Esperar que el sistema procese y transmita el resultado
    #500000; // Tiempo suficiente para la operación completa

    $stop;
  end

  // Tarea para enviar datos simulados a través de UART RX
  task uart_send;
    input [7:0] data;
    integer i;
    begin
      // Enviar bit de inicio (start bit)
      i_rx = 0; // Start bit
      #(SB_TICK * 104166 / FREQ_CLK); // Tiempo de un bit UART

      // Enviar 8 bits de datos (LSB primero)
      for (i = 0; i < 8; i = i + 1) begin
        i_rx = data[i];
        #(SB_TICK * 104166 / FREQ_CLK);
      end

      // Enviar bit de parada (stop bit)
      i_rx = 1; // Stop bit
      #(SB_TICK * 104166 / FREQ_CLK);
    end
  endtask

  // Monitoreo de señales principales
  initial begin
    $monitor("Time: %0t | LEDs: %b | RX: %b | TX: %b | ALU Result: %b",
             $time, result_leds, i_rx, o_tx, uut.alu_result);
  end

endmodule

