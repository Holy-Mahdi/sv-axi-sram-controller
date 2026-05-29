module axi_sram_top #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 256
)(
    input logic clk,
    input logic rst_n,
    axi_if.slave axi_slave_if
);

    logic                  sram_cs;
    logic                  sram_we;
    logic [$clog2(DEPTH)-1:0] sram_addr;
    logic [DATA_WIDTH-1:0] sram_wdata;
    logic [DATA_WIDTH-1:0] sram_rdata;

    axi_sram_ctrl #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .DEPTH      (DEPTH)
    ) u_axi_sram_ctrl (
        .axi_if     (axi_slave_if),
        .sram_rdata (sram_rdata),
        .sram_cs    (sram_cs),
        .sram_we    (sram_we),
        .sram_addr  (sram_addr),
        .sram_wdata (sram_wdata)
    );

    sram_model #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .DEPTH      (DEPTH)
    ) u_sram_model (
        .clk        (clk),
        .rst_n      (rst_n),
        .cs         (sram_cs),
        .we         (sram_we),
        .addr       (sram_addr),
        .data_in    (sram_wdata),
        .data_out   (sram_rdata)
    );

endmodule