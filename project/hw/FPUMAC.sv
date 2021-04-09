module FPUMAC #(parameter COL_WIDTH = 10) (clk, rst_n, col0, col1, col2, filter, result_pixels);
	input clk, rst_n;
	input [7:0] col0 [COL_WIDTH-1:0];
	input [7:0] col1 [COL_WIDTH-1:0];
	input [7:0] col2 [COL_WIDTH-1:0];
	input signed [7:0] filter [8:0];
	output [7:0] result_pixels [COL_WIDTH-3:0];

	genvar i;

	generate
		for(i = 0; i < COL_WIDTH-3; i++)begin
			FilterMAC fmac(.clk(clk), .rst_n(rst_n), .array0({col0[i+2:i], col1[i+2:i], col2[i+2:i]}), .array1(filter), .result_pixel(result_pixels[i]));	
		end
	endgenerate
endmodule
