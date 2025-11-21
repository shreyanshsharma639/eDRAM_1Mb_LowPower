`timescale 1ns / 1ps

module precharge_circuit (
    input  wire         precharge_en, 
    inout  wire [255:0] bitlines     
);
    assign bitlines = (precharge_en) ? 256'hFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF : 256'bZ;
endmodule
