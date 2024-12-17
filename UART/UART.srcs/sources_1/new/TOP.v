`timescale 1ns / 1ps
module TOP
#(
    parameter NB_DATA = 8,    // Longitud de los datos
    parameter NB_OP = 6,      // Longitud del código de operación
    parameter SB_TICK = 16,   // Ticks para el bit de STOP (ajustable según baud rate)
    parameter FREQ_CLK = 50E6, // Frecuencia del reloj principal (50 MHz)
    parameter BAUD_RATE = 19200 // Baud rate para UART
)
(
    input wire i_clk,             // Reloj principal
    input wire i_reset,           // Señal de reset global
    input wire i_rx,              // Entrada UART RX
    output wire o_tx,             // Salida UART TX
    output wire [NB_DATA-1:0] result_leds // Resultado para visualizar en los leds 
);

    // Señales internas
    wire [NB_DATA-1:0] rx_data, tx_data, alu_result;
    wire [NB_DATA-1:0] alu_data_a, alu_data_b;
    wire [NB_OP-1:0] alu_op;
    wire rx_done, tx_done, tx_enable;
    wire s_tick;
    assign result_leds = alu_result; // Asigno resultado a LEDS 
    // Generador de baud rate
    BAUD_RATE_GENERATOR #(
        .FREQ_CLK(FREQ_CLK),
        .BAUD_RATE(BAUD_RATE)
    ) baud_gen (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .o_tick(s_tick)
    );

    // UART RX
    RX_UART #(
        .DATA_LENGTH(NB_DATA),
        .SB_TICK(SB_TICK)
    ) uart_rx (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_rx(i_rx),
        .i_s_tick(s_tick),
        .o_rx_ready(rx_done),
        .o_rx_data(rx_data)
    );

    // INTERFACE
    INTERFACE #(
        .DATA_LENGTH(NB_DATA),
        .OP_LENGTH(NB_OP)
    ) interface (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_rx_done(rx_done),
        .i_tx_done(tx_done),
        .i_rx_data(rx_data),
        .i_alu_result(alu_result),
        .o_tx_data(tx_data),
        .o_data_A(alu_data_a),
        .o_data_B(alu_data_b),
        .output_operation(alu_op),
        .o_tx_enable(tx_enable)
    );

    // ALU
    ALU #(
        .NB_OP(NB_OP),
        .NB_DATA(NB_DATA)
    ) alu (
        .i_data_a(alu_data_a),
        .i_data_b(alu_data_b),
        .i_op(alu_op),
        .o_data(alu_result)
    );

    // UART TX
    TX_UART #(
        .DATA_LENGTH(NB_DATA),
        .SB_TICK(SB_TICK)
    ) uart_tx (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_start_tx(tx_enable),
        .i_s_tick(s_tick),
        .i_tx_data(tx_data),
        .o_tx_done(tx_done),
        .o_tx(o_tx)
    );

    
endmodule
