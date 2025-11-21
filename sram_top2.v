`timescale 1ns / 1ps

module sram_top (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [14:0] addr,
    input  logic [31:0] din,
    input  logic       ce_n,
    input  logic       we_n,
    output logic [31:0] dout
);

    wire [15:0] bank_sel_w;
    wire [10:0] bank_addr_w;
    wire        precharge_en_w;
    wire        row_decode_en_w;
    wire        col_decode_en_w;
    wire        sense_amp_en_w;
    wire        write_driver_en_w;
    wire [15:0] request_wakeup_w;
    wire [15:0] access_done_w;
    wire [15:0] bank_active_status_w;
    wire [15:0] power_gate_en_w;
    wire [15:0] rbb_en_w;
    wire [31:0] all_banks_dout [15:0];

    controller u_controller (
        .clk(clk),
        .rst_n(rst_n),
        .addr(addr),
        .ce_n(ce_n),
        .we_n(we_n),
        .bank_active_status(bank_active_status_w),
        .bank_sel(bank_sel_w),
        .bank_addr(bank_addr_w),
        .precharge_en(precharge_en_w),
        .row_decode_en(row_decode_en_w),
        .col_decode_en(col_decode_en_w),
        .sense_amp_en(sense_amp_en_w),
        .write_driver_en(write_driver_en_w),
        .request_wakeup(request_wakeup_w),
        .access_done(access_done_w)
    );

    power_management_unit u_pmu (
        .clk(clk),
        .rst_n(rst_n),
        .request_wakeup(request_wakeup_w),
        .access_done(access_done_w),
        .power_gate_en(power_gate_en_w),
        .rbb_en(rbb_en_w),
        .bank_active_status(bank_active_status_w)
    );

    generate
        for (genvar i = 0; i < 16; i = i + 1) begin : BANK_GEN
            
            if (i < 2) begin
                memory_bank_2 bank_inst (
                    .clk(clk),
                    .rst_n(rst_n),
                    .bank_addr(bank_addr_w),
                    .din(din),
                    
                    .precharge_en(precharge_en_w    & bank_sel_w[i]),
                    .row_decode_en(row_decode_en_w  & bank_sel_w[i]),
                    .col_decode_en(col_decode_en_w  & bank_sel_w[i]),
                    .sense_amp_en(sense_amp_en_w    & bank_sel_w[i]),
                    .write_driver_en(write_driver_en_w & bank_sel_w[i]),
                    
                    .power_gate_en(power_gate_en_w[i]),
                    .rbb_en(rbb_en_w[i]),
                    .bank_dout(all_banks_dout[i])
                );
            end else begin
                assign all_banks_dout[i] = 32'bZ;
            end
            
        end
    endgenerate

    assign dout = all_banks_dout[addr[14:11]];

endmodule