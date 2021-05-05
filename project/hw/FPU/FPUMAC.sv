module FPUMAC #(parameter COL_WIDTH = 10) (clk, rst_n, col0, col1, col2, filter, result_pixels);
	input clk, rst_n;
	input [7:0] col0 [COL_WIDTH-1:0];
	input [7:0] col1 [COL_WIDTH-1:0];
	input [7:0] col2 [COL_WIDTH-1:0];
	input signed [7:0] filter [8:0];
	output [7:0] result_pixels [COL_WIDTH-3:0];

	genvar j;

	generate
		for(j = 0; j < COL_WIDTH-2; j++)begin
			//note that the array is acually flipped around from what it would look like on paper. ie flip the columns and then the rows.
			FilterMAC fmac(.clk(clk), .rst_n(rst_n), .array0(  { <<8{col0[j  ], col1[j  ], col2[j  ],
										 col0[j+1], col1[j+1], col2[j+1],
										 col0[j+2], col1[j+2], col2[j+2] }}),
				.array1(filter), .result_pixel(result_pixels[j]));
		end
	endgenerate
endmodule
