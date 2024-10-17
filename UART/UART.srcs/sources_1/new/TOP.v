`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2024 05:18:34 PM
// Design Name: 
// Module Name: TOP
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


module TOP
#(
    parameter   DATA_LEN = 8,
                OP_LEN = 6 
)
(
    input wire  i_clk,                           // Reloj del sistema
    input wire  i_rst,                           // Señal de reset
    input wire  i_rx,                            // Entrada de datos UART (Rx)
    output wire o_tx                            // Salida de datos UART (Tx)
);

    reg [DATA_LEN - 1 : 0] reg_rx;
    
    
    
    reg [DATA_LEN - 1 : 0] reg_data_A;
    reg [DATA_LEN - 1 : 0] reg_data_B;
    reg [DATA_LEN - 1 : 0] reg_resultado;
    reg [OP_LEN - 1 : 0] reg_op;
    reg [1:0]   state_reg, state_next;
    wire o_rx_ready, i_tx_start,o_tx_done_tick;
    
    localparam [2:0]
        idle            =   3'b000,
        read_param_a    =   3'b001,
        read_param_b    =   3'b010,
        read_op         =   3'b011,
        tx_rtdo         =   3'b100;
    
    
    INTERFACE #(
        .DATA_LENGTH(DATA_LEN)
    )
    interface (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_rx(i_rx),
        .o_rx_ready(o_rx_ready),
        .o_rx_data(reg_rx),
        .i_tx_data(reg_resultado),
        .i_tx_start(i_tx_start),
        .o_tx_done_tick(o_tx_done_tick),
        .o_tx(o_tx)
    );
    
    
    ALU #(
        .NB_OP(OP_LEN),
        .NB_DATA(DATA_LEN)
    )
    alu(
        .i_data_a(reg_data_A),
        .i_data_b(reg_data_B),
        .i_op(reg_op),
        .o_data(reg_resultado)
    );
    
    always @(posedge i_clk, posedge i_rst)
        if (i_rst)
            begin
                state_reg <= idle;
                reg_data_A <= {(DATA_LEN) {1'b0}};
                reg_data_B <= {(DATA_LEN) {1'b0}};
                reg_op <= {(OP_LEN) {1'b0}};
            end
        else
            begin
                state_reg <= state_next;
                reg_data_A <= reg_data_A;
                reg_data_B <= reg_data_B;
                reg_op <= reg_op;           
            end
    
    always@(*) 
        begin
            state_next = state_reg;
            case(state_reg)
                idle:
                read_param_a:
                read_param_b:
                read_op:
                tx_rtdo:
                 
        end
    

endmodule
