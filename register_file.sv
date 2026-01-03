`timescale 1ns / 1ps

module register_file #(parameter REGF_WIDTH = 32)
(
 input clk,
 input logic w_en,
 input logic [4:0] rs1, 
 input logic [4:0] rs2, 
 input logic [4:0] rd,
 input logic [(REGF_WIDTH - 1):0] data_w,
 output logic [(REGF_WIDTH - 1):0] Op1,
 output logic [(REGF_WIDTH - 1):0] Op2
);


  logic [(REGF_WIDTH - 1):0] x [0:31];

  // Declare file I/O variables for simulation
  `ifdef SIM
    integer fd, i;
  `endif

  // Initialize the register file with binary data
  initial begin
    $readmemb("C:/Users/sunrise/Desktop/modified_aneeq/fib_rf.mem", x);
    $display("Register file initialized");
  end

  // Assign operands to the ALU
  assign Op1 = (rs1 == 5'd0) ? '0 : x[rs1];
  assign Op2 = (rs2 == 5'd0) ? '0 : x[rs2];

  // Always block to write back the result to the register file
  always_ff @(negedge clk) begin
    if (w_en) begin
      if (rd == 5'd0) begin
        x[rd] <= '0;
      end else begin
        x[rd] <= data_w;
      end
    end
  end

  // === Final block to dump register file at simulation end ===

  `ifdef SIM
   final begin
    $display("Final block entered!");
      fd = $fopen("regfile.dump", "w");
      $display("=== Dumping Register File to regfile.dump ===");
      for (i = 0; i < 32; i = i + 1) begin
        $fdisplay(fd, "x[%0d] = %0d (0x%08h)", i, x[i], x[i]);
      end
      #1000
      $fclose(fd);
      $display("=== Dump Complete ===");
    end
  `endif

endmodule
