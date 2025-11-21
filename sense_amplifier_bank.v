`timescale 1ns / 1ps

module sense_amplifier_bank (
    input  wire [31:0] data_in,         
    input  wire        sense_amp_en,   
    output wire [31:0] data_out        
);
    assign data_out = (sense_amp_en) ? data_in : 32'bZ;

endmodule
