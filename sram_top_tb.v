`timescale 1ns / 1ps

module sram_top_tb;

    logic        clk;
    logic        rst_n;
    logic [14:0] addr_tb;
    logic [31:0] din_tb;
    logic        ce_n_tb;
    logic        we_n_tb;
    wire [31:0] dout_tb;

    sram_top DUT (
        .clk(clk),
        .rst_n(rst_n),
        .addr(addr_tb),
        .din(din_tb),
        .ce_n(ce_n_tb),
        .we_n(we_n_tb),
        .dout(dout_tb)
    );

    always #5 clk = ~clk;


    task write_mem(input [14:0] i_addr, input [31:0] i_data);
        @(posedge clk);
        addr_tb = i_addr;
        din_tb  = i_data;
        we_n_tb = 1'b0; 
        ce_n_tb = 1'b0; 
        
        @(posedge clk);
        ce_n_tb = 1'b1; 
        
        wait (DUT.u_controller.current_state != DUT.u_controller.IDLE);
        wait (DUT.u_controller.current_state == DUT.u_controller.IDLE);
        
        @(posedge clk);
        din_tb = 32'bZ;
    endtask

    task read_mem(input [14:0] i_addr, input [31:0] expected_data);
        @(posedge clk);
        addr_tb = i_addr;
        we_n_tb = 1'b1; 
        ce_n_tb = 1'b0; 
        
        @(posedge clk);
        ce_n_tb = 1'b1; 

        wait (DUT.u_controller.current_state == DUT.u_controller.ACCESS && DUT.u_controller.captured_we_n == 1'b1);

        #1; 

        if (dout_tb == expected_data) begin
            $display("PASSED: Read data (0x%h) from addr 0x%h matches expected.", dout_tb, i_addr);
        end else begin
            $display("FAILED: Read data (0x%h) from addr 0x%h. Expected 0x%h.", dout_tb, i_addr, expected_data);
        end
        wait (DUT.u_controller.current_state == DUT.u_controller.IDLE);
    endtask

    initial begin
        $display("SIM START: Verifying sram_top bank isolation.");
        clk = 0;
        rst_n   = 1'b0;
        addr_tb = '0;
        din_tb  = 32'bZ;
        ce_n_tb = 1'b1;
        we_n_tb = 1'b1;
        #12;
        rst_n = 1'b1;
        #10;
        $display("TEST 2: Writing 0xAAAAAAAA to address 0x0BCD (Bank 0).");
        write_mem(15'h0BCD, 32'hAAAAAAAA);

        $display("TEST 3: Writing 0xDEADBEEF to address 0xABCD (Bank 10).");
        write_mem(15'hABCD, 32'hDEADBEEF);

        $display("TEST 4: Reading from address 0xABCD (Bank 10) to confirm write.");
        read_mem(15'hABCD, 32'hDEADBEEF);

        $display("TEST 5: Reading from address 0x0BCD (Bank 0) to check for corruption.");
        read_mem(15'h0BCD, 32'hAAAAAAAA); // This test will FAIL, proving the bug.

        #20;
        $display("SIM END: Verification complete.");
        $finish;
    end

endmodule