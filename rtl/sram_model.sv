module sram_model #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 256
)(
    input logic clk,
    input logic rst_n,
    input logic cs,
    input logic we,
    input logic [$clog2(DEPTH)-1:0] addr,
    input logic [DATA_WIDTH-1:0] data_in,

    output logic [DATA_WIDTH-1:0] data_out
);

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    initial begin
        integer i;
        for (i = 0; i < DEPTH; i++) begin
            mem[i] = '0;
        end
    end

    always_ff @(posedge clk )
    
    begin
        if (cs && we) begin
            mem[addr] <= data_in;
        end 
    end

    always_comb begin
        if (cs && !we) begin
            data_out = mem[addr];
        end else begin
            data_out = '0;
        end
    end
    
endmodule