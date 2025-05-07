`timescale 1ns / 1ps

module APB_AXI_BRIDGE(
    input wire PCLK,
    input wire PRESET,
    input wire protocol_select,
    
    // Common Signals
    input wire [31:0] M_Raddr1,
    input wire [31:0] M_Raddr2,
    input wire [31:0] M_Waddr,
    input wire [31:0] M_Wdata,
    input wire [15:0] S_rdata1,
    input wire [15:0] S_rdata2,

    // Uncommon Signals (APB & AXI)
    input wire PWRITE,
    input wire PENABLE,
    input wire S_awready,
    input wire S_wready,
    input wire [1:0] S_bresp,
    input wire [1:0] S_rresp,
    input wire S_arready,
    input wire S_bvalid,
    input wire S_rvalid,
    input wire M_awvalid,
    input wire M_wvalid,
    input wire M_bready,
    input wire M_arvalid,
    input wire M_rready,

    // Outputs
    output reg [31:0] m_Raddr1,
    output reg [31:0] m_Raddr2,
    output reg [31:0] m_Waddr,
    output reg [31:0] m_Wdata,
    output reg [15:0] s_Rdata1,
    output reg [15:0] s_Rdata2,
    output reg pWRITE,
    output reg pENABLE,
    output reg s_awready,
    output reg s_wready,
    output reg [1:0] s_bresp,
    output reg [1:0] s_rresp,
    output reg s_arready,
    output reg s_bvalid,
    output reg s_rvalid,
    output reg m_awvalid,
    output reg m_wvalid,
    output reg m_bready,
    output reg m_arvalid,
    output reg m_rready
);

    always @(posedge PCLK or posedge PRESET) begin
        if (PRESET) begin
            // Reset all signals to default values
            m_Raddr1   <= 32'h00000000;
            m_Raddr2   <= 32'h00000000;
            m_Waddr    <= 32'h00000000;
            m_Wdata    <= 32'h00000000;
            s_Rdata1   <= 16'h0000;
            s_Rdata2   <= 16'h0000;
            pWRITE     <= 1'b0;
            pENABLE    <= 1'b0;
            s_awready  <= 1'b0;
            s_wready   <= 1'b0;
            s_bresp    <= 2'b00;
            s_rresp    <= 2'b00;
            s_arready  <= 1'b0;
            s_bvalid   <= 1'b0;
            s_rvalid   <= 1'b0;
            m_awvalid  <= 1'b0;
            m_wvalid   <= 1'b0;
            m_bready   <= 1'b0;
            m_arvalid  <= 1'b0;
            m_rready   <= 1'b0;
        end else begin
            // Pass common signals
            m_Raddr1 <= M_Raddr1;
            m_Raddr2 <= M_Raddr2;
            m_Waddr  <= M_Waddr;
            m_Wdata  <= M_Wdata;
            s_Rdata1 <= S_rdata1;
            s_Rdata2 <= S_rdata2;

            if (protocol_select == 0) begin
                // APB Protocol Selected
                pWRITE  <= PWRITE;
                pENABLE <= PENABLE;
                
                // Reset AXI-specific signals
                s_awready  <= 1'b0;
                s_wready   <= 1'b0;
                s_bresp    <= 2'b00;
                s_rresp    <= 2'b00;
                s_arready  <= 1'b0;
                s_bvalid   <= 1'b0;
                s_rvalid   <= 1'b0;
                m_awvalid  <= 1'b0;
                m_wvalid   <= 1'b0;
                m_bready   <= 1'b0;
                m_arvalid  <= 1'b0;
                m_rready   <= 1'b0;
            end else begin
                // AXI Protocol Selected
                s_awready  <= S_awready;
                s_wready   <= S_wready;
                s_bresp    <= S_bresp;
                s_rresp    <= S_rresp;
                s_arready  <= S_arready;
                s_bvalid   <= S_bvalid;
                s_rvalid   <= S_rvalid;
                m_awvalid  <= M_awvalid;
                m_wvalid   <= M_wvalid;
                m_bready   <= M_bready;
                m_arvalid  <= M_arvalid;
                m_rready   <= M_rready;

                // Reset APB-specific signals
                pWRITE  <= 1'b0;
                pENABLE <= 1'b0;
            end
        end
    end

endmodule
