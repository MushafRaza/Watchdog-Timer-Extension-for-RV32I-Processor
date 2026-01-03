`timescale 1ns/1ps

module program_counter #(parameter PROG_VALUE = 348) 
(input logic clk, rst, Stall, [31:0] PC_in,
output logic [(31) : 0] PC_Value);
    always_ff @(posedge clk or negedge rst) begin
        if (!rst)
            PC_Value <= 0;
        else if (!Stall) begin
            if (PC_Value < PROG_VALUE)
                PC_Value <= PC_in;
            else
                PC_Value <= PROG_VALUE;
        end
    end

endmodule
