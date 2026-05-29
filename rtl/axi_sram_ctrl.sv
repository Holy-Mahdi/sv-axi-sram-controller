module axi_sram_ctrl #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 256
)(
    axi_if.slave axi_if,
    
    input  logic [DATA_WIDTH-1:0] sram_rdata,

    output logic sram_cs,
    output logic sram_we,
    output logic [$clog2(DEPTH)-1:0] sram_addr,
    output logic [DATA_WIDTH-1:0] sram_wdata
);

    localparam int SRAM_ADDR_W = $clog2(DEPTH);

  
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        WRITE_ADDR = 2'b01,
        WRITE_RESP = 2'b10,
        READ_DATA = 2'b11
    } state_t;

    state_t state;
    
    logic [SRAM_ADDR_W-1:0] reg_addr;
    logic [DATA_WIDTH-1:0] reg_wdata;

    always_comb begin
        sram_cs = 1'b0;
        sram_we = 1'b0;
        sram_addr = reg_addr;
        sram_wdata = reg_wdata;

        case (state)
            WRITE_ADDR: begin
               
                if (axi_if.w_valid) begin
                    sram_cs = 1'b1;
                    sram_we = 1'b1;
                    sram_wdata = axi_if.w_data; 
                end
            end
            READ_DATA: begin
                sram_cs = 1'b1;
                sram_we = 1'b0;
            end
            default: ;
        endcase
    end

    always_ff @(posedge axi_if.clk or negedge axi_if.rst_n) begin
        if (!axi_if.rst_n) begin
            state <= IDLE;
            reg_addr <= '0;
            reg_wdata <= '0;
            
            axi_if.aw_ready <= 1'b0;
            axi_if.w_ready <= 1'b0;
            axi_if.b_valid <= 1'b0;
            axi_if.b_resp <= 2'b00;
            axi_if.ar_ready <= 1'b0;
            axi_if.r_valid <= 1'b0;
            axi_if.r_resp <= 2'b00;
            axi_if.r_data <= '0;
        end else begin
            axi_if.aw_ready <= 1'b0;
            axi_if.w_ready <= 1'b0;
            axi_if.ar_ready <= 1'b0;

            case (state)
                IDLE: begin
                    if (axi_if.aw_valid) begin
                        axi_if.aw_ready <= 1'b1;
                        reg_addr <= axi_if.aw_addr[SRAM_ADDR_W+1:2];
                        state <= WRITE_ADDR;
                    end 
                    else if (axi_if.ar_valid) begin
                        axi_if.ar_ready <= 1'b1;
                        reg_addr <= axi_if.ar_addr[SRAM_ADDR_W+1:2];
                        state <= READ_DATA;
                    end
                end

                WRITE_ADDR: begin
                    if (axi_if.w_valid) begin
                        axi_if.w_ready <= 1'b1;
                        reg_wdata <= axi_if.w_data;
                        state <= WRITE_RESP;
                    end
                end

                WRITE_RESP: begin
                    axi_if.b_valid <= 1'b1;
                    axi_if.b_resp <= 2'b00; 
                    if (axi_if.b_ready) begin
                        axi_if.b_valid <= 1'b0;
                        state <= IDLE;
                    end
                end

                READ_DATA: begin
                    axi_if.r_valid <= 1'b1;
                    axi_if.r_data <= sram_rdata; 
                    axi_if.r_resp <= 2'b00; 
                    
                    if (axi_if.r_ready) begin
                        axi_if.r_valid <= 1'b0;
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule