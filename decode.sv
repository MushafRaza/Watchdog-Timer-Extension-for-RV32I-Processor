`timescale 1ns / 1ps

module decode(
input logic clk, rst, Flush,
input logic [31:0] Instruction_Decode,
input logic [31:0] PCD,
input logic [31:0] PC_4,
input logic w_enW, Stall,
input logic [4:0] RDW,
input logic [31:0] result,
output logic [31:0] Instruction_Execute,
output logic signed [31:0] Op1E,
output logic signed [31:0] Op2E,
output logic signed [31:0] Immediate_E,
output logic [31:0] PCE,
output logic [31:0] PCE_4,
output logic BSelE, func7E, w_enE, wd_enE, rd_enE, AselE, BrUnE, BranchE, JumpE,
output logic [2:0] ALUSelE, 
output logic [2:0] op_selE, 
output logic [1:0] WBSelE,
output logic [4:0] RDE

);
     logic signed [31:0] Immediate;
     logic signed [31:0] Op1;
     logic signed [31:0] Op2;
     logic [2:0] ALUSel;
     logic BSel, w_en, func7, BrUn,Lt,  Eq, wd_en, rd_en;
     logic [2:0] op_sel;
     logic [1:0] WBSel;
     logic [2:0] IMMSel; 
     logic ASel, PC_Mux, Branch, Jump;
     //ROM
     control_logic ROM(
     .func3(Instruction_Decode[14:12]), 
     .op_code(Instruction_Decode[6:2]), 
     .func7_30(Instruction_Decode[30]), 
     .BSel(BSel), .func7(func7), .w_en(w_en), .wd_en(wd_en), .rd_en(rd_en), .Asel(ASel), .BrUn(BrUn), .Branch(Branch), .Jump(Jump),
     .ALUSel(ALUSel), 
     .op_sel(op_sel), 
     .WBSel(WBSel), 
     .IMMSel(IMMSel));
     
          // === Register File ===
     register_file #(.REGF_WIDTH(32)) RF (
     .clk(clk),
     .w_en(w_enW),
     .rs1(Instruction_Decode[19:15]),
     .rs2(Instruction_Decode[24:20]),
     .rd(RDW),
     .data_w(result),
     .Op1(Op1),
     .Op2(Op2)
     );
     
     imm_gen imm_gen(
     .imm(Instruction_Decode [31:0]),
     .IMMSel(IMMSel),
     .immediate (Immediate)
      );
      
      always @(posedge clk or negedge rst) begin
          if (!rst) begin
              w_enE <= 1'b0;
              ALUSelE <= 3'b000;
              wd_enE <= 1'b0;
              RDE <= 5'b00000;
              BranchE <= 1'b0;
              Op1E <= 32'h00000000; 
              Op2E <= 32'h00000000; 
              Immediate_E <= 32'h00000000;
              PCE <= 32'h00000000; 
              PCE_4 <= 32'h00000000;
              BSelE   <= 1'b0;
              func7E  <= 1'b0;
              rd_enE  <= 1'b0;
              AselE   <= 1'b0;
              BrUnE   <= 1'b0;
              JumpE   <= 1'b0;
              op_selE <= 3'b000;
              WBSelE  <= 2'b00;
              Instruction_Execute <= 32'h00000000;
          end else if (Flush|Stall) begin
                                   w_enE <= 1'b0;
                                  ALUSelE <= 3'b000;
                                  wd_enE <= 1'b0;
                                  RDE <= 5'b00000;
                                  BranchE <= 1'b0;
                                  Op1E <= 32'h00000000; 
                                  Op2E <= 32'h00000000; 
                                  Immediate_E <= 32'h00000000;
                                  PCE <= 32'h00000000; 
                                  PCE_4 <= 32'h00000000;
                                  BSelE   <= 1'b0;
                                  func7E  <= 1'b0;
                                  rd_enE  <= 1'b0;
                                  AselE   <= 1'b0;
                                  BrUnE   <= 1'b0;
                                  JumpE   <= 1'b0;
                                  op_selE <= 3'b000;
                                  WBSelE  <= 2'b00;
                                  Instruction_Execute <= 32'h00000013;
          end else begin
              w_enE <= w_en;
              ALUSelE <= ALUSel;
              wd_enE <= wd_en;
              RDE <= Instruction_Decode[11:7];
              BranchE <= Branch;
              Op1E <= Op1; 
              Op2E <= Op2; 
              Immediate_E <= Immediate;
              PCE <= PCD; 
              PCE_4 <= PC_4;
              BSelE   <= BSel;
              func7E  <= func7;
              rd_enE  <= rd_en;
              AselE   <= ASel;
              BrUnE   <= BrUn;
              JumpE   <= Jump;
              op_selE <= op_sel;
              WBSelE  <= WBSel;
              Instruction_Execute <= Instruction_Decode;
          end
    end

endmodule
