`timescale 1ns / 1ps

module TOP_tb;
    // ============================
    // Signals Declaration
    // ============================
    reg PCLK, PRESET, PWRITE;
    reg [31:0] Raddr1, Raddr2, Waddr;
    wire [15:0] operand1, operand2;
    wire [31:0] result;
    wire reading_completed, write_completed;

    // ============================
    // DUT Instantiation
    // ============================
    TOP DUT (
        .PCLK(PCLK),
        .PRESET(PRESET),
        .PWRITE(PWRITE),
        .Raddr1(Raddr1),
        .Raddr2(Raddr2),
        .Waddr(Waddr),
        .reading_completed(reading_completed),
        .write_completed(write_completed),
        .operand1(operand1),
        .operand2(operand2),
        .result(result)
    );

    // ============================
    // Clock Generation
    // ============================
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;  // 100 MHz clock, 10 ns period
    end

    // ============================
    // Test Procedure
    // ============================
    initial begin
        $display("==== Starting Testbench ====");

        // Reset Phase
        PRESET = 1;
        PWRITE = 0;
        Raddr1 = 0;
        Raddr2 = 0;
        Waddr  = 0;
        #50;  // Hold reset for 50 ns
        PRESET = 0;
        $display("System Reset Done.");

        // ============================
        // APB Read Transaction
        // ============================
        #10;
        PWRITE = 0;
        Raddr1 = 32'h1211_1111;  // Address for operand1
        Raddr2 = 32'h1312_2222;  // Address for operand2
        $display("Read Request Sent | Raddr1: %h | Raddr2: %h", Raddr1, Raddr2);

        // Wait for read completion
        wait (reading_completed);
        #10;
        $display("Read Completed | Operand1: %0d | Operand2: %0d", operand1, operand2);

        // ============================
        // APB Write Transaction (Wdata = Operand1 * Operand2)
        // ============================
        #20;
        PWRITE = 1;
        Waddr = 32'h1111_0000;  // Address to store the result
        $display("Write Request Sent | Waddr: %h | Expected Result: %0d", Waddr, operand1 * operand2);

        // Wait for write completion
        wait (write_completed);
        $display("Write Completed | Result Written: %0d", result);

        // ============================
        // End Simulation
        // ============================
        $display("==== Test Completed Successfully ====");
       #120
        $finish;
    end

    // ============================
    // Monitor Signals Continuously
    // ============================
    initial begin
        $monitor("Time: %0t | PWRITE: %b | Raddr1: %h | Raddr2: %h | Operand1: %0d | Operand2: %0d | Result: %0d | Read Done: %b | Write Done: %b",
                 $time, PWRITE, Raddr1, Raddr2, operand1, operand2, result, reading_completed, write_completed);
    end

    // ============================
    // Dump VCD for Waveform Analysis
    // ============================
    initial begin
        $dumpfile("TOP_tb.vcd");
        $dumpvars(0, TOP_tb);
    end

endmodule