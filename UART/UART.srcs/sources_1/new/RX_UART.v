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
    parameter   SB_TICK = 16        //# Numero de ticks para que frene. El cual es 16, 24 y 32 para 1, 1.5 y 2 bits de stop respectivamente.
 )
(
    input wire i_clk,           // Reloj principal
    input wire i_reset,         // Reset sincrónico
    input wire i_rx,            // Línea de recepción UART
    input wire i_s_tick,          // Tick del generador de baud rate
    output reg o_rx_ready,    // Señal de dato listo
   // output reg o_error,          // Señal de error en la recepción
    output wire [DATA_LENGTH-1:0] o_rx_data   // Byte recibido
);

    // Estados del receptor
    localparam [1:0] 
        IDLE   = 2'b00, // Esperando el bit de inicio
        START  = 2'b01, // Detectando el bit de inicio
        DATA   = 2'b10, // Recibiendo los bits de datos
        STOP   = 2'b11; // Verificando el bit de parada

    reg [1:0] state, state_next; // Estado actual y próximo estado
    reg [3:0] tick_count, next_tick_count;        // Contador para oversampling
    reg [2:0] data_count, next_data_count;
    reg [DATA_LENGTH-1:0] shift_reg, next_shift_reg; //shiftreg
    

    always @(posedge i_clk) begin
        if (i_reset) begin
            state <= IDLE;
            tick_count <= 0;
            data_count <= 0;
            shift_reg <= 0;
            
        end 
        else begin
            state <= state_next;
            tick_count <= next_tick_count;
            data_count <= next_data_count;
            shift_reg <= next_shift_reg;
        end
    end

    always @(*) begin
        state_next = state;
        o_rx_ready = 1'b0;
        next_tick_count = tick_count;
        next_data_count = data_count;
        next_shift_reg = shift_reg;
            case (state)
                IDLE: begin
                   // o_rx_ready <= 0; // Limpiar señal de dato listo
                    if (~i_rx) begin // Detectar bit de inicio
                        state_next <= START; // Detectar bit de inicio
                        next_tick_count <= 0;
                    end
                end
                
                START: begin
                    if (i_s_tick) begin 
                        if (tick_count == 7) begin // Confirmar estabilidad del bit
                            state_next <= DATA;
                            next_tick_count = 0;
                            next_data_count = 0;
                        end else begin
                                  next_tick_count = tick_count + 1;
                        end    
                    end
                end 
                
                DATA: begin
                    if(i_s_tick) begin
                       if(tick_count == (SB_TICK - 1)) begin
                            next_tick_count = 0;
                    next_shift_reg = {i_rx, shift_reg[DATA_LENGTH-1:1]}; // i_rx en la posición más significativa y los bits shiftreg[NB_DATA-1:1] desplazados hacia la derecha.
                    if(data_count == (DATA_LENGTH - 1))
                        state_next = STOP;
                    else
                        next_data_count = data_count + 1;
                end
                else begin
                    next_tick_count = tick_count + 1;
                end
            end
        end
                
                STOP: begin
                 if(i_s_tick) begin
                     if(tick_count == (SB_TICK - 1)) begin
                        state_next = IDLE;
                       //    o_rx_ready = 1'b1;
                        if (i_rx) begin
                        o_rx_ready = 1'b1; // Indicate that reception is complete if stop bit is valid
                    end
                    end
                    else begin
                            next_tick_count = tick_count + 1;
                    end       
               end
        end
        default: begin
            state_next = IDLE; // Default state is IDLE
        end
    endcase   
end

    assign o_rx_data = shift_reg; 
endmodule
