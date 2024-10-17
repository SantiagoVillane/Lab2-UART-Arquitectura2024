`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2024 11:47:34 PM
// Design Name: 
// Module Name: RX_UART
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


module RX_UART
#(
    parameter   DATA_LENGTH = 8,           //# Numero de bits de información
                SB_TICK = 16        //# Numero de ticks para que frene. El cual es 16, 24 y 32 para 1, 1.5 y 2 bits de stop respectivamente.
)
(
    input   wire i_clck, i_reset,     // Reloj del sistema y señal de reset
    input   wire i_rx,                // Entrada de datos UART (Rx)
    input   wire i_s_tick,  
    output  reg o_rx_ready,          // Señal que indica que se ha recibido un dato
    output  wire [DATA_LENGTH-1:0] o_rx_data   // Dato recibido
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
    
    
    always @(posedge i_clck, posedge i_reset)
        if (i_reset)
            begin
                state_reg <= idle;
                s_reg <= 0;
                n_reg <= 0;
                b_reg <= 0;
            end
        else
            begin
                state_reg <= state_next;
                s_reg <= s_next;
                n_reg <= n_next;
                b_reg <= b_next;
            end    
    
    
    /*
        ETAPAS DEL PROCESO:
        El proceso de recepcion consta de 3 etapas. 
        Etapa start: correspondiente a la etapa del bit de inicio de recepción
        Etapa data: correspondiente a la recepción de la información
        Etapa stop: correspondiente a la etapa del bit de stop donde finaliza el proceso de recepción
        
        Luego tenemos una cuarta etapa. La etapa idle, que es la etapa de stand by donde el receptor espera que le llegue información.
    */    
    
    /*
        REGISTROS UTILIZADOS:
        Registros s: son los que mantienen la cuenta de cuantos stick pasaron para saber si se debe pasar a la siguiente etapa o no. 
        Estos registros cuentan hasta 7 en la etapa start, luego hasta 15 en la etapa data y finalmente hasta SB_TICK en la etapa de stop.
        
        Registros n: Mantienen la cuenta de cuantos bits de información han sido recibidos en la etapa de data.
        Registros b: Son los encargados de ir ensamblando la información recibida.
        
        Un ciclo de clock después de que todo el proceso de recepción finalizo, por medio de o_rx_done_tick, se entrega un uno para indicar que finalizo el proceso de recepción.
    
    */
    
    
    always @(*)
        begin
            state_next = state_reg;
            o_rx_ready = 1'b0;
            s_next = s_reg;
            n_next = n_reg;
            b_next = b_reg;
            
            case(state_reg)
                idle:
                    if(~i_rx)
                        begin
                            state_next = start;
                            s_next = 0;
                        end
                start:
                    if(i_s_tick)
                        if(s_reg == 7)
                            begin
                                state_next = data;
                                s_next = 0;
                                n_next = 0;
                            end
                        else
                            s_next = s_reg + 1;    
                data:
                    if(i_s_tick)
                        if(s_reg == 15)
                            begin
                                s_next = 0;
                                b_next = {i_rx, b_reg[7:1]};
                                if(n_reg == (DATA_LENGTH-1))
                                    state_next = stop;
                                else
                                    n_next = n_reg + 1;
                            end
                        else
                            s_next = s_reg + 1;
                stop:
                    if(i_s_tick)
                        if(s_reg == (SB_TICK-1))
                            begin
                                state_next = idle;
                                o_rx_ready = 1'b1;
                            end            
                        else    
                            s_next = s_reg + 1;
            endcase                
        end
    
    
    assign o_rx_data = b_reg; 

endmodule
