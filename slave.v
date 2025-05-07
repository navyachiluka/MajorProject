`timescale 1ns / 1ps

module slave(
    input PCLK,
    input PRESET,

    // AXI Inputs
    input M_awvalid,
    input M_wvalid,
    input M_bready,
    input M_arvalid,
    input M_rready,
    input [31:0] M_Raddr1,  // Read addresses from memory
    input [31:0] M_Raddr2,
    input [31:0] M_waddr,
    input [31:0] M_wdata,

    // APB Inputs
    input PENABLE,
    input PWRITE,

    // Outputs
    output reg [15:0] S_rdata1,  // 16-bit operand 1
    output reg [15:0] S_rdata2,  // 16-bit operand 2
    output reg [31:0] S_result,  // 32-bit product/result
    output reg PReady,
    output reg [1:0] S_bresp,
    output reg [1:0] S_rresp,
    output reg S_bvalid,
    output reg S_rvalid,
    output reg S_awready,
    output reg S_arready,
    output reg S_wready
);

    // ============================
    // Memory Module Instantiation
    // ============================
    wire [15:0] mem_read_data1, mem_read_data2;

    memorymodule mem_inst (
        .PCLK(PCLK),  // Pass PCLK instead of clk
        .waddr(M_waddr),
        .wdata(M_wdata),
        .raddr1(M_Raddr1),
        .raddr2(M_Raddr2),
        .mem_read_data1(mem_read_data1),
        .mem_read_data2(mem_read_data2)
    );

    // ============================
    // State Machine for AXI/APB Transactions
    // ============================
    always @(posedge PCLK or posedge PRESET) begin
        if (PRESET) begin
            // Reset all registers
            PReady     <= 0;
            S_rdata1   <= 0;
            S_rdata2   <= 0;
            S_result   <= 0;
            S_bvalid   <= 0;
            S_rvalid   <= 0;
            S_awready  <=1;
            S_arready  <= 1;
            S_wready   <= 1;
            S_bresp    <= 2'b00;
            S_rresp    <= 2'b00;
        end else begin
            // ============================
            // APB Transactions (Read & Write)
            // ============================
            if (PENABLE) begin
                PReady <= 1;  // Assert PReady in the Access phase
                
                if (PWRITE) begin  // APB Write Transaction
                    S_result <= M_wdata;  // Store write data in result register
                end else begin  // APB Read Transaction
                    S_rdata1 <= mem_read_data1;
                    S_rdata2 <= mem_read_data2;
                end
            end else begin
                PReady <= 0;
            end

            // ============================
            // AXI Write Transaction
            // ============================
            if (M_awvalid) begin
                S_awready <= 1;  // Ready to accept the write address
            end

            if (M_wvalid && S_awready) begin
                S_wready  <= 1;  // Ready to accept write data
                S_result  <= M_wdata;  // Store written data in result register
                S_bvalid  <= 1;  // Send write response
                S_bresp   <= 2'b00;  // OKAY response
            end

            if (M_bready) begin
                S_bvalid   <= 0;
                S_awready  <= 0;  // Deassert awready after accepting address
                S_wready   <= 0;  // Deassert wready after accepting data
            end

            // ============================
            // AXI Read Transaction
            // ============================
            if (M_arvalid) begin
                S_arready <= 1;
                S_rvalid  <= 1;
                S_rdata1  <= mem_read_data1;
                S_rdata2  <= mem_read_data2;
                S_rresp   <= 2'b00;  // OKAY response
            end

            if (M_rready) begin
                S_rvalid   <= 0;
                S_arready  <= 0;  // Deassert arready
            end
        end
    end

endmodule
