`timescale 1ns / 1ps

module row_decoder (
    input  wire [7:0]  row_addr,    // The binary address of the row to select
    input  wire        decode_en,   // Enables the decoder output
    output reg  [255:0] wordline    // One-hot output, activates a single row
);
 
    always @* begin   
        for (integer i = 0; i < 256; i = i + 1) begin    
            if (decode_en && (row_addr == i)) begin
                wordline[i] = 1'b1; 
            end else begin
                wordline[i] = 1'b0; 
            end
        end
    end

endmodule
