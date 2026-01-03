`timescale 1ns / 1ps

module execute(
input logic clk, rst,
input logic [31:0] Instruction_Execute,
input logic signed [31:0] Op1E,
input logic signed [31:0] Op2E,
input logic signed [31:0] OpM,
input logic signed [31:0] OpW,
input logic signed [31:0] Immediate_E,
input logic [31:0] PCE,
input logic [31:0] PCE_4,
input logic BSelE, func7E, w_enE, wd_enE, rd_enE, AselE, BrUnE, BranchE, JumpE,
input logic [2:0] ALUSelE, 
input logic [2:0] op_selE, 
input logic [1:0] WBSelE,
input logic [4:0] RDE,
input logic [1:0] Forward_A,
input logic [1:0] Forward_B,
output logic [31:0] OP2M,
output logic [31:0] PCM_4,
output logic [31:0] ALU_OpM,
output logic [31:0] PC_Target,
output logic w_enM, wd_enM, rd_enM, PC_Mux,
output logic [2:0] op_selM, 
output logic [1:0] WBSelM,
output logic [4:0] RDM,
output logic [31:0] Instruction_Mem
    );
    
    logic [31:0] result_data;
    logic [31:0] Op1;
    logic [31:0] Op2;
    logic Lt, Eq;
    logic signed [31:0] In1; 
    logic signed [31:0] In2;
    
         always_comb begin
        if (JumpE) begin
            PC_Mux = 1'b1;
        end else if (BranchE) begin
            case (Instruction_Execute[14:12])
                3'b000: PC_Mux = Eq;
                3'b001: PC_Mux = ~Eq;
                3'b100: PC_Mux = Lt;
                3'b101: PC_Mux = ~Lt;
                3'b110: PC_Mux = Lt;
                3'b111: PC_Mux = ~Lt;
                default: PC_Mux = 1'b0;
            endcase
        end else begin
            PC_Mux = 1'b0;
        end
    end
// === ALU ===
        
         always_comb begin
            case(Forward_A)
                2'b00: Op1 = Op1E;
                2'b01: Op1 = OpW;
                2'b10: Op1 = OpM;
                default: Op1 = Op1E;
            endcase
            case(Forward_B)
                2'b00: Op2 = Op2E;
                2'b01: Op2 = OpW;
                2'b10: Op2 = OpM;
                default: Op2 = Op2E;   
            endcase         
        end
          
         always_comb begin
         case(BSelE)
         1'b0: In2 = Op2;
         1'b1: In2 = Immediate_E;
         endcase
         end
         
         always_comb begin
         case(AselE)
         1'b0: In1 = Op1;
         1'b1: In1 = PCE;
         endcase
         end
         
                     
         alu #(.ALU_WIDTH(32)) ALU (
         .Op1(In1),
         .Op2(In2),
         .ALUSel(ALUSelE),
         .func7(func7E),
         .Result(result_data)
         );
         
         branch_comp COMP(
         .Op1(Op1),
         .Op2(Op2),
         .BrUn(BrUnE),
         .Eq(Eq),
         .Lt(Lt)
         );
         
      always_comb begin   
         if(JumpE) begin
          PC_Target = result_data & ~1;
         end
         else
         PC_Target = result_data;
      end
         
             always @(posedge clk or negedge rst) begin
             if(rst == 1'b0) begin
                 w_enM <= 1'b0; 
                 wd_enM <= 1'b0; 
                 rd_enM <= 1'b0;
                 WBSelM <= 2'b00;
                 RDM <= 5'h00;
                 PCM_4 <= 32'h00000000; 
                 ALU_OpM <= 32'h00000000; 
                 OP2M <= 32'h00000000;
                 Instruction_Mem <= 32'h00000000;
                 op_selM <= 3'b000;
             end           
             else begin
                 w_enM <= w_enE; 
                 wd_enM <= wd_enE; 
                 rd_enM <= rd_enE;
                 WBSelM <= WBSelE;
                 RDM <= RDE;
                 PCM_4 <= PCE_4; 
                 ALU_OpM <= result_data; 
                 OP2M <= Op2;
                 Instruction_Mem <= Instruction_Execute;
                 op_selM <= op_selE;
             end
         end
endmodule
