`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2024 11:47:34 PM
// Design Name: 
// Module Name: INTERFACE
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


module INTERFACE
#(
    parameter DATA_LENGTH = 8
)
(
    input wire i_clk,                           // Reloj del sistema
    input wire i_rst,                           // Señal de reset
    
    input wire i_rx,                            // Entrada de datos UART (Rx)
    output wire o_rx_ready,                     // Señal que indica que se ha recibido un dato
    output wire [DATA_LENGTH-1:0] o_rx_data,    // Dato recibido
    
    
    input wire [DATA_LENGTH-1:0] i_tx_data,     // Dato a transmitir
    input wire i_tx_start,                      // Señal para iniciar la transmisión
    output wire o_tx_done_tick,                 // Señal que indica si la transmisión finalizo
    output wire o_tx                            // Salida de datos UART (Tx)    
);


    // Señal que marca el tick del generador de baudios
    wire baud_tick;

    // Instancia del generador de baudios
    baud_generator BAUD_RATE_GENERATOR (
        .clk(i_clk),
        .rst(i_rst),
        .baud_tick(baud_tick)
    );

    // Instancia del transmisor UART
    uart_transmitter TX_UART (
        .i_clck(i_clk),
        .i_reset(i_rst),
        .i_s_tick(baud_tick),
        .i_tx_data(i_tx_data),
        .i_tx_start(i_tx_start),
        .o_tx(o_tx),
        .o_tx_done_tick(o_tx_done_tick)
    );

    // Instancia del receptor UART
    uart_receiver receiver (
        .i_clck(i_clk),
        .i_reset(i_rst),
        .i_s_tick(baud_tick),
        .i_rx(i_rx),
        .o_rx_ready(o_rx_ready),
        .o_rx_data(o_rx_data)
    );

endmodule