`timescale 1ns / 1ps


module fetch(
input logic clk, rst, Flush,
input logic PC_Mux, Stall,
input logic [31:0] PC_Target,
output logic [31:0] Instruction_Fetch,
output logic [31:0] PCD,
output logic [31:0] PC_4
);

logic [31:0] PC_In;
logic [31:0] PC_next;
logic [31:0] PC_Value;
logic [31:0] Instruction;

   assign PC_In = PC_Value + 4;
   
   always_comb begin
   case(PC_Mux)
   1'b0: PC_next = PC_In;
   1'b1: PC_next = PC_Target;
   default: PC_next = PC_In;
   endcase
   end
   
   program_counter #(.PROG_VALUE(348)) PC (
   .clk(clk),
   .rst(rst),
   .PC_in(PC_next),
   .PC_Value(PC_Value),
   .Stall(Stall)
   );
   // === Instruction Memory ===
   instruction_memory #(.IMEM_DEPTH(256)) IMEM (
   .PC_Value(PC_Value),
   .Instruction(Instruction)
   );
   
   // Fetch Cycle Register Logic
       always @(posedge clk or negedge rst) begin
       if (!rst) begin
           Instruction_Fetch <= 32'h00000000;
           PCD <= 32'h00000000;
           PC_4 <= 32'h00000000;
       end  
       else if (Flush) begin                     
                         Instruction_Fetch <= 32'h00000013;
                         PCD <= 32'h00000000;
                         PC_4 <= 32'h00000000;
       end  
       else if (Stall) begin
             Instruction_Fetch <= Instruction_Fetch;
             PCD <= PCD;
             PC_4 <= PC_4;
        end      
       else begin
           Instruction_Fetch <= Instruction;
           PCD <= PC_Value;
           PC_4 <= PC_In;
       end
   end

endmodule
