`timescale 1ns / 1ps

module memory_bank ( 
    input  logic        clk,
    input  logic        rst_n,
    input  logic [10:0] bank_addr,
    input  logic [31:0] din, 
    input  logic        precharge_en,
    input  logic        row_decode_en,
    input  logic        col_decode_en,
    input  logic        sense_amp_en,
    input  logic        write_driver_en,
    input  logic        power_gate_en,
    input  logic        rbb_en,
    output logic [31:0] bank_dout
);

    wire [255:0] wordlines;         
    wire [255:0] bitlines_array;    
    wire [31:0]  selected_bitlines;   
    wire [7:0] row_addr = bank_addr[10:3];
    wire [2:0] col_addr = bank_addr[2:0];  
    generate
        for (genvar r = 0; r < 256; r++) begin : ROW_GEN
            for (genvar c = 0; c < 256; c++) begin : COL_GEN
                memory_cell mem_cell_inst (
                    .clk(clk),
                    .rst_n(rst_n),
                    .wl(wordlines[r]),
                    .write_en(write_driver_en), 
                    .bl(bitlines_array[c])
                );
            end
        end
    endgenerate


    row_decoder u_row_decoder (
        .row_addr(row_addr),
        .decode_en(row_decode_en),
        .wordline(wordlines)
    );

    precharge_circuit u_precharge_circuit (
        .precharge_en(precharge_en),
        .bitlines(bitlines_array)
    );

    column_decoder_mux u_col_mux (
        .col_addr(col_addr),
        .col_decode_en(col_decode_en),
        .bitlines_array(bitlines_array),
        .selected_bitlines(selected_bitlines)
    );


    write_driver_bank u_write_driver (
        .data_in(din),
        .write_driver_en(write_driver_en),
        .data_out(selected_bitlines)
    );

    sense_amplifier_bank u_sense_amp (
        .data_in(selected_bitlines),
        .sense_amp_en(sense_amp_en),
        .data_out(bank_dout)
    );

endmodule

