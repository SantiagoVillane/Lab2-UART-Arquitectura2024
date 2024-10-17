`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2024 11:47:34 PM
// Design Name: 
// Module Name: TX_UART
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

module TX_UART
#(
    parameter   DATA_LENGTH = 8,           //# Numero de bits de información
                SB_TICK = 16        //# Numero de ticks para que frene. El cual es 16, 24 y 32 para 1, 1.5 y 2 bits de stop respectivamente.
)
(
    input wire i_clck, i_reset,     // Reloj del sistema y señal de reset
    input wire i_tx_start,          // Señal para iniciar la transmisión
    input wire i_s_tick,
    input wire [DATA_LENGTH-1: 0] i_tx_data,   // Dato a transmitir
    output reg o_tx_done_tick,      
    output wire o_tx                // Salida de datos UART (Tx)
);


    localparam [1:0]
        idle    =   2'b00,
        start   =   2'b01,
        data    =   2'b10,
        stop    =   2'b11; 
    
    
    reg [1:0]   state_reg, state_next;
    reg [3:0]   s_reg, s_next;
    reg [2:0]   n_reg, n_next;
    reg [DATA_LENGTH-1:0]   b_reg, b_next;
    reg tx_reg, tx_next;
    

    always @(posedge i_clck, posedge i_reset)
        if (i_reset)
            begin
                state_reg <= idle;
                s_reg <= 0;
                n_reg <= 0;
                b_reg <= 0;
                tx_reg <= 1'b1;
            end
        else
            begin
                state_reg <= state_next;
                s_reg <= s_next;
                n_reg <= n_next;
                b_reg <= b_next;
                tx_reg <= tx_next;
            end     


    always @(*)
        begin
            state_next = state_reg;
            o_tx_done_tick = 1'b0;
            s_next = s_reg;
            n_next = n_reg;
            b_next = b_reg;
            tx_next = tx_reg;

            case(state_reg)
                idle:
                    begin
                        tx_next = 1'b1;
                        if(i_tx_start)
                            begin
                                state_next = start;
                                s_next = 0;
                                b_next = i_tx_data;
                            end
                    end
                start:
                    begin
                        tx_next = 1'b0;
                        if(i_s_tick)
                            if(s_reg == 15)
                                begin
                                    state_next = data;
                                    s_next = 0;
                                    n_next = 0;
                                end
                            else
                                s_next = s_reg + 1;    
                    end
                data:
                    begin
                        tx_next = b_reg[0];
                        if(i_s_tick)
                            if(s_reg == 15)
                                begin
                                    s_next = 0;
                                    b_next = b_reg >> 1;
                                    if(n_reg == (DATA_LENGTH - 1))
                                        state_next = stop;
                                    else
                                        n_next = n_reg + 1;
                                end
                             else
                                s_next = s_reg + 1;   
                    end
                stop:
                    begin
                        tx_next = 1'b1;
                        if(i_s_tick)
                            if(s_reg == (SB_TICK-1))
                                begin
                                    state_next = idle;
                                    o_tx_done_tick = 1'b1;
                                end            
                            else    
                                s_next = s_reg + 1;
                    end
            endcase                
        end

    assign o_tx = tx_reg;


endmodule