`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.12.2024 20:57:55
// Design Name: 
// Module Name: Test_Bench_INTERFACE
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


module Test_Bench_INTERFACE();


  // Parámetros
  parameter NB_DATA = 8;
  parameter NB_OP = 6;

  // Señales de entrada
  reg i_clk;
  reg i_reset;
  reg i_rx_done;
  reg i_tx_done;
  reg [NB_DATA-1:0] i_rx_data;

  // Señales de salida
  wire [NB_DATA-1:0] o_tx_data;
  wire [NB_OP-1:0] o_alu_op;
  wire [NB_DATA-1:0] o_alu_dataA;
  wire [NB_DATA-1:0] o_alu_dataB;
  wire o_tx_enable;

  // Resultado de la ALU
  wire signed [NB_DATA-1:0] o_result;

  // Instancia del DUT (Device Under Test)
  INTERFACE #(
    .DATA_LENGTH(NB_DATA),
    .OP_LENGTH(NB_OP)
  ) uut (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_rx_done(i_rx_done),
    .i_tx_done(i_tx_done),
    .i_rx_data(i_rx_data),
    .i_alu_result(o_result),
    .o_tx_data(o_tx_data),
    .o_data_A(o_alu_dataA),
    .o_data_B(o_alu_dataB),
    .output_operation(o_alu_op),
    .o_tx_enable(o_tx_enable)
  );

  // Instancia de tu ALU personalizada
  ALU #(
    .NB_OP(NB_OP),
    .NB_DATA(NB_DATA)
  ) u_alu (
    .i_data_a(o_alu_dataA),      // Dato A desde la INTERFACE
    .i_data_b(o_alu_dataB),      // Dato B desde la INTERFACE
    .i_op(o_alu_op),             // Operación desde la INTERFACE
    .o_data(o_result)            // Resultado de la operación
  );

  // Generar un reloj de 20ns (50 MHz)
  always begin
    #5 i_clk = ~i_clk;
  end

  // Inicialización de señales y estímulos
  initial begin
    // Configuración inicial
    i_clk = 0;
    i_reset = 1;
    i_rx_done = 0;
    i_rx_data = 0;
    i_tx_done = 0;

    // Reset del sistema
    #100;
    i_reset = 0;

    // Cargar Dato A
    #40;
    i_rx_done = 1;
    i_rx_data = 8'b00000101; // Ejemplo: Dato A = 5
    #40;
    i_rx_done = 0;

    // Cargar Dato B
    #40;
    i_rx_done = 1;
    i_rx_data = 8'b00000011; // Ejemplo: Dato B = 3
    #40;
    i_rx_done = 0;

    // Cargar Operación
    #40;
    i_rx_done = 1;
    i_rx_data = 8'b100000; // Operación Suma (`6'b100000`)
    #40;
    i_rx_done = 0;

    // Esperar el resultado de la ALU
    #2000;

  end

  // Monitoreo de señales principales
  initial begin
    $monitor("Time: %0t | State: %b | Counter: %d | ALU Op: %h | ALU DataA: %h | ALU DataB: %h | TX Enable: %b | TX Data: %h",
             $time, uut.state, uut.op_count, o_alu_op, o_alu_dataA, o_alu_dataB, o_tx_enable, o_tx_data);
  end
  // Monitoreo de la señal tx_done para finalizar la simulación
   always @(posedge i_clk) begin
      if (o_tx_enable == 1'b1) begin
      #100
        // Comprobamos si el dato se transmite correctamente
        $display("Transmitiendo: %h", o_tx_data);
        $finish;
        end
          // Comprobar el resultado de la ALU
//    #200;
//    if (o_tx_data !== o_result) begin
//      $display("Error: o_tx_data = %h, expected = %h", o_tx_data, o_result);
//    end else begin
//      $display("Test Passed: o_tx_data = %h, expected = %h", o_tx_data, o_result);
        end
//         $display("------ Fin ! ------");
//          #2000; //se simula la transimision
         
    //   $finish;
//      end
//   end


endmodule


