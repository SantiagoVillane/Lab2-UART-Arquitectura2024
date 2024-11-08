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
    output wire o_tx,                           // Salida de datos UART (Tx)
    output wire [DATA_LEN-1:0] result_leds
);

    wire [DATA_LEN - 1 : 0] reg_rx;
    wire [DATA_LEN - 1 : 0] reg_data_a;
    wire [DATA_LEN - 1 : 0] reg_data_b;
    wire [OP_LEN - 1 : 0] reg_op;
    
    
    localparam READ_A_STATE=2'b00;
    localparam READ_B_STATE=2'b01;
    localparam READ_OPREATION_CODE_STATE=2'b10;
    localparam CALCULATE_STATE=2'b11;
    
    reg [1:0] reg_actualState,reg_nextActualState;
    
    reg [DATA_LEN-1:0] o_reg_dataA,o_reg_nextDataA;
    reg [DATA_LEN-1:0] o_reg_dataB,o_reg_nextDataB;
    reg [OP_LEN-1:0] o_reg_operationCode,o_reg_nextOperationCode;
    reg [DATA_LEN-1:0] o_reg_aluResultData,o_reg_nextAluResultData;
    reg o_reg_txStart,o_reg_nextTxStart;
    
    wire[DATA_LEN-1:0] reg_resultado; 
    assign result_leds = reg_resultado;
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
    
    always@(posedge i_clk) begin
         if(i_rst) begin 
            reg_actualState<=READ_A_STATE;
            o_reg_dataA<=0;
            o_reg_dataB<=0;
            o_reg_operationCode<=0;
            o_reg_aluResultData<=0;
            o_reg_txStart<=0;
        end
        else begin
            reg_actualState<=reg_nextActualState;
            o_reg_dataA<=o_reg_nextDataA;
            o_reg_dataB<=o_reg_nextDataB;
            o_reg_operationCode<=o_reg_nextOperationCode;
            o_reg_aluResultData<=o_reg_nextAluResultData;
            o_reg_txStart<=o_reg_nextTxStart;
            
        end
    end
    
    always@(*) begin
         reg_nextActualState=reg_actualState;
         o_reg_nextDataA=o_reg_dataA;
         o_reg_nextDataB=o_reg_dataB;
         o_reg_nextOperationCode=o_reg_operationCode;
         o_reg_nextAluResultData=o_reg_aluResultData;
         //o_reg_nextData=o_reg_data;
         //o_reg_nextTxStart=o_reg_txStart;
         
         
         o_reg_nextTxStart=0;
         //if(i_rxDone) begin
         //if( i_tick) begin 
            if(o_rx_ready && reg_actualState==READ_A_STATE) begin
                //o_reg_nextTxStart=0;//NO SE SI VA AHI XD
                o_reg_nextDataA=reg_rx;
                reg_nextActualState=READ_B_STATE;
            end
            else if (o_rx_ready && reg_actualState==READ_B_STATE) begin
                o_reg_nextDataB=reg_rx;
                reg_nextActualState=READ_OPREATION_CODE_STATE;
            
            end
            else if (o_rx_ready && reg_actualState==READ_OPREATION_CODE_STATE) begin
                o_reg_nextOperationCode=reg_rx[OP_LEN-1:0];
                reg_nextActualState=CALCULATE_STATE;
                //reg_nextActualState=READ_A_STATE;
                //o_reg_nextTxStart=1;
                //o_reg_nextAluResultData=i_dataAluResult;
            end
            else if (reg_actualState==CALCULATE_STATE) begin
                 o_reg_nextAluResultData=reg_resultado;
                 reg_nextActualState=READ_A_STATE;
                 o_reg_nextTxStart=1;
            end
         //end
    end
    assign reg_data_A=o_reg_dataA;
    assign reg_data_B=o_reg_dataB;
    assign reg_op=o_reg_operationCode;
    //assign o_data=o_reg_data;
    //assign o_data=reg_resultado;
    //assign o_data=i_data;
    assign o_txStart = o_reg_txStart;
    

endmodule
