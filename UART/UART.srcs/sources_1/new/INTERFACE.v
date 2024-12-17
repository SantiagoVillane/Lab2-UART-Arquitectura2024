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
    parameter DATA_LENGTH = 8,   // Longitud de los datos
    parameter OP_LENGTH = 6
)
(
    input wire i_clk,                 // Reloj principal
    input wire i_reset,               // Reset global
    input wire i_rx_done,                  // Entrada UART RX
    input wire i_tx_done,
    input wire [DATA_LENGTH-1:0] i_rx_data, // Entrada de datos para transmitir
    input wire [DATA_LENGTH-1:0] i_alu_result, // Entrada de datos para transmitir
    output wire [DATA_LENGTH-1:0] o_tx_data,
    output wire [DATA_LENGTH-1:0] o_data_A,
    output wire [DATA_LENGTH-1:0] o_data_B,
    output wire [OP_LENGTH-1:0] output_operation,
    output wire o_tx_enable  
);


     //EStados
    localparam [1:0]
        IDLE   = 2'b00, 
        DATA = 2'b01, 
        STOP = 2'b10; 
        
    // Para controlar que cargo
    reg[1:0] op_count,next_op_count;
    reg[1:0] state,state_next;
    reg[DATA_LENGTH-1:0] alu_data_A,next_alu_data_A;
    reg[DATA_LENGTH-1:0] alu_data_B,next_alu_data_B; 
    reg[OP_LENGTH-1:0] alu_op,next_alu_op;
    reg[DATA_LENGTH-1:0] data_tx,next_data_tx;
    reg tx_enable,next_tx_enable;
    reg alu_data_ready,next_alu_data_ready; //Señal de validación para el dato de la ALU
    
    always@(posedge i_clk) begin 
    if(i_reset) begin
        state <= IDLE;
        alu_data_A <= 0;
        alu_data_B <= 0; 
        alu_op <= 0;
        data_tx <= 0;
        tx_enable <= 0;
        op_count <= 0;
        alu_data_ready <= 0;
    end else begin
        state <= state_next;
        alu_data_A <= next_alu_data_A;
        alu_data_B <= next_alu_data_B;
        alu_op <= next_alu_op;
        data_tx <= next_data_tx;
        tx_enable <= next_tx_enable;
        op_count <= next_op_count;
        alu_data_ready <= next_alu_data_ready;
   end
 end
 
     always @(*) begin
     state_next = state;
     next_alu_data_A = alu_data_A;
     next_alu_data_B = alu_data_B;
     next_alu_op = alu_op;
     next_data_tx = data_tx;
     next_tx_enable = 1'b0;
     next_op_count = op_count;
     next_alu_data_ready = alu_data_ready;//Mantiene el valor actual por default
     
     case(state)
     IDLE: begin
        if(i_rx_done) begin
        if(op_count==2'b00 || op_count==2'b01 || op_count==2'b10) begin
              state_next = DATA;

            end
        end
      end 
      
      DATA: begin
        case(op_count)
            2'b00: begin
                next_alu_data_A = i_rx_data; //Carga dato A
                next_op_count = op_count + 1;
                state_next = IDLE; //Vuelve a IDLE y espera la próxima entrada
            end
            2'b01: begin
                next_alu_data_B = i_rx_data; //Carga dato B
                next_op_count = op_count + 1;
                state_next = IDLE; //Vuelve a IDLE y espera la próxima entrada
            end
            2'b10: begin
                next_alu_op = i_rx_data[OP_LENGTH-1:0]; //Carga el operador
                next_op_count = op_count + 1;
                state_next = STOP;
                next_alu_data_ready = 1'b1; //El dato de la Alu está listo
            end
            default : begin
                state_next = IDLE;
            end
          endcase 
         end
         
         STOP: begin
            if(alu_data_ready) begin
                next_data_tx = i_alu_result; //Asigno resultado a la ALU
            end
            
            next_tx_enable = 1'b1; // Inicia la transmisión
            if(i_tx_done) begin //Cambio de estado cuando está completa la transmisión
                next_op_count = 2'b00; //Reseteo el contador de operaciones
                state_next = IDLE; //Después de transmitir regeresa a IDLE
            end else begin
                state_next = STOP; //Me mantengo en STOP hasta que termina la transmisión
            end
           end
           
           default: state_next = IDLE;
         endcase
       end  
       
 assign o_data_A = alu_data_A;
 assign o_data_B = alu_data_B;
 assign output_operation = alu_op;
 assign o_tx_data = data_tx;
 assign o_tx_enable = tx_enable;
 
 
endmodule
