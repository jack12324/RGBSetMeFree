module FPUBuffers(clk, rst_n, shift_rows, col_new, col0, col1, col2);
	input clk, rst_n, shift_rows;
	input [7:0] col_new [9:0];
	output [7:0] col0 [9:0];
	output [7:0] col1 [9:0];
	output [7:0] col2 [9:0];
	
	always_ff @(posedge clk, negedge rst_n)begin
		if(!rst_n)begin
			col0 <= 0;
			col1 <= 0;
			col2 <= 0;
		end
		else if(shift_rows)begin
			col0 <= col1;
			col1 <= col2;
			col2 <= col_new;
		end
	end
endmodule
