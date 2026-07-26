`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/27/2026 01:25:04 AM
// Design Name: 
// Module Name: SPI_slave
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


module SPI_slave (
    input        clk,
    input        MOSI,
    input        SS_n,
    input        rst_n,
    input  [7:0] tx_data,
    input        tx_valid,

    output [9:0] rx_data,
    output       rx_valid,
    output       MISO
);
    reg [4:0] STATE_REG, NEXT_REG;
    
    localparam IDLE      = 5'b00001;
    localparam CHK_CMD   = 5'b00010;
    localparam WRITE     = 5'b00100;
    localparam READ_ADD  = 5'b01000;
    localparam READ_DATA = 5'b10000;

    reg [9:0] ACCUMULATOR      = 0;
    reg [4:0] COUNTER          = 0; 
    reg [9:0] RX_DATA          = 0;
    reg       RX_VALID         = 0;
    reg       MISO_OUT         = 0;
    reg       Address_recieved = 0;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            STATE_REG <= IDLE;
        else 
            STATE_REG <= NEXT_REG;
    end
    
    always@(*) begin
        case(STATE_REG)
            IDLE: begin
                if(!SS_n) begin
                    NEXT_REG <= CHK_CMD;
                end
                else 
                    NEXT_REG <= IDLE;
            end
            CHK_CMD: begin
                if(!SS_n) begin
                    if(!MOSI)
                        NEXT_REG <= WRITE;
                    else
                        if(!Address_recieved)
                            NEXT_REG <= READ_ADD;
                        else
                            NEXT_REG <= READ_DATA;
                end
                else 
                    NEXT_REG <= IDLE;
            end
            WRITE: begin
                if(!SS_n) begin
                    NEXT_REG <= WRITE;
                end
                else 
                    NEXT_REG <= IDLE;
            end
            READ_ADD: begin
                if(!SS_n) begin
                    NEXT_REG <= READ_ADD;
                end
                else 
                    NEXT_REG <= IDLE;
            end
            READ_DATA: begin
                if(!SS_n) begin
                    NEXT_REG <= READ_DATA;
                end
                else 
                    NEXT_REG <= IDLE;
            end
            default: NEXT_REG <= IDLE;
        endcase
    end

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ACCUMULATOR      <= 0;
            COUNTER          <= 0;
            RX_DATA          <= 0;
            RX_VALID         <= 0;
            MISO_OUT         <= 0;
            Address_recieved <= 0;
        end
        else begin
            case(STATE_REG)
                IDLE: begin
                    ACCUMULATOR      <= 0;
                    COUNTER          <= 0;
                    RX_DATA          <= 0;
                    RX_VALID         <= 0;
                    MISO_OUT         <= 0;
                end
                CHK_CMD: begin
                    COUNTER          <= 0;
                    ACCUMULATOR      <= 0;
                end
                WRITE: begin
                    if(COUNTER < 10) begin
                        ACCUMULATOR[9 - COUNTER] <= MOSI;
                        COUNTER  <= COUNTER + 1;
                        RX_VALID <= 0;
                    end
                    else begin
                        RX_DATA  <= ACCUMULATOR;
                        RX_VALID <= 1;
                        COUNTER  <= 0;
                    end
                end
                READ_ADD: begin
                    if(COUNTER < 10) begin
                        Address_recieved         <= 0;
                        ACCUMULATOR[9 - COUNTER] <= MOSI;
                        COUNTER  <= COUNTER + 1;
                        RX_VALID <= 0;
                    end
                    else begin
                        RX_DATA          <= ACCUMULATOR;
                        RX_VALID         <= 1;
                        COUNTER          <= 0;
                        Address_recieved <= 1;
                    end        
                end
                READ_DATA: begin
                    if(COUNTER < 10) begin
                        ACCUMULATOR[9 - COUNTER] <= MOSI;
                        COUNTER  <= COUNTER + 1;
                        RX_VALID <= 0;
                    end
                    else if (COUNTER == 10) begin 
                        RX_DATA          <= ACCUMULATOR;
                        RX_VALID         <= 1;
                        COUNTER          <= COUNTER + 1;
                    end
                    else if (COUNTER == 11) begin
                        RX_VALID <= 0;
                        if(tx_valid) begin // Wait specifically for the RAM response pulse
                            MISO_OUT <= tx_data[7];
                            COUNTER  <= COUNTER + 1;
                        end
                    end
                    else if (COUNTER > 11 && COUNTER < 19) begin
                        MISO_OUT <= tx_data[18 - COUNTER];
                        COUNTER  <= COUNTER + 1;
                    end
                    else if (COUNTER == 19) begin
                        COUNTER  <= 0;
                        Address_recieved <= 0;
                    end
                end 
            endcase
        end
    end

    assign rx_data  = RX_DATA;
    assign rx_valid = RX_VALID;
    assign MISO     = MISO_OUT;

endmodule