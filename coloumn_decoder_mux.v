`timescale 1ns / 1ps

module column_decoder_mux(
    input  wire [2:0]  col_addr,          
    input  wire        col_decode_en,     
    inout  wire [255:0] bitlines_array,    
    inout  wire [31:0]  selected_bitlines  
);
  
    genvar i, j;
    generate
        for (j = 0; j < 8; j = j + 1) begin : COL_GROUP            
            wire switch_enable = (col_decode_en && (col_addr == j)); 
            for (i = 0; i < 32; i = i + 1) begin : BIT_SWITCH              
                tranif1 (bitlines_array[j*32 + i], selected_bitlines[i], switch_enable);
            end
        end
    endgenerate
endmodule

