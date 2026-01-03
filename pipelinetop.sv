`timescale 1ns / 1ps

module pipelinetop(
    input  logic clk,
    input  logic rst,
    output logic wdt_irq,      // Top-level watchdog interrupt
    output logic wdt_reset     // Top-level watchdog reset
);

    // =========================
    // Pipeline signals
    // =========================
    logic [31:0] Instruction_Fetch;
    logic [31:0] PCD;
    logic [31:0] PC4;
    logic PC_Mux;

    logic [31:0] Instruction_Decode;
    logic signed [31:0] Op1E;
    logic signed [31:0] Op2E;
    logic signed [31:0] Immediate_E;
    logic [31:0] PCE;
    logic [31:0] PCE_4;

    logic BSelE, func7E, w_enE, wd_enE, rd_enE, AselE, BrUnE, BranchE, JumpE;
    logic [2:0] ALUSelE;
    logic [2:0] op_selE;
    logic [1:0] WBSelE;
    logic [4:0] RDE;

    logic [31:0] OP2M;
    logic [31:0] PCM_4;
    logic signed [31:0] ALU_OpM;
    logic w_enM, wd_enM, rd_enM;
    logic [2:0] op_selM;
    logic [1:0] WBSelM;
    logic [4:0] RDM;
    logic [31:0] Instruction_Mem;

    logic w_enW, Stall;
    logic [1:0] WBSelW;
    logic [4:0] RDW;
    logic [31:0] ALU_OpW, PCW_4, memop;
    logic [31:0] Instruction_WB;
    logic signed [31:0] result;
    logic [4:0] RD;
    logic [31:0] Instruction_W;

    logic [31:0] PC_Target;
    logic w_en;
    logic [1:0] Forward_A;
    logic [1:0] Forward_B;
    logic Flush;
    
    // Watchdog-aware reset
    logic rst_final;
    assign rst_final = rst | wdt_reset;


    // =========================
    // FETCH STAGE
    // =========================
    fetch Fetch (
        .clk(clk), .rst(rst_final), .Stall(Stall), .Flush(Flush),
        .PC_Mux(PC_Mux),
        .PC_Target(PC_Target),
        .Instruction_Fetch(Instruction_Fetch),
        .PCD(PCD),
        .PC_4(PC4)
    );

    // =========================
    // DECODE STAGE
    // =========================
    decode Decode (
        .clk(clk), 
        .rst(rst_final), 
        .Stall(Stall), .Flush(Flush),
        .Instruction_Decode(Instruction_Fetch),
        .PCD(PCD),
        .PC_4(PC4),
        .w_enW(w_en),
        .RDW(RD),
        .result(result),
        .Instruction_Execute(Instruction_Decode),
        .Op1E(Op1E),
        .Op2E(Op2E),
        .Immediate_E(Immediate_E),
        .PCE(PCE),
        .PCE_4(PCE_4),
        .BSelE(BSelE),
        .func7E(func7E),
        .w_enE(w_enE),
        .wd_enE(wd_enE),
        .rd_enE(rd_enE),
        .AselE(AselE),
        .BrUnE(BrUnE),
        .BranchE(BranchE),
        .JumpE(JumpE),
        .ALUSelE(ALUSelE), 
        .op_selE(op_selE), 
        .WBSelE(WBSelE),
        .RDE(RDE)
    );

    // =========================
    // EXECUTE STAGE
    // =========================
    execute Execute (
        .clk(clk), 
        .rst(rst_final),
        .Instruction_Execute(Instruction_Decode),
        .Op1E(Op1E),
        .Op2E(Op2E),
        .Immediate_E(Immediate_E),
        .PCE(PCE),
        .PCE_4(PCE_4),
        .BSelE(BSelE),
        .func7E(func7E),
        .w_enE(w_enE),
        .wd_enE(wd_enE),
        .rd_enE(rd_enE),
        .AselE(AselE),
        .BrUnE(BrUnE),
        .BranchE(BranchE),
        .JumpE(JumpE),
        .ALUSelE(ALUSelE), 
        .op_selE(op_selE), 
        .WBSelE(WBSelE),
        .RDE(RDE),
        .OP2M(OP2M),
        .PCM_4(PCM_4),
        .ALU_OpM(ALU_OpM),
        .PC_Target(PC_Target),
        .w_enM(w_enM),
        .wd_enM(wd_enM),
        .rd_enM(rd_enM),
        .PC_Mux(PC_Mux),
        .op_selM(op_selM), 
        .WBSelM(WBSelM),
        .RDM(RDM),
        .Instruction_Mem(Instruction_Mem),
        .Forward_A(Forward_A),
        .Forward_B(Forward_B),
        .OpM(ALU_OpM),
        .OpW(result)
    );

    // =========================
    // MEMORY STAGE
    // =========================
    memory Memory (
        .clk(clk), 
        .rst(rst_final),
        .OP2M(OP2M),
        .PCM_4(PCM_4),
        .ALU_OpM(ALU_OpM),
        .w_enM(w_enM),
        .wd_enM(wd_enM),
        .rd_enM(rd_enM),
        .op_selM(op_selM), 
        .WBSelM(WBSelM),
        .RDM(RDM),
        .Instruction_Mem(Instruction_Mem),
        .w_enW(w_enW), 
        .WBSelW(WBSelW),
        .RDW(RDW),
        .ALU_OpW(ALU_OpW),
        .PCW_4(PCW_4),
        .memop(memop),
        .Instruction_WB(Instruction_WB),
        .wdt_irq(wdt_irq),       // Connect top-level outputs
        .wdt_reset(wdt_reset)
    );

    // =========================
    // WRITEBACK STAGE
    // =========================
    writeback WriteBack (
        .clk(clk), 
        .rst(rst_final),
        .w_enW(w_enW), 
        .WBSelW(WBSelW),
        .RDW(RDW),
        .ALU_OpW(ALU_OpW),
        .PCW_4(PCW_4),
        .memop(memop),
        .Instruction_WB(Instruction_WB),
        .result(result),
        .RD(RD),
        .Instruction_W(Instruction_W),
        .w_en(w_en)
    );

    // =========================
    // DATA HAZARD UNIT
    // =========================
    data_hazard_unit hazard_unit(
        .RS1E(Instruction_Decode[19:15]),
        .RS2E(Instruction_Decode[24:20]),
        .PC_Mux(PC_Mux),
        .RDM(RDM),
        .RDW(RDW),
        .RDE(RDE),
        .RS1D(Instruction_Fetch[19:15]),
        .RS2D(Instruction_Fetch[24:20]),
        .w_enW(w_enW), .w_enM(w_enM),
        .rd_en(rd_enE),
        .Forward_A(Forward_A),
        .Forward_B(Forward_B),
        .Stall(Stall),
        .Flush(Flush)
    );

endmodule
