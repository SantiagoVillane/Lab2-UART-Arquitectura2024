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
    parameter DATA_LENGTH = 8,    // Longitud del dato (8 bits)
    parameter SB_TICK = 16        // Número de ticks para el bit de parada
)
(
    input wire i_clk,             // Reloj principal
    input wire i_reset,           // Reset sincrónico
    input wire i_start_tx,           // Señal de inicio de transmisión
    input wire i_s_tick,          // Tick del generador de baud rate
    output reg o_tx_done,              // Línea UART de salida
    //output reg o_busy,             // Indicador de transmisión activa
    output wire o_tx,
    input wire [DATA_LENGTH-1:0] i_tx_data // Dato paralelo a transmitir
);

    // Estados del transmisor
    localparam [1:0] 
        IDLE  = 2'b00,  // Estado inactivo
        START = 2'b01,  // Transmisión del bit de inicio
        DATA  = 2'b10,  // Transmisión de los bits de datos
        STOP  = 2'b11;  // Transmisión del bit de parada

    // Registros de estado
    reg [1:0] state, state_next;         // Estado actual y próximo estado
    reg [3:0] tick_count, tick_count_next; // Contador de ticks
    reg [2:0] bit_count, bit_count_next; // Contador de bits de datos
    reg [DATA_LENGTH-1:0] shift_reg, shift_reg_next; // Registro de desplazamiento para datos
    reg tx_reg, tx_next;

    // Lógica secuencial (Actualizar registros en el flanco de subida del reloj)
    always @(posedge i_clk) begin
        if (i_reset) begin
            state <= IDLE;
            tick_count <= 0;
            bit_count <= 0;
            shift_reg <= 0;
            tx_reg <= 1'b1;  // Línea UART inactiva
            //o_busy <= 1'b0;
        end else begin
            state <= state_next;
            tick_count <= tick_count_next;
            bit_count <= bit_count_next;
            shift_reg <= shift_reg_next;
            tx_reg <= tx_next;
        end
    end

    // Lógica combinacional (FSM)
    always @(*) begin
        // Valores por defecto
        state_next = state;
        tick_count_next = tick_count;
        bit_count_next = bit_count;
        shift_reg_next = shift_reg;
        o_tx_done = 1'b0; 
        tx_next = tx_reg;
        //o_busy = (state != IDLE);

        case (state)
            IDLE: begin
                tx_next = 1'b1; //Transmisor de estado IDLE en alto
                if (i_start_tx) begin
                    state_next = START;
                    tick_count_next = 0;
                    shift_reg_next = i_tx_data; // Cargar dato paralelo en el registro de desplazamiento
                end
            end

            START: begin
                tx_next = 1'b0;// Transmitir bit de inicio
                if (i_s_tick) begin
                    if (tick_count == (SB_TICK - 1)) begin
                        state_next = DATA;
                        tick_count_next = 0;
                        bit_count_next = 0;
                    end else begin
                        tick_count_next = tick_count + 1;
                    end
                end
            end

            DATA: begin
                tx_next = shift_reg[0]; // Enviar el bit menos significativo
                if (i_s_tick) begin
                    if (tick_count == (SB_TICK - 1)) begin
                        tick_count_next = 0;
                        shift_reg_next = shift_reg >> 1; // Desplazar registro
                        if (bit_count == (DATA_LENGTH - 1)) begin
                            state_next = STOP;
                        end else begin
                            bit_count_next = bit_count + 1;
                        end
                    end else begin
                        tick_count_next = tick_count + 1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1;
                if (i_s_tick) begin
                    if (tick_count == (SB_TICK - 1)) begin
                        state_next = IDLE;
                        o_tx_done = 1'b1;
                    end else begin
                        tick_count_next = tick_count + 1;
                    end
                end
            end
             default: begin
            state_next = IDLE;              // Default IDLE
        end
        endcase
    end
    assign o_tx = tx_reg;
endmodule
