`timescale 1ns / 1ps

module imm_gen(
input logic [31:0] imm,
input logic [2:0] IMMSel,
output logic [31:0] immediate
   );
   
   always_comb begin
   case(IMMSel)
   3'b001: begin //I-type
              if(imm[31]) begin
              immediate = {20'b11111111111111111111, imm[31:20]};
              end
              else begin
              immediate = {20'b0, imm[31:20]};
              end
          end
    3'b000: begin //S-type
             if(imm[31]) begin
                immediate = {20'b11111111111111111111, imm[31:25], imm[11:7]};
                end
                else begin
                immediate = {20'b0, imm[31:25], imm[11:7]};
                end
           end
    3'b010: begin //JAL
              if(imm[31]) begin
              immediate = {11'b11111111111, imm[31], imm[19:12], imm[20], imm[30:21], 1'b0};
              end
             else begin
             immediate = {11'b00000000000, imm[31], imm[19:12], imm[20], imm[30:21], 1'b0};
                end     
            end
    3'b011: begin //B-type
                if(imm[31]) begin
                  immediate = {19'b1111111111111111111, imm[31], imm[7], imm[30:25], imm[11:8], 1'b0};
                  end
                 else begin
                 immediate = {19'b0000000000000000000, imm[31], imm[7], imm[30:25], imm[11:8], 1'b0};
                    end     
            end
    3'b100: begin //U-type
              immediate = {imm[31:12], 12'b000000000000};      
            end
   default: begin //I-type
                       if(imm[31]) begin
                       immediate = {20'b11111111111111111111, imm[31:20]};
                       end
                       else begin
                       immediate = {20'b00000000000000000000, imm[31:20]};
                       end
                   end        
    endcase
  end
endmodule
