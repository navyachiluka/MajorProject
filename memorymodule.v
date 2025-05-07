`timescale 1ns / 1ps

module memorymodule (
    input PCLK,
    input [31:0] waddr,
    input [31:0] wdata,
    input [31:0] raddr1,
    input [31:0] raddr2,
    output reg [15:0] mem_read_data1,
    output reg [15:0] mem_read_data2
);

    // 16-bit memory to store operands
    reg [15:0] name_reg [5:0];

    // Address Mapping
    localparam WRITE_ADDR1 = 32'h1111_0000;
    localparam WRITE_ADDR2 = 32'h2111_0000;
    localparam READ_ADDR1  = 32'h1211_1111;
    localparam READ_ADDR2  = 32'h1312_2222;
    localparam READ_ADDR3  = 32'h2211_1111;
    localparam READ_ADDR4  = 32'h2312_2222;

    // Initialize memory contents
    initial begin
        name_reg[0] = 16'h0000;
        name_reg[1] = 16'h0001;
        name_reg[2] = 16'h0011;
        name_reg[3] = 16'h0111;
        name_reg[4] = 16'h1111;
        name_reg[5] = 16'h1011;
    end

    always @(posedge PCLK) begin
        // ============================
        // Write Operations
        // ============================
        if (waddr == WRITE_ADDR1) begin
            name_reg[0] <= wdata[15:0];  // Store only 16 bits
        end 
        else if (waddr == WRITE_ADDR2) begin
            name_reg[1] <= wdata[15:0];
        end

        // ============================
        // Read Operations
        // ============================
        if (raddr1 == READ_ADDR1) mem_read_data1 <= name_reg[2];
        if (raddr2 == READ_ADDR2) mem_read_data2 <= name_reg[3];

        if (raddr1 == READ_ADDR3) mem_read_data1 <= name_reg[4];
        if (raddr2 == READ_ADDR4) mem_read_data2 <= name_reg[5];
    end

endmodule
