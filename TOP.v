`timescale 1ns / 1ps

module TOP (
    input PCLK,
    input PRESET,
    input PWRITE,
    input [31:0] Raddr1,
    input [31:0] Raddr2,
    input [31:0] Waddr,
    output wire reading_completed,
    output wire write_completed,
    output wire [15:0] operand1,
    output wire [15:0] operand2,
    output wire [31:0] result
);

// ============================
// Internal Signals
// ============================
wire S_awready, S_wready, S_bvalid, S_rvalid;
wire [1:0] S_bresp, S_rresp;
wire S_arready;
wire protocol_select, PENABLE_M;
wire [15:0] S_Rdata1, S_Rdata2;
wire [31:0] M_Raddr1, M_Raddr2, M_Waddr, M_Wdata;
wire M_awvalid, M_wvalid, M_bready, M_arvalid, M_rready;
wire [31:0] product;

// ============================
// Master Module Instantiation
// ============================
master MASTER (
    .PCLK(PCLK),
    .PRESET(PRESET),
    .PWRITE(PWRITE),
    .S_awready(S_awready),
    .S_wready(S_wready),
    .S_bvalid(S_bvalid),
    .S_rvalid(S_rvalid),
    .S_bresp(S_bresp),
    .S_rresp(S_rresp),
    .Raddr1(Raddr1),
    .Raddr2(Raddr2),
    .Waddr(Waddr),
    .S_Rdata1(S_Rdata1),
    .S_Rdata2(S_Rdata2),
    .operand1(operand1),
    .operand2(operand2),
    .M_awvalid(M_awvalid),
    .M_wvalid(M_wvalid),
    .M_arvalid(M_arvalid),
    .M_rready(M_rready),
    .M_bready(M_bready),
    .M_Wdata(M_Wdata),
    .M_Raddr1(M_Raddr1),
    .M_Raddr2(M_Raddr2),
    .M_Waddr(M_Waddr),
    .PENABLE_M(PENABLE_M),
    .product(product),
    .reading_completed(reading_completed),
    .write_completed(write_completed),
    .S_arready(S_arready)
);

// ============================
// APB-AXI Bridge Instantiation
// ============================
APB_AXI_BRIDGE bridge (
    .PCLK(PCLK),
    .PRESET(PRESET),
    .protocol_select(protocol_select),
    .M_Raddr1(M_Raddr1),
    .M_Raddr2(M_Raddr2),
    .M_Waddr(M_Waddr),
    .M_Wdata(M_Wdata),
    .S_rdata1(S_Rdata1),
    .S_rdata2(S_Rdata2),
    .PWRITE(PWRITE),
    .PENABLE(PENABLE_M),
    .S_awready(S_awready),
    .S_wready(S_wready),
    .S_bresp(S_bresp),
    .S_rresp(S_rresp),
    .S_arready(S_arready),
    .S_bvalid(S_bvalid),
    .S_rvalid(S_rvalid),
    .M_awvalid(M_awvalid),
    .M_wvalid(M_wvalid),
    .M_bready(M_bready),
    .M_arvalid(M_arvalid),
    .M_rready(M_rready)
);

// ============================
// Address Decoder Instantiation
// ============================
address_decoder decoder (
    .M_Raddr1(M_Raddr1),
    .M_Raddr2(M_Raddr2),
    .M_waddr(M_Waddr),
    .protocol_select(protocol_select)
);

// ============================
// Slave Module Instantiation
// ============================
slave SLAVE (
    .PCLK(PCLK),
    .PRESET(PRESET),
    .M_awvalid(M_awvalid),
    .M_wvalid(M_wvalid),
    .M_bready(M_bready),
    .M_arvalid(M_arvalid),
    .M_rready(M_rready),
    .M_Raddr1(M_Raddr1),
    .M_Raddr2(M_Raddr2),
    .M_waddr(M_Waddr),
    .M_wdata(M_Wdata),
    .PENABLE(PENABLE_M),
    .PWRITE(PWRITE),
    .S_rdata1(S_Rdata1),
    .S_rdata2(S_Rdata2),
    .S_bresp(S_bresp),
    .S_rresp(S_rresp),
    .S_bvalid(S_bvalid),
    .S_rvalid(S_rvalid),
    .S_awready(S_awready),
    .S_arready(S_arready),
    .S_wready(S_wready)
);

// ============================
// Memory Module Instantiation
// ============================
memorymodule MEM (
    .PCLK(PCLK),
    .waddr(M_Waddr),
    .wdata(M_Wdata),
    .raddr1(M_Raddr1),
    .raddr2(M_Raddr2),
    .mem_read_data1(S_Rdata1),
    .mem_read_data2(S_Rdata2)
);

// ============================
// Result Assignment (Product from Master)
// ============================
assign result = product;

endmodule
