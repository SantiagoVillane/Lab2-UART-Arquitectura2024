`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.10.2024 21:22:16
// Design Name: 
// Module Name: uart_rx
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


module uart_rx
#(
    parameter DATA_LEN = 8,
    parameter SB_TICK = 16

  )
  (
    input wire i_data_rx,
    input wire i_clock,
    input wire i_tick,
    input wire i_reset,
    
    output wire[DATA_LEN-1:0] o_data, 
    output reg o_rx_done   
  );
  
  localparam [1:0] IDLE_STATE = 2'b00;
  localparam [1:0] START_STATE = 2'b01;
  localparam [1:0] READ_DATA_STATE = 2'b10;
  localparam [1:0] STOP_STATE = 2'b11;
  
  reg[1:0] reg_actual_sate;
  reg[1:0] next_actual_sate;
  
  reg[3:0] reg_ticks_counter;
  reg[3:0] reg_next_ticks_counter;
  reg[DATA_LEN-1:0] reg_bitsRxCounter;
  reg[DATA_LEN-1:0] reg_nextBitsRxCounter; 
endmodule
