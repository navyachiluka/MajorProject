
module master(
input  PCLK,
input PRESET,
input S_awready,
input S_wready,
input S_bresp,
input S_arready,
input S_rresp,
input S_bvalid,
input S_rvalid,
input PWRITE,
input [31:0] Raddr1,Raddr2,
input [31:0]Waddr,
input [15:0]S_Rdata1,
input [15:0] S_Rdata2,
output reg [31:0] M_Raddr1,
output reg [31:0] M_Raddr2,
output reg [15:0] operand1, operand2,
output reg PENABLE_M,
output reg [31:0] product,
output reg reading_completed,
output reg write_completed,
output reg [31:0] M_Waddr,
output reg [31:0] M_Wdata,
output reg M_awvalid,
output reg M_wvalid,
output reg M_bready,
output reg M_arvalid,
output reg M_rready);
// State encoding
    parameter IDLE = 3'b000;
      parameter READ_ADDR = 3'b001;
    parameter READ_DATA = 3'b010;
    parameter WRITE_ADDR = 3'b011;
    parameter WRITE_DATA = 3'b100;
    parameter WRITE_RESP = 3'b101;
 
    reg [2:0] state;
always @ (posedge PCLK or posedge PRESET)
 begin
if (PRESET)
begin
M_Waddr <= 32'bx;
M_Raddr1 <= 32'bx;
M_Raddr2 <= 32'bx;
product <= 32'bx;
reading_completed <=1'b0;
operand1 <= 32'hx;
operand2 <= 32'hx;
PENABLE_M <=1'b0;
M_awvalid <= 1'b0;
M_wvalid <= 1'b0;
M_bready <= 1'b0;
M_arvalid <= 1'b0;
M_rready <= 1'b0;
end
else if (PRESET==0)
 begin
  if(PWRITE ==0)
  begin
    M_Raddr1 <= Raddr1;
    M_Raddr2 <= Raddr2;
    operand1 <= S_Rdata1;
    operand2 <= S_Rdata2;
    PENABLE_M <= 1'b1;
    reading_completed <= 1'b1;
  end
  else if(PWRITE == 1)
   begin
   operand1 <= S_Rdata1;
   operand2 <= S_Rdata2;
   product <= operand1*operand2;
   M_Waddr <= Waddr;
   M_Wdata <= product;
   write_completed<=1'b1;
   PENABLE_M <= 1'b1;
  
  end
  else
    begin  
            state <= IDLE;                            
            case (state)
                IDLE: begin
                    state  <= READ_ADDR;
                end
                 READ_ADDR: begin
                  if (S_arready)
                   begin
                    M_Raddr1 <= Raddr1;
                    M_Raddr2 <= Raddr2 ;
                    M_arvalid  <= 1;
                    state    <= READ_DATA;
                    end
                end
               
                READ_DATA: begin
                    if (S_rvalid) begin
                        M_rready <= 1;
                        operand1 <= S_Rdata1;
                        operand2 <= S_Rdata2;
                        if (S_rresp == 2'b00)
                        begin
                          reading_completed <= 1'b1;
                        end
                        else
                         begin
                           reading_completed <= 1'b1;
                         end
                        reading_completed <= 1'b1;
                        state <= WRITE_ADDR;
                    end
                end
                WRITE_ADDR: begin
                    if (S_awready) begin
                        M_Waddr <= Waddr;
                        M_awvalid <= 1;
                        M_wvalid  <= 1;
                        state   <= WRITE_DATA;
                    end
                end
               
              WRITE_DATA: begin
                  if (S_wready) begin
                  product <= operand1 * operand2;  // ? Ensure product is assigned before moving ahead
                   #10; // ? Give time for product to compute before writing
        
                    M_Wdata <= product;  // Assign computed product to write data
                    M_wvalid <= 0;  
                    M_bready <= 1;  
                    state <= WRITE_RESP;
                          end
                         end

                WRITE_RESP: begin
                    if (S_bvalid) begin
                       if (S_bresp == 2'b00) begin
                         write_completed<=1'b1;
                       end
                       else
                       begin
                          write_completed<=1'b0;
                        end
                        M_bready <= 0;
                        state  <= IDLE;
                    end
                end

            endcase
        end
   end
   end
endmodule

