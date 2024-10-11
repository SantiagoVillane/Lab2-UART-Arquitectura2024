`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2024 14:36:30
// Design Name: 
// Module Name: ALU
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


module ALU
#(
    parameter NB_OP = 6,
    parameter NB_DATA = 8
)
(
    input wire signed [NB_DATA-1:0] i_data_a,
	input wire signed [NB_DATA-1:0] i_data_b,
	input wire[NB_OP-1:0] i_op,
	output wire signed [NB_DATA-1:0] o_data
);

    reg [NB_DATA-1:0] temp;
    
    always @(*) 
    begin
        case(i_op)
            6'b100000 : temp = i_data_a + i_data_b;  
            6'b100010 : temp = i_data_a - i_data_b;
            6'b100100 : temp = i_data_a & i_data_b;
            6'b100101 : temp = i_data_a | i_data_b;
            6'b100110 : temp = i_data_a ^ i_data_b;
            6'b000011 : temp = i_data_a >>> i_data_b;
            6'b000010 : temp = i_data_a >> i_data_b;
            6'b100111 : temp = ~(i_data_a|i_data_b);
            default : temp = {NB_DATA{1'b0}};
        endcase
    end
    
    assign o_data = temp;

endmodule