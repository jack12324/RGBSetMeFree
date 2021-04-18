module FPUBuffers #(COL_WIDTH = 10) (clk, rst_n, shift_cols, col_new, col0, col1, col2);
	input clk, rst_n, shift_cols;
	input [7:0] col_new [COL_WIDTH - 1:0];
	output logic [7:0] col0   [COL_WIDTH - 1:0];
	output logic [7:0] col1   [COL_WIDTH - 1:0];
	output logic [7:0] col2   [COL_WIDTH - 1:0];
	
	always_ff @(posedge clk, negedge rst_n)begin
		if(!rst_n)begin
			col0 <= '{default:'0};
			col1 <= '{default:'0};
			col2 <= '{default:'0};
		end
		else if(shift_cols)begin
			col0 <= col1;
			col1 <= col2;
			col2 <= col_new;
		end
	end
endmodule
