`timescale 1ns / 1ps

module sram_top (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [14:0] addr,
    input  logic [31:0] din,
    input  logic        ce_n,
    input  logic        we_n,
    output logic [31:0] dout
);

    wire [10:0] bank_addr;
    wire        precharge_en;
    wire        row_decode_en;
    wire        col_decode_en;
    wire        sense_amp_en;
    wire        write_driver_en;
    wire [15:0] request_wakeup;
    wire [15:0] access_done;
    wire [15:0] bank_active_status;
    wire [15:0] power_gate_en;
    wire [15:0] rbb_en;
    wire [15:0] bank_sel;
    wire [31:0] all_banks_dout [15:0];

    controller u_controller (
        .clk(clk),
        .rst_n(rst_n),
        .addr(addr),
        .ce_n(ce_n),
        .we_n(we_n),
        .bank_active_status(bank_active_status),
        .bank_sel(bank_sel),
        .bank_addr(bank_addr),
        .precharge_en(precharge_en),
        .row_decode_en(row_decode_en),
        .col_decode_en(col_decode_en),
        .sense_amp_en(sense_amp_en),
        .write_driver_en(write_driver_en),
        .request_wakeup(request_wakeup),
        .access_done(access_done)
    );

    power_management_unit u_pmu (
        .clk(clk),
        .rst_n(rst_n),
        .request_wakeup(request_wakeup),
        .access_done(access_done),
        .power_gate_en(power_gate_en),
        .rbb_en(rbb_en),
        .bank_active_status(bank_active_status)
    );

   generate
        for (genvar i = 0; i < 16; i++) begin : BANK_GEN
            
            wire bank_precharge_en   = precharge_en    & bank_sel[i];
            wire bank_row_decode_en  = row_decode_en   & bank_sel[i];
            wire bank_col_decode_en  = col_decode_en   & bank_sel[i];
            wire bank_sense_amp_en   = sense_amp_en    & bank_sel[i];
            wire bank_write_driver_en= write_driver_en & bank_sel[i];

            memory_bank u_bank (
                .clk(clk),
                .rst_n(rst_n),
                .bank_addr(bank_addr), 
                .din(din),
                
                .precharge_en(bank_precharge_en),
                .row_decode_en(bank_row_decode_en),
                .col_decode_en(bank_col_decode_en),
                .sense_amp_en(bank_sense_amp_en),
                .write_driver_en(bank_write_driver_en),

                .power_gate_en(power_gate_en[i]),
                .rbb_en(rbb_en[i]),
                .bank_dout(all_banks_dout[i])
            );
        end
    endgenerate

    always_comb begin

        dout = 32'bZ;
        case (bank_sel)
            16'h0001: dout = all_banks_dout[0];
            16'h0002: dout = all_banks_dout[1];
            16'h0004: dout = all_banks_dout[2];
            16'h0008: dout = all_banks_dout[3];
            16'h0010: dout = all_banks_dout[4];
            16'h0020: dout = all_banks_dout[5];
            16'h0040: dout = all_banks_dout[6];
            16'h0080: dout = all_banks_dout[7];
            16'h0100: dout = all_banks_dout[8];
            16'h0200: dout = all_banks_dout[9];
            16'h0400: dout = all_banks_dout[10];
            16'h0800: dout = all_banks_dout[11];
            16'h1000: dout = all_banks_dout[12];
            16'h2000: dout = all_banks_dout[13];
            16'h4000: dout = all_banks_dout[14];
            16'h8000: dout = all_banks_dout[15];
            default:  dout = 32'bZ;
        endcase
    end

endmodule
