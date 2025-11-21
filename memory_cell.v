`timescale 1ns / 1ps

module memory_cell (
    input wire clk,      
    input wire rst_n,    
   
    input wire  wl,      
    input wire  write_en,
    inout wire  bl
);
    parameter LEAKAGE_CYCLES = 2000;
    reg stored_charge;
    reg [$clog2(LEAKAGE_CYCLES)-1:0] leakage_counter;

    assign bl = (wl && !write_en) ? stored_charge : 1'bz;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stored_charge   <= 1'b0;
            leakage_counter <= 0;
        end else begin
            if (wl) begin
                stored_charge   <= bl;
                leakage_counter <= 0;
            end
            else if (stored_charge == 1'b1) begin
                if (leakage_counter >= LEAKAGE_CYCLES) begin
                    stored_charge <= 1'b0;
                end else begin
                    leakage_counter <= leakage_counter + 1;
                end
            end
            else begin
                 leakage_counter <= 0;
            end
        end
    end

endmodule

