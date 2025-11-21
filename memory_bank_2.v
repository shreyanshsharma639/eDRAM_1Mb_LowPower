`timescale 1ns / 1ps

module memory_bank (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [10:0] bank_addr,
    input  logic [31:0] din,
    input  logic       precharge_en,
    input  logic       row_decode_en,
    input  logic       col_decode_en,
    input  logic       sense_amp_en,
    input  logic       write_driver_en,
    input  logic       power_gate_en,
    input  logic       rbb_en,
    output logic [31:0] bank_dout
);

    wire [7:0] row_addr = bank_addr[10:3]; 
    wire [2:0] col_addr = bank_addr[2:0]; 

    logic [31:0] memory_array [255:0][7:0];
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int r = 0; r < 256; r++) begin
                for (int c = 0; c < 8; c++) begin
                    memory_array[r][c] <= 32'b0;
                end
            end
        end else if (write_driver_en) begin
            memory_array[row_addr][col_addr] <= din;
        end
    end

    always @* begin
        if (sense_amp_en) begin
            bank_dout = memory_array[row_addr][col_addr];
        end else begin
            bank_dout = 32'bZ;
        end
    end

endmodule