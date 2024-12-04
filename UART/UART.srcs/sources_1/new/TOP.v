module TOP
#(
    parameter   DATA_LEN = 8,
                OP_LEN = 6 
)
(
    input wire  i_clk,
    input wire  i_rst,
    input wire  i_rx,
    output wire o_tx,
    output wire [DATA_LEN-1:0] result_leds
);
 
 
    wire [DATA_LEN - 1 : 0] data_a;
    wire [DATA_LEN - 1 : 0] data_b;
    wire [OP_LEN - 1 : 0] op;
 
    reg [DATA_LEN - 1 : 0] reg_data_a;
    reg [DATA_LEN - 1 : 0] reg_data_b;
    reg [OP_LEN - 1 : 0] reg_op; 
 
    wire [DATA_LEN - 1 : 0] alu_result;  
 
    wire [DATA_LEN - 1 : 0] data_to_read;
    wire [DATA_LEN -1 : 0] data_to_write;
 
    wire rx_ready;
    wire tx_start;
    wire tx_done;
 
    localparam IDLE = 3'b000;
    localparam READ_A_STATE = 3'b001;
    localparam READ_B_STATE = 3'b010;
    localparam READ_OPERATION_CODE_STATE = 3'b011;
    localparam CALCULATE_STATE = 3'b100;
 
    reg [2:0] reg_actualState, reg_nextActualState;
    reg [OP_LEN-1:0] o_reg_operationCode, o_reg_nextOperationCode;
    reg [DATA_LEN-1:0] o_reg_dataA, o_reg_nextDataA;
    reg [DATA_LEN-1:0] o_reg_dataB, o_reg_nextDataB;
    reg [DATA_LEN-1:0] o_reg_aluResultData, o_reg_nextAluResultData;
    reg o_reg_txStart, o_reg_nextTxStart;
 
    INTERFACE #(
        .DATA_LENGTH(DATA_LEN)
    )
    interface (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_rx(i_rx),
        .o_rx_ready(rx_ready),
        .o_rx_data(data_to_read),
        .i_tx_data(data_to_write),
        .i_tx_start(tx_start),
        .o_tx_done_tick(tx_done),
        .o_tx(o_tx)
    );
 
    ALU #(
        .NB_OP(OP_LEN),
        .NB_DATA(DATA_LEN)
    )
    alu(
        .i_data_a(data_a),
        .i_data_b(data_b),
        .i_op(op),
        .o_data(alu_result)
    );
 
    always@(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin 
            reg_actualState <= IDLE;
            o_reg_dataA <= {DATA_LEN{1'b0}};
            o_reg_dataB <= {DATA_LEN{1'b0}};
            o_reg_operationCode <= {OP_LEN{1'b0}};
            o_reg_aluResultData <= {DATA_LEN{1'b0}};
            o_reg_txStart <= 1'b0;
        end else begin
            reg_actualState <= reg_nextActualState;
            o_reg_dataA <= o_reg_nextDataA;
            o_reg_dataB <= o_reg_nextDataB;
            o_reg_operationCode <= o_reg_nextOperationCode;
            o_reg_aluResultData <= o_reg_nextAluResultData;
            o_reg_txStart <= o_reg_nextTxStart;
        end
    end
 
    always@(*) begin
        reg_nextActualState = reg_actualState;
        o_reg_nextDataA = o_reg_dataA;
        o_reg_nextDataB = o_reg_dataB;
        o_reg_nextOperationCode = o_reg_operationCode;
        o_reg_nextAluResultData = o_reg_aluResultData;
        o_reg_nextTxStart = 1'b0;
 
        case (reg_actualState)
            IDLE: begin
                if (rx_ready) begin
                    reg_nextActualState = READ_A_STATE;
                end
            end
            READ_A_STATE: begin
                if (rx_ready) begin
                    o_reg_nextDataA = data_to_read;
                    reg_nextActualState = READ_B_STATE;
                end
            end
            READ_B_STATE: begin
                if (rx_ready) begin
                    o_reg_nextDataB = data_to_read;
                    reg_nextActualState = READ_OPERATION_CODE_STATE;
                end
            end
            READ_OPERATION_CODE_STATE: begin
                if (rx_ready) begin
                    o_reg_nextOperationCode = data_to_read;
                    reg_nextActualState = CALCULATE_STATE;
                end
            end
            CALCULATE_STATE: begin
                o_reg_nextAluResultData = alu_result;
//if (tx_done) begin
                    reg_nextActualState = IDLE;
                    o_reg_nextTxStart = 1'b1; // Inicia transmisión
              //  end
            end
        endcase
    end
 
    assign data_a = o_reg_dataA;
    assign data_b = o_reg_dataB;
    assign op = o_reg_operationCode;
    assign data_to_write = o_reg_aluResultData;
    assign result_leds = o_reg_aluResultData; // Asignar resultado a LEDS si se desea
    assign tx_start = o_reg_txStart;
endmodule