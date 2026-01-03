`timescale 1ns/1ps
module alu #(parameter ALU_WIDTH = 32) 
(input logic [2:0] ALUSel,
input logic func7,
input logic [(ALU_WIDTH - 1):0] Op1, 
input logic [(ALU_WIDTH - 1):0] Op2,
output logic  [(ALU_WIDTH - 1):0] Result);

logic [31:0] temp;

always_comb begin
temp = 0;
Result = 0;
case(ALUSel[2:0])
3'b000: begin 
        case(func7)
            1'b0: Result = Op1 + Op2;
            1'b1: Result = Op1 - Op2;
        endcase 
        end
3'b001: begin
        Result = Op1 << Op2 [4:0];
        end
3'b010: begin
        temp = Op1 - Op2;
        Result = temp [31];
        end
3'b011: begin
        Result = (Op1 < Op2) ? 1 : 0;
        end
3'b100: begin 
        Result = Op1 ^ Op2;
        end
3'b101: begin
        case(func7) 
        1'b0: Result = Op1 >> Op2 [4:0];
        1'b1: Result = Op1 >>> Op2 [4:0];
        endcase        
        end
3'b110: begin
        Result = Op1 | Op2;
        end
3'b111: begin
        Result = Op1 & Op2;
        end
endcase

if (func7 == 1'b1 && ALUSel == 3'b001) begin
    Result = Op2;
end  
end
endmodule
