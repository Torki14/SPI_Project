`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/27/2026 01:26:20 AM
// Design Name: 
// Module Name: SPI_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SPI_wrapper
#(
    parameter MEM_DEPTH = 256,
    parameter ADDR_SIZE = 8
)(
    input  clk,
    input  rst_n,
    input  SS_n,
    input  MOSI,

    output MISO
);

    wire [9:0] COMMAND_LINE;
    wire [7:0] DATA_OUT_LINE;
    wire       TX_VALID_LINK;
    wire       RX_VALID_LINK;

    SPI_slave my_slave (
        .clk(clk),
        .MOSI(MOSI),
        .SS_n(SS_n),
        .rst_n(rst_n),
        .tx_data(DATA_OUT_LINE),
        .tx_valid(TX_VALID_LINK),
        .rx_data(COMMAND_LINE),
        .rx_valid(RX_VALID_LINK),
        .MISO(MISO)
    );

    RAM #(
        .MEM_DEPTH(MEM_DEPTH),
        .ADDR_SIZE(ADDR_SIZE)
    ) my_mem (
        .clk(clk),
        .rst_n(rst_n),
        .din(COMMAND_LINE),
        .rx_valid(RX_VALID_LINK),
        .dout(DATA_OUT_LINE),
        .tx_valid(TX_VALID_LINK)
    );

endmodule