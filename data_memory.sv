`timescale 1ns / 1ps
module data_memory #(parameter DMEM_DEPTH = 256) (
    input  logic        clk,
    input  logic        rst,
    input  logic        w_en,
    input  logic        r_en,
    input  logic [2:0]  op_sel,
    input  logic [31:0] addr,
    input  logic [31:0] data_w,
    output logic [31:0] data_r,
    output logic        wdt_irq,
    output logic        wdt_reset
);


logic [31:0] data_memory [0:(DMEM_DEPTH-1)];
logic [31:0] wdt_rdata;


watchdog_timer WDT (
    .clk(clk),
    .rst(rst),
    .w_en(w_en && addr[31:28] == 4'h4),
    .r_en(r_en && addr[31:28] == 4'h4),
    .addr(addr),
    .wdata(data_w),
    .rdata(wdt_rdata),
    .wdt_irq(wdt_irq),
    .wdt_reset(wdt_reset)
);
initial begin
    for (int i = 0; i < DMEM_DEPTH; i++)
        data_memory[i] = 32'h00000000;
    $readmemb("C:/Users/sunrise/Desktop/modified_aneeq/fib_dm.mem", data_memory);
    $display("Data memory initialized");
end


always_comb begin
    data_r = 32'h00000000; // Default value
    if (addr[31:28] == 4'h4) begin
        data_r = wdt_rdata;
    end
    else if (r_en) begin
        case (op_sel)
            3'b000: begin // lb
                case(addr[1:0])
                2'b00: data_r = {{24{data_memory[addr[31:2]][7]}}, data_memory[addr[31:2]][7:0]};
                2'b01: data_r = {{24{data_memory[addr[31:2]][15]}}, data_memory[addr[31:2]][15:8]};
                2'b10: data_r = {{24{data_memory[addr[31:2]][23]}}, data_memory[addr[31:2]][23:16]};
                2'b11: data_r = {{24{data_memory[addr[31:2]][31]}}, data_memory[addr[31:2]][31:24]};
                endcase
            end
            3'b001: begin // lh
                if (addr[1] == 1'b0) data_r = {{16{data_memory[addr[31:2]][15]}}, data_memory[addr[31:2]][15:0]};
                else data_r = {{16{data_memory[addr[31:2]][31]}}, data_memory[addr[31:2]][31:16]};
            end
            3'b010: data_r = data_memory[addr[31:2]]; // lw
            3'b100: begin // lbu
                if (addr[1:0] == 2'b00) data_r = {24'b0, data_memory[addr[31:2]][7:0]};
                else if (addr[1:0] == 2'b01) data_r = {24'b0,data_memory[addr[31:2]][15:8]};
                else if (addr[1:0] == 2'b10) data_r = {24'b0, data_memory[addr[31:2]][23:16]};
                else data_r = {24'b0,data_memory[addr[31:2]][31:24]};
            end
            3'b101: begin // lhu
                if (addr[1] == 1'b0) data_r = {16'b0, data_memory[addr[31:2]][15:0]};
                else data_r = {16'b0, data_memory[addr[31:2]][31:16]};
            end
            default: data_r = 32'hDEADBEEF;
        endcase
    end
end

always_ff @(posedge clk) begin
    if (w_en) begin
        case (op_sel)
            3'b000: begin // sb
                case(addr[1:0])
                2'b00: data_memory[addr[31:2]][7:0] = data_w[7:0];
                2'b01: data_memory[addr[31:2]][15:8] = data_w[7:0];
                2'b10: data_memory[addr[31:2]][23:16] = data_w[7:0];
                2'b11: data_memory[addr[31:2]][31:24] = data_w[7:0];
                endcase
            end
            3'b001: begin // sh
                if (addr[1] == 1'b0) data_memory[addr[31:2]][15:0] = data_w[15:0];
                else data_memory[addr[31:2]][31:16] = data_w[15:0];
            end
            3'b010: data_memory[addr[31:2]] = data_w; // sw
            default: ;
        endcase
    end
end

`ifdef SIM
    final begin
    $display("=== Final Contents of Data Memory (First 30 Words) ===");
    for (int i = 0; i < 30; i++) begin
        $display("DMEM[%0d] = 0x%08h", i, data_memory[i]);
    end
    end

 `endif
endmodule