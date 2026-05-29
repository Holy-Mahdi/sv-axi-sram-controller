interface axi_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32

)(
    input logic clk,
    input logic rst_n
);
    
    logic [ADDR_WIDTH-1:0] aw_addr;
    logic [2:0] aw_prot;
    logic aw_valid;
    logic aw_ready;

    logic [DATA_WIDTH-1:0] w_data;
    logic [(DATA_WIDTH/8)-1:0] w_strb;
    logic w_valid;
    logic w_ready;

    logic [1:0] b_resp;
    logic b_valid;
    logic b_ready;

    logic [ADDR_WIDTH-1:0] ar_addr;
    logic [2:0] ar_prot;
    logic ar_valid;
    logic ar_ready;


    logic [DATA_WIDTH-1:0] r_data;
    logic [1:0] r_resp;
    logic r_valid;
    logic r_ready;

    

    modport master(
        input  clk, rst_n,
        input ar_ready, w_ready, aw_ready, b_valid, b_resp, r_data, r_resp, r_valid,
        output ar_addr, ar_prot, ar_valid, w_valid, aw_addr, aw_prot, aw_valid, b_ready, r_ready, w_strb, w_data
    );


    modport slave(
        input  clk, rst_n,
        input ar_addr, ar_prot, ar_valid, w_valid, aw_addr, aw_prot, aw_valid, b_ready, r_ready,w_strb, w_data,
        output ar_ready, w_ready, aw_ready, b_valid, b_resp, r_data, r_resp, r_valid
    );
    
endinterface //axi_if