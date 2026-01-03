`timescale 1ns / 1ps

module watchdog_timer (
    input  logic        clk,
    input  logic        rst,

    // Memory-mapped interface
    input  logic        w_en,
    input  logic        r_en,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,

    // Outputs
    output logic        wdt_irq,
    output logic        wdt_reset
);

    // Address map
    localparam WDT_CTRL    = 32'h4000_0000;
    localparam WDT_TIMEOUT = 32'h4000_0004;
    localparam WDT_FEED    = 32'h4000_0008;
    localparam WDT_STATUS  = 32'h4000_000C;

    // Registers
    logic        wdt_enable;
    logic        irq_enable;
    logic [31:0] timeout_reg;
    logic [31:0] counter;
    logic        expired;

    /* =========================
       MAIN SEQUENTIAL LOGIC
       ========================= */
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter      <= 32'd0;
            timeout_reg  <= 32'd0;
            wdt_enable   <= 1'b0;
            irq_enable   <= 1'b0;
            expired      <= 1'b0;
        end
        else begin
            expired <= 1'b0; // default, one-cycle pulse

            // MMIO write handling
            if (w_en) begin
                case (addr)
                    WDT_TIMEOUT: timeout_reg <= wdata;

                    WDT_CTRL: begin
                        wdt_enable <= wdata[0];
                        irq_enable <= wdata[1];
                    end

                    WDT_FEED: counter <= timeout_reg; // kick / feed
                endcase
            end

            // Countdown logic
            if (wdt_enable) begin
                if (counter > 0)
                    counter <= counter - 1;
                else
                    expired <= 1'b1;
            end
        end
    end

    /* =========================
       READ LOGIC
       ========================= */
    always_comb begin
        rdata = 32'h0;
        if (r_en) begin
            case (addr)
                WDT_CTRL:    rdata = {30'b0, irq_enable, wdt_enable};
                WDT_TIMEOUT: rdata = timeout_reg;
                WDT_STATUS:  rdata = {31'b0, expired};
                default:     rdata = 32'h0;
            endcase
        end
    end

    /* =========================
       OUTPUT SIGNALS
       ========================= */
    assign wdt_irq   = expired & irq_enable;
    assign wdt_reset = expired;

endmodule
