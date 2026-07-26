module RAM 
#(
    parameter MEM_DEPTH = 256,
    parameter ADDR_SIZE = 8
)(
    input        clk,
    input [9:0]  din,
    input        rst_n,
    input        rx_valid,

    output [7:0] dout,
    output       tx_valid
);

    reg [ADDR_SIZE -1 : 0] mem [0 : MEM_DEPTH - 1];

    reg [$clog2(MEM_DEPTH) - 1 : 0]  WR_ADDR, RD_ADDR;
    
    reg [7:0] DATA_OUT = 0;
    reg TX_VALID = 0;

    always@(posedge clk) begin
        if(!rst_n) begin
            DATA_OUT <= 0;
            TX_VALID <= 0;
            WR_ADDR  <= 0;
            RD_ADDR  <= 0;
        end
        else if(rx_valid) begin
                case(din[9:8]) 
                2'b00: begin
                    WR_ADDR  <= din[7:0];
                    TX_VALID <= 0;
                end

                2'b01: begin
                    mem[WR_ADDR] <= din[7:0];
                    TX_VALID     <= 0;
                end

                2'b10: begin
                    RD_ADDR  <= din[7:0];
                    TX_VALID <= 0;
                end

                2'b11: begin
                    DATA_OUT  <= mem[RD_ADDR];
                    TX_VALID  <= 1;
                end  
                endcase
        end
        else 
            TX_VALID <= 0;
    end
    assign tx_valid = TX_VALID;
    assign dout     = DATA_OUT;
endmodule