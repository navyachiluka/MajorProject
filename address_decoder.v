module address_decoder (
    input [31:0] M_Raddr1, M_Raddr2, M_waddr,
    output reg protocol_select
);
    parameter AXI_START = 32'h0000_0000, AXI_END = 32'h3FFFFFFF;
    parameter APB_START = 32'h40000000, APB_END = 32'h7FFFFFFF;

    always @(*) begin
        if ((M_Raddr1 >= AXI_START && M_Raddr1 <= AXI_END) ||
            (M_Raddr2 >= AXI_START && M_Raddr2 <= AXI_END) ||
            (M_waddr >= AXI_START && M_waddr <= AXI_END))
            protocol_select = 1;  // AXI
        else
            protocol_select = 0;  // APB
    end
endmodule
