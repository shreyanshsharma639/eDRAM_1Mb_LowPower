`timescale 1ns / 1ps

module write_driver_bank (
    input  wire [31:0] data_in,          
    input  wire        write_driver_en, 
	output wire [31:0] data_out         
);
    assign data_out = (write_driver_en) ? data_in : 32'bZ;

endmodule
