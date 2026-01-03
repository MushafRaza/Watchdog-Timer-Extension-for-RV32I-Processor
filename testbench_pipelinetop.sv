`timescale 1ns / 1ps
module testbench_pipelinetop;

 logic clk;
 logic rst;

 // Instantiate the pipelinetop
 pipelinetop uut (
     .clk(clk),
     .rst(rst)
 );

 // Clock generation
 always #5 clk = ~clk;

 initial begin
     $display("=== Pipeline Processor + Watchdog Simulation Start ===");
     $display("Time | PC | IF | ID | EX | MEM | WB | Op1 | Op2 | ALU | WDT_IRQ | WDT_RST");
     $display("---------------------------------------------------------------------------------------------------------------");

     clk = 0;
     rst = 0;

     #30;
     rst = 1;

     forever begin
         @(posedge clk);

         // Print pipeline + watchdog status
         $display("%0t | %08h | %08h | %08h | %08h | %08h | %08h | %4d | %4d | %4d |   %b     |    %b",
             $time,
             uut.Fetch.PC_Value,
             uut.Fetch.Instruction,
             uut.Decode.Instruction_Decode,
             uut.Execute.Instruction_Execute,
             uut.Memory.Instruction_Mem,
             uut.WriteBack.Instruction_W,
             $signed(uut.Execute.Op1E),
             $signed(uut.Execute.Op2E),
             $signed(uut.Execute.ALU_OpM),
             uut.wdt_irq,
             uut.wdt_reset
         );

         // -----------------------------
         // EXIT CONDITIONS
         // -----------------------------

         // 1?? Watchdog interrupt detected
         if (uut.wdt_irq) begin
             $display("\n??  WATCHDOG INTERRUPT ASSERTED at time %0t", $time);
             $display("??  Software failed to feed watchdog\n");
         end

         // 2?? Watchdog reset detected
         if (uut.wdt_reset) begin
             $display("\n? WATCHDOG RESET ASSERTED at time %0t", $time);
             $display("? Processor forced into reset state\n");
             $finish;
         end

         // 3?? Normal program termination (jal x0, 0)
         if (uut.WriteBack.Instruction_W == 32'b00000000000000000000000001101111) begin
             $display("\n? Program completed normally (no watchdog reset)");
             $finish;
         end
     end
 end

endmodule
