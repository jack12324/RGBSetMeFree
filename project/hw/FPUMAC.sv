module FPUMAC(clk, rst_n, col0, col1, col2, filter, result_pixels);
	input clk, rst_n;
	input [7:0] col0 [9:0];
	input [7:0] col1 [9:0];
	input [7:0] col2 [9:0];
	output [7:0] result_pixels [7:0];
endmodule
