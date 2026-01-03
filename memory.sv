// Memory Module 

`timescale 1ns / 1ps

module memory(
    input  logic clk, rst,
    input  logic [31:0] OP2M,
    input  logic [31:0] PCM_4,
    input  logic [31:0] ALU_OpM,
    input  logic w_enM, wd_enM, rd_enM,
    input  logic [2:0] op_selM,
    input  logic [1:0] WBSelM,
    input  logic [4:0] RDM,
    input  logic [31:0] Instruction_Mem,

    output logic w_enW,
    output logic [1:0] WBSelW,
    output logic [4:0] RDW,
    output logic [31:0] ALU_OpW,
    output logic [31:0] PCW_4,
    output logic [31:0] memop,
    output logic [31:0] Instruction_WB,
    output logic wdt_irq,
    output logic wdt_reset
);

logic [31:0] data_out;    

// Instantiate data memory with watchdog timer
data_memory #(.DMEM_DEPTH(256)) dmem (
    .clk(clk),
    .rst(rst),
    .w_en(wd_enM),
    .r_en(rd_enM),
    .op_sel(op_selM),      // func3
    .addr(ALU_OpM),
    .data_w(OP2M),
    .data_r(data_out),
    .wdt_irq(wdt_irq),     // connected watchdog IRQ
    .wdt_reset(wdt_reset)  // connected watchdog reset
);

// Pipeline register between MEM and WB stages
always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
        w_enW          <= 1'b0; 
        WBSelW         <= 2'b00;
        RDW            <= 5'h00;
        PCW_4          <= 32'h00000000; 
        ALU_OpW        <= 32'h00000000; 
        memop          <= 32'h00000000;
        Instruction_WB <= 32'h00000000;
    end
    else begin
        w_enW          <= w_enM; 
        WBSelW         <= WBSelM;
        RDW            <= RDM;
        PCW_4          <= PCM_4; 
        ALU_OpW        <= ALU_OpM; 
        memop          <= data_out;
        Instruction_WB <= Instruction_Mem;
    end
end

endmodule